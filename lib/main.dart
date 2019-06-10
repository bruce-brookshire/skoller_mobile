import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'screens/auth/auth_home.dart';
import 'constants/constants.dart';
import 'screens/main_app/tab_bar.dart';
import 'constants/timezone_manager.dart';

void main() {
  runApp(SkollerApp());
  //Allow currentTZ to cache through heuristic exploration before we need it
  TimeZoneManager.verifyTzDbActive();
}

class SkollerApp extends StatefulWidget {
  @override
  State createState() => _SkollerAppState();
}

class _SkollerAppState extends State<SkollerApp> {
  bool _darkTheme = false;
  AppState currentState = AppState.loading;

  void changeAppState(AppState newState) {
    setState(() {
      currentState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme;

    if (_darkTheme) {
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
    Widget currentWidget;

    switch (currentState) {
      case AppState.loading:
        currentWidget = AuthHome(changeAppState);
        break;
      case AppState.failedLoading:
        currentWidget = AuthHome(changeAppState);
        break;
      case AppState.authScreen:
        currentWidget = AuthHome(changeAppState);
        break;
      case AppState.mainApp:
        currentWidget = MainView(changeAppState);
        break;
    }

    return MaterialApp(
      builder: (context, widget) => Theme(data: currentTheme, child: widget),
      theme: currentTheme,
      home: currentWidget,
    );
  }
}
