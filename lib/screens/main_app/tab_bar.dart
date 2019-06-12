import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  int _selectedIndex = 0;
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

  @override
  Widget build(BuildContext context) => WillPopScope(
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _selectedIndex == 0
                    ? Image.asset("image_assets/tab_bar_assets/tasks_blue.png")
                    : Image.asset("image_assets/tab_bar_assets/tasks_gray.png"),
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 1
                    ? Image.asset(
                        "image_assets/tab_bar_assets/calendar_blue.png")
                    : Image.asset(
                        "image_assets/tab_bar_assets/calendar_gray.png"),
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 2
                    ? Image.asset("image_assets/tab_bar_assets/chat_blue.png")
                    : Image.asset("image_assets/tab_bar_assets/chat_gray.png"),
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 3
                    ? Image.asset(
                        "image_assets/tab_bar_assets/classes_blue.png")
                    : Image.asset(
                        "image_assets/tab_bar_assets/classes_gray.png"),
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 4
                    ? Image.asset(
                        "image_assets/tab_bar_assets/activity_blue.png")
                    : Image.asset(
                        "image_assets/tab_bar_assets/activity_gray.png"),
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      );
  //Icon(Icons.school)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
