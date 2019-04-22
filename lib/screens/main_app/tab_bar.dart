import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import '../../requests/requests_core.dart';
import '../../constants/constants.dart';
import 'tasks/tasks_view.dart';
import 'classes/classes_view.dart';
import 'calendar/calendar.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _widgetOptions = [
    TasksView(),
    CalendarView(),
    ClassesView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Auth.logIn('bruce@skoller.co', 'password').then((success) {
    //   if (success) {
    //     StudentClass.getStudentClasses().then((onValue) {
    //       print(onValue);
    //     });
    //   }
    // });
//TODO: CupertinoPageScaffold necessary?
    return CupertinoTabScaffold(
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) {
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
                ? Image.asset("image_assets/tab_bar_assets/calendar_blue.png")
                : Image.asset("image_assets/tab_bar_assets/calendar_gray.png"),
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Image.asset("image_assets/tab_bar_assets/classes_blue.png")
                : Image.asset("image_assets/tab_bar_assets/classes_gray.png"),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
      ),
    );
  }
  //Icon(Icons.school)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
