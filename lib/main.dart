import 'package:flutter/material.dart';
import 'requests/requests_core.dart';
import 'screens/auth/auth_home.dart';
import 'constants/constants.dart';
import 'screens/main_app/tab_bar.dart';
import 'constants/timezone_manager.dart';

void main() {
  runApp(MyApp());
  //Allow currentTZ to cache through heuristic exploration before we need it
  TimeZoneManager.verifyTzDbActive();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = false;

    ThemeData currentTheme;
    if (isDarkTheme) {
      currentTheme = ThemeData(
        primaryColor: SKColors.skoller_blue,
        accentColor: SKColors.skoller_blue,
        backgroundColor: SKColors.dark_gray,
        scaffoldBackgroundColor: SKColors.dark_gray,
        textTheme: TextTheme(
          body1: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          body2: TextStyle(
              color: SKColors.skoller_blue,
              fontSize: 15,
              fontWeight: FontWeight.bold),
          button: TextStyle(color: Colors.white),
        ),
      );
    } else {
      currentTheme = ThemeData(
        primaryColor: SKColors.skoller_blue,
        accentColor: SKColors.skoller_blue,
        backgroundColor: SKColors.background_gray,
        scaffoldBackgroundColor: SKColors.background_gray,
        textTheme: TextTheme(
          body1: TextStyle(
              color: SKColors.dark_gray,
              fontSize: 15,
              fontWeight: FontWeight.bold),
          body2: TextStyle(
              color: SKColors.skoller_blue,
              fontSize: 15,
              fontWeight: FontWeight.bold),
          button: TextStyle(color: Colors.white),
        ),
      );
    }

    return MaterialApp(
      builder: (context, widget) => Theme(data: currentTheme, child: widget),
      theme: currentTheme,
      home: AuthHome(),
    );
  }
}
