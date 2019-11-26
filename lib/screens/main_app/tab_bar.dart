import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'activity/activity_view.dart';
import 'forecast/todo_view.dart';
import 'package:skoller/tools.dart';
import 'classes/classes_view.dart';
import 'chat/chat_list_view.dart';
import 'calendar/calendar.dart';

class SKTabBar extends StatefulWidget {
  @override
  _SKTabBarState createState() => _SKTabBarState();
}

class _SKTabBarState extends State<SKTabBar> {
  final _widgetOptions = [
    TodoView(),
    CalendarView(),
    ChatListView(),
    ClassesView(),
    ActivityView(),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<NavigatorObserver> _navigatorObservers = [
    FirebaseAnalyticsObserver(analytics: Analytics.analytics),
    FirebaseAnalyticsObserver(analytics: Analytics.analytics),
    FirebaseAnalyticsObserver(analytics: Analytics.analytics),
    FirebaseAnalyticsObserver(analytics: Analytics.analytics),
    FirebaseAnalyticsObserver(analytics: Analytics.analytics),
  ];

  final List<String> _indexIconPartialPaths = [
    'forecast_',
    'calendar_',
    'chat_',
    'classes_',
    'activity_',
  ];

  List<bool> _indexNeedsDot = [false, false, false, false, false];

  CupertinoTabController controller;

  var prevIndex = StudentClass.currentClasses.length == 0 ? CLASSES_TAB : FORECAST_TAB;

  @override
  void initState() {
    super.initState();

    controller = CupertinoTabController(initialIndex: prevIndex);

    checkAlertDots();

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.classChanged,
      observer: this,
      onNotification: (_) {
        checkAlertDots();
        if (mounted) setState(() {});
      },
    );

    DartNotificationCenter.subscribe(
      observer: this,
      channel: NotificationChannels.selectTab,
      onNotification: (index) {
        controller.index = index;
        if (mounted) setState(() {});
      },
    );

    SchedulerBinding.instance.addPostFrameCallback(afterFirstLayout);
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    controller.dispose();
    super.dispose();
  }

  void afterFirstLayout(_) {
    for (final partialPath in _indexIconPartialPaths) {
      precacheImage(
          AssetImage('image_assets/tab_bar_assets/${partialPath}blue.png'),
          context);
      precacheImage(
          AssetImage('image_assets/tab_bar_assets/${partialPath}gray.png'),
          context);
    }
  }

  void checkAlertDots() {
    _indexNeedsDot[CLASSES_TAB] = StudentClass.currentClasses.values.any(
      (elem) => [ClassStatuses.needs_setup, ClassStatuses.needs_student_input]
          .contains(elem.status.id),
    );

    _indexNeedsDot[ACTIVITY_TAB] =
        Mod.currentMods.values.any((mod) => mod.isAccepted == null);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigatorKeys[controller.index].currentState.maybePop();
        return false;
      },
      child: CupertinoTabScaffold(
        controller: controller,
        tabBuilder: (context, index) {
          return CupertinoTabView(
              navigatorKey: _navigatorKeys[index],
              navigatorObservers: [_navigatorObservers[index]],
              builder: (context) {
                return CupertinoPageScaffold(child: _widgetOptions[index]);
              });
        },
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          items: List.generate(5, createTabIndex),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem createTabIndex(int index) {
    if (!_indexNeedsDot[index])
      return BottomNavigationBarItem(
        icon: Image.asset(
            'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${controller.index == index ? 'blue' : 'gray'}.png'),
      );
    else
      return BottomNavigationBarItem(
        icon: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Image.asset(
                    'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${controller.index == index ? 'blue' : 'gray'}.png'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: SKColors.warning_red,
                ),
                width: 4,
                height: 4,
              ),
            )
          ],
        ),
      );
  }

  void _onItemTapped(int index) {
    if (prevIndex == index)
      _navigatorKeys[index]
          .currentState
          ?.popUntil((route) => route.settings.isInitialRoute);

    prevIndex = index;
    if (mounted) setState(() {});
  }
}
