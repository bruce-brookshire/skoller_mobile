import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/tools.dart';
import 'chat/chat_list_view.dart';
import 'tasks/tasks_view.dart';
import 'classes/classes_view.dart';
import 'calendar/calendar.dart';
import 'activity/activity_view.dart';

class SKTabBar extends StatefulWidget {
  @override
  _SKTabBarState createState() => _SKTabBarState();
}

class _SKTabBarState extends State<SKTabBar> {
  final _widgetOptions = [
    TasksView(),
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

  final List<String> _indexIconPartialPaths = [
    'tasks_',
    'calendar_',
    'chat_',
    'classes_',
    'activity_',
  ];

  List<bool> _indexNeedsDot = [false, false, false, false, false];
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    checkAlertDots();

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.classChanged,
      observer: this,
      onNotification: (_) {
        checkAlertDots();
        if (mounted) setState(() {});
      },
    );

    SchedulerBinding.instance.addPostFrameCallback(afterFirstLayout);
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
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
    _indexNeedsDot[3] = StudentClass.currentClasses.values.fold(
        false,
        (val, elem) => val
            ? val
            : ![
                ClassStatuses.class_setup,
                ClassStatuses.class_issue,
                ClassStatuses.syllabus_submitted
              ].contains(elem.status.id));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == null) {
      if (StudentClass.currentClasses.length == 0) {
        _selectedIndex = 3;
      } else {
        _selectedIndex = 0;
      }
    }
    return WillPopScope(
      onWillPop: () async {
        _navigatorKeys[_selectedIndex].currentState.maybePop();
        return false;
      },
      child: CupertinoTabScaffold(
        tabBuilder: (context, index) {
          return CupertinoTabView(
              navigatorKey: _navigatorKeys[index],
              builder: (context) {
                return CupertinoPageScaffold(child: _widgetOptions[index]);
              });
        },
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          items: List.generate(5, createTabIndex),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem createTabIndex(int index) {
    if (!_indexNeedsDot[index])
      return BottomNavigationBarItem(
        icon: Image.asset(
            'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${_selectedIndex == index ? 'blue' : 'gray'}.png'),
      );
    else
      return BottomNavigationBarItem(
        icon: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Image.asset(
                    'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${_selectedIndex == index ? 'blue' : 'gray'}.png'),
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
    setState(() {
      _selectedIndex = index;
    });
  }
}
