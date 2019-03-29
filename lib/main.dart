import 'package:flutter/material.dart';
import 'requests/requests_core.dart';
import 'sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: SignIn(),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final _widgetOptions = [
    Text('Index 0: Tasks'),
    Text('Index 1: Grades'),
    Text('Index 2: School'),
  ];

  @override
  Widget build(BuildContext context) {
    Auth.logIn('bruce@skoller.co', 'password').then((success) {
      if (success) {
        StudentClass.getStudentClasses().then((onValue) {
          print(onValue);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('BottomNavigationBar Sample'),
      ),
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
