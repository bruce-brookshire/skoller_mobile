import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/main_app/menu_view.dart';
import 'tab_bar.dart';

class MainView extends StatefulWidget {
  @override
  State createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool menuShowing = false;
  bool constraintsSetup = false;

  double deviceHeight;
  double deviceWidth;

  double menuTop;
  double menuHeight;

  double backgroundTop;
  double backgroundHeight;

  @override
  void initState() {
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
        menuTop = 0;
        backgroundTop = menuHeight - 15;
      } else {
        menuTop = -menuHeight - 5;
        backgroundTop = -backgroundHeight - 5;
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
      deviceHeight = size.height;

      menuHeight = deviceHeight * 0.7;
      menuTop = -menuHeight - 5;

      backgroundHeight = (deviceHeight - menuHeight) + 15;
      backgroundTop = -backgroundHeight - 5;
    }

    return Stack(
      children: <Widget>[
        SKTabBar(),
        AnimatedPositioned(
          top: backgroundTop,
          height: backgroundHeight,
          left: 0,
          width: deviceWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: toggleMenu,
            child: Container(
              color: menuShowing ? Colors.black.withOpacity(0.3) : null,
            ),
          ),
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
        ),
        AnimatedPositioned(
          top: menuTop,
          height: menuHeight,
          left: 0,
          width: deviceWidth,
          child: MenuView(),
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
        ),
      ],
    );
  }
}
