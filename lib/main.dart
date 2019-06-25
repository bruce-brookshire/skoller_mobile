import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:skoller/loading_view.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'screens/auth/auth_home.dart';
import 'constants/constants.dart';
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

  void changeAppState(dynamic newState) {
    if (newState is AppState) {
      setState(() {
        currentState = newState;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.appStateChanged,
      observer: this,
      onNotification: changeAppState,
    );
  }

  @override
  void dispose() {
    super.dispose();

    DartNotificationCenter.unsubscribe(
      channel: NotificationChannels.appStateChanged,
      observer: this,
    );
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
        currentWidget = LoadingView();
        break;
      case AppState.main:
        currentWidget = MainView();
        break;
      case AppState.auth:
        currentWidget = AuthHome();
        break;
      case AppState.veri:
        currentWidget = MainView();
        break;
    }

    return MaterialApp(
      builder: (context, widget) => Theme(data: currentTheme, child: widget),
      theme: currentTheme,
      home: currentWidget,
    );
  }
}
