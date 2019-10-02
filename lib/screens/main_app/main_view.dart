import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/menu/major_search_modal.dart';
import 'package:skoller/screens/main_app/tutorial/tutorial.dart';
import 'package:skoller/constants/constants.dart';
import 'package:app_review/app_review.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:url_launcher/url_launcher.dart';
import 'primary_school_modal.dart';
import 'menu_view.dart';
import 'tab_bar.dart';
import 'dart:io';

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
    // If the student does not have a primary school or term, set it
    if (SKUser.current.student.primarySchool == null ||
        SKUser.current.student.primaryPeriod == null)
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showPrimarySchoolModal(),
      );
    // If the student has no majors and they have at least one class set up
    else if ((SKUser.current.student.fieldsOfStudy ?? []).length == 0 &&
        StudentClass.currentClasses.values.any((sc) => [
              ClassStatuses.class_setup,
              ClassStatuses.class_issue
            ].contains(sc.status.id ?? 0)))
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showMajorSelection(),
      );

    // If the user can review
    else {
      checkSeedInvestPopup();
      checkAppReview();
    }

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

    Mod.fetchMods();

    WidgetsBinding.instance.addPostFrameCallback((_) => setScreenSize());

    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    super.dispose();
  }

  void showPrimarySchoolModal() {
    Navigator.push(
      context,
      SKNavOverlayRoute(
        builder: (context) => PrimarySchoolModal(),
        isBarrierDismissible: false,
      ),
    );
  }

  void showMajorSelection() async {
    final inst = await SharedPreferences.getInstance();
    final alreadyShown =
        await inst.containsKey(PreferencesKeys.kShouldAskMajor);

    // If the db shows we've already asked, just return.
    if (alreadyShown) return;

    final loader = SKLoadingScreen.fadeIn(context);
    final result = await FieldsOfStudy.getFieldsOfStudy();
    loader.dismiss();

    if (result.wasSuccessful()) {
      inst.setBool(PreferencesKeys.kShouldAskMajor, false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MajorSelector(result.obj),
      );
    }
  }

  void checkSeedInvestPopup() async {
    final inst = await SharedPreferences.getInstance();
    final action_name = 'seed_invest_popup';
    final utc_now = DateTime.now().toUtc();
    final deadline = DateTime.utc(2019, 11, 1);

    if (!inst.containsKey(action_name) && utc_now.isBefore(deadline)) {
      inst.setBool(action_name, true);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray),
              boxShadow: [UIAssets.boxShadow],
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: (_) => Navigator.pop(context),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                    Text(
                      'For a LIMITED time',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 32,
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Don’t miss out! The power of Skoller can be in your hands...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset('image_assets/$action_name.png'),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (_) async {
                    final url = 'https://seedinvest.com/skoller';
                    if (await canLaunch(url)) {
                      launch(url);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: SKColors.skoller_blue,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Check it out!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void checkAppReview() async {
    final inst = await SharedPreferences.getInstance();

    final hasShown = await inst.get(PreferencesKeys.kShouldReview);

    if (hasShown is bool || (hasShown != null && !(hasShown is String))) return;

    final now = DateTime.now();
    final scheduled = hasShown == null ? null : DateTime.parse(hasShown);

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
            curCount);

    final assignmentCompleted = Assignment.currentAssignments.values
        .any((a) => (a.due?.isBefore(now) ?? false) || a.completed);

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

  Future<bool> createAndroidReviewRequest(bool showRatingDisable) async {
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
                    child: Image.asset(ImageNames.chatImages.star_yellow),
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
                        boxShadow: [UIAssets.boxShadow]),
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

    Navigator.push(
      context,
      SKNavOverlayRoute(builder: (context) => viewToPresent),
    );
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
