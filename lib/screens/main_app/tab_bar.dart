import 'package:flutter/material.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';
import 'tasks_view.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _widgetOptions = [
    TasksView(),
    Text('Index 1: Grades'),
    TasksView(),
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

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Image.asset("image_assets/tab_bar_assets/tasks_blue.png")
                : Image.asset("image_assets/tab_bar_assets/tasks_gray.png"),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Image.asset("image_assets/tab_bar_assets/classes_blue.png")
                : Image.asset("image_assets/tab_bar_assets/classes_gray.png"),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Image.asset("image_assets/tab_bar_assets/activity_blue.png")
                : Image.asset("image_assets/tab_bar_assets/activity_gray.png"),
            title: Text('School'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
