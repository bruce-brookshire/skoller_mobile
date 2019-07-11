import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/tools.dart';
import 'dart:async';
import 'tab_bar.dart';
import 'menu_view.dart';
import 'primary_school_view.dart';

class MainView extends StatefulWidget {
  @override
  State createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool menuShowing = false;
  bool constraintsSetup = false;

  double deviceWidth;

  double menuLeft;
  double menuWidth;

  double backgroundLeft;
  double backgroundWidth;

  @override
  void initState() {
    // if (SKUser.current.student.primarySchool == null) {
      Timer(Duration(milliseconds: 50),
          () => {this.presentWidgetOverMainView(PrimarySchoolView())});
    // }

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

    super.initState();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              color: menuShowing ? Colors.black.withOpacity(0.3) : null,
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
