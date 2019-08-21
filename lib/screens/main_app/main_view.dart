import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/tutorial/tutorial.dart';
import 'package:skoller/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'primary_school_modal.dart';
import 'menu_view.dart';
import 'tab_bar.dart';

class MainView extends StatefulWidget {
  @override
  State createState() => _MainState();
}

class _MainState extends State<MainView> {
  bool menuShowing = false;
  bool constraintsSetup = false;

  double deviceWidth;

  double menuLeft;
  double menuWidth;

  double backgroundLeft;
  double backgroundWidth;

  @override
  void initState() {
    if (SKUser.current.student.primarySchool == null ||
        SKUser.current.student.primaryPeriod == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => showPrimarySchoolModal(context));
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

    Mod.fetchMods();

    super.initState();
  }

  showPrimarySchoolModal(BuildContext context) {
    Navigator.push(
      context,
      SKNavOverlayRoute(
        builder: (context) => PrimarySchoolModal(),
        isBarrierDismissible: false,
      ),
    );
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (StudentClass.currentClasses.length == 0) {
      return TutorialTab((context) {
        presentWidgetOverMainView(AddClassesView());
      }, 'Join your 1st class 🤓');
    } else {
      if (!constraintsSetup) {
        constraintsSetup = true;

        Size size = MediaQuery.of(context).size;
        deviceWidth = size.width;

        menuWidth = deviceWidth * 0.7;
        menuLeft = -menuWidth - 5;

        backgroundWidth = (deviceWidth - menuWidth) + 15;
        backgroundLeft = -backgroundWidth - 5;
      }

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
}
