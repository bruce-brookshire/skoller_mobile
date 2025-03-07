import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/screens/main_app/classes/class_menu_modal.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/menu/major_search_modal.dart';
import 'package:skoller/screens/main_app/premium/expired_trial_pay_wall_model.dart';
import 'package:skoller/screens/main_app/tutorial/tutorial.dart';
import 'package:skoller/tools.dart';

import 'menu_view.dart';
import 'primary_school_modal.dart';
import 'tab_bar.dart';

class MainView extends StatefulWidget {
  @override
  State createState() => _MainState();
}

class _MainState extends State<MainView> {
  bool menuShowing = false;

  double deviceWidth = 320;

  double menuWidth = 224;
  double menuLeft = -230;

  double backgroundWidth = 115;
  double backgroundLeft = -120;

  @override
  void initState() {
    /// Initializes [SubscriptionManager] which triggers fetching and setting User subscription
    SubscriptionManager.instance;

    // If the student does not have a primary school or term, set it
    if (SKUser.current?.student.primarySchool == null ||
        SKUser.current?.student.primaryPeriod == null)
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showPrimarySchoolModal(),
      );
    // If the student has no majors and they have at least one class set up
    else if ((SKUser.current?.student.fieldsOfStudy ?? []).length == 0 &&
        StudentClass.currentClasses.values.any((sc) => [
              ClassStatuses.class_setup,
              ClassStatuses.class_issue
            ].contains(sc.status.id ?? 0)))
      WidgetsBinding.instance!.addPostFrameCallback(
        (_) => showMajorSelection(),
      );

    // If the user can review
    else
      checkAppReview();

    SKCacheManager.restoreCachedData();

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.toggleMenu,
      observer: this,
      onNotification: toggleMenu,
    );

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.presentViewOverTabBar,
      observer: this,
      onNotification: presentWidgetOverMainView,
    );

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.presentModalViewOverTabBar,
      observer: this,
      onNotification: presentModalWidgetOverMainView,
    );

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.subscriptionChanged,
      observer: this,
      onNotification: showPayWallModalIfSubscriptionExpired,
    );

    Mod.fetchMods();

    WidgetsBinding.instance!.addPostFrameCallback((_) => setScreenSize());
    getSubs();
    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    super.dispose();
  }

  void showPrimarySchoolModal() async {
    await Navigator.push(
      context,
      SKNavOverlayRoute(
        builder: (context) => PrimarySchoolModal(),
        isBarrierDismissible: false,
      ),
    );

    DartNotificationCenter.post(
      channel: NotificationChannels.presentViewOverTabBar,
      options: AddClassesView(),
    );
  }

  void showPayWallModalIfSubscriptionExpired(dynamic userState) async {
    if (!Subscriptions.isTrial && !Subscriptions.isSubscriptionActive) {
      await Navigator.push(
        context,
        SKNavOverlayRoute(
          builder: (context) => ExpiredTrialPayWallModal(),
          isBarrierDismissible: false,
        ),
      );
    }
  }

  void showMajorSelection() async {
    final inst = await SharedPreferences.getInstance();
    final alreadyShown =
        await inst.containsKey(PreferencesKeys.kShouldAskMajor);

    // If the db shows we've already asked, just return.
    if (alreadyShown) return;

    final loader = SKLoadingScreen.fadeIn(context);
    final result = await FieldsOfStudy.getFieldsOfStudy();
    loader.fadeOut();

    if (result.wasSuccessful()) {
      inst.setBool(PreferencesKeys.kShouldAskMajor, false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MajorSelector(result.obj),
      );
    }
  }

  void checkAppReview() async {
    final inst = await SharedPreferences.getInstance();

    final hasShown = await inst.get(PreferencesKeys.kShouldReview);

    if (hasShown is bool || (hasShown != null && !(hasShown is String))) return;

    final now = DateTime.now();
    final scheduled =
        hasShown == null ? null : DateTime.parse(hasShown.toString());

    if (scheduled?.isAfter(now) ?? false) return;

    // Check to make sure there are at least 2 classes set up,
    // and that there is at least 1 assignment past due

    final numSetupClasses = StudentClass.currentClasses.values.toList().fold(
        0,
        (curCount, sc) =>
            ([ClassStatuses.class_setup, ClassStatuses.class_issue]
                    .contains(sc.status.id)
                ? 1
                : 0) +
            int.parse(curCount.toString()));

    final assignmentCompleted = Assignment.currentAssignments.values
        .any((a) => (a.due?.isBefore(now) ?? false) || a.isCompleted!);

    final shouldReview = numSetupClasses >= 2 && assignmentCompleted;

    if (shouldReview) {
      if (Platform.isAndroid) {
        final shouldProceed =
            await createAndroidReviewRequest(hasShown is String);

        if (shouldProceed == null) {
          inst.setString(
            PreferencesKeys.kShouldReview,
            now.add(Duration(days: 20)).toIso8601String(),
          );

          return;
        } else if (shouldProceed is bool && !shouldProceed) {
          inst.setBool(PreferencesKeys.kShouldReview, false);

          return;
        }
      }

      inst.setBool(PreferencesKeys.kShouldReview, true);

      AppReview.requestReview;
    }
  }

  void setScreenSize() {
    Size size = MediaQuery.of(context).size;
    deviceWidth = size.width;

    menuWidth = deviceWidth * 0.7;
    menuLeft = -menuWidth - 5;

    backgroundWidth = (deviceWidth - menuWidth) + 15;
    backgroundLeft = -backgroundWidth - 5;
  }

  Future<dynamic> createAndroidReviewRequest(bool showRatingDisable) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (_) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Image.asset(ImageNames.signUpImages.star_yellow),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Review us!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'When you do, it helps your peers see the value in Skoller. We would appreciate your feedback!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => Navigator.pop(context, true),
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: SKColors.skoller_blue,
                        boxShadow: UIAssets.boxShadow),
                    child: Text(
                      'Leave a review',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => Navigator.pop(context, null),
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(color: SKColors.border_gray)),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(
                        color: SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              if (showRatingDisable)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => Navigator.pop(context, false),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Text(
                        'Don\'t ask me again',
                        style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  getSubs() async {
    bool isSubscriptionAvailable = await stripeBloc.mySubscriptionsList();
    if (isSubscriptionAvailable) {
      if (!(Subscriptions.mySubscriptions?.user?.trial ?? true) &&
              !(Subscriptions.mySubscriptions?.user?.lifetimeSubscription ??
                  true) ||
          !(Subscriptions.mySubscriptions?.user?.lifetimeTrial ?? true)) {
        if (!(Subscriptions.mySubscriptions?.user?.isActive ?? true)) {
          createAPremiumFreeUserDialog();
        }
      }
    } else {
      createAPremiumFreeUserDialog();
    }
    /*Future.delayed(Duration(seconds: 2), () {
      print('token-login' +
          tokenLoginMap['user']['lifetime_subscription'].toString());
      if ((tokenLoginMap['user']['lifetime_subscription'] ?? false) == true) {
        createAPremiumFreeUserDialog();
      }
    });*/
  }

  Future<dynamic> createAPremiumFreeUserDialog() async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Image.asset(ImageNames.sammiImages.big_smile),
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'Your trial is expired!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Login on desktop at Skoller.com to manage your account settings.',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => Navigator.pop(context, true),
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: SKColors.skoller_blue,
                        boxShadow: UIAssets.boxShadow),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleMenu(dynamic withOptions) {
    setState(() {
      menuShowing = !menuShowing;

      if (menuShowing) {
        menuLeft = 0;
        backgroundLeft = menuWidth - 15;
      } else {
        menuLeft = -menuWidth - 5;
        backgroundLeft = -backgroundWidth - 5;
      }
    });
  }

  void presentWidgetOverMainView(dynamic viewToPresent) {
    if (menuShowing) toggleMenu(null);

    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => viewToPresent,
        settings: RouteSettings(name: viewToPresent.runtimeType.toString()),
      ),
    );
  }

  void presentModalWidgetOverMainView(dynamic viewToPresent) {
    if (menuShowing) toggleMenu(null);

    final route = viewToPresent is ClassMenuModal
        ? SKCoverSheetNav(builder: (_) => viewToPresent)
        : SKNavOverlayRoute(builder: (_) => viewToPresent);

    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    if (StudentClass.currentClasses.length == 0)
      return TutorialTab(
        (context) => presentWidgetOverMainView(AddClassesView()),
        'Join your 1st class 🤓',
      );
    else
      return Stack(
        children: <Widget>[
          SKTabBar(),
          AnimatedPositioned(
            left: backgroundLeft,
            width: backgroundWidth,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: toggleMenu,
              onHorizontalDragStart: toggleMenu,
              child: AnimatedContainer(
                color: menuShowing
                    ? Colors.black.withOpacity(0.3)
                    : Colors.transparent,
                duration: Duration(milliseconds: 300),
              ),
            ),
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
          ),
          AnimatedPositioned(
            left: menuLeft,
            width: menuWidth,
            top: 0,
            bottom: 0,
            child: MenuView(),
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
          ),
        ],
      );
  }
}
