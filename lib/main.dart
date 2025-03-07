// @dart = 2.9

import 'dart:io';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoller/loading_view.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/tools.dart';

import 'constants/constants.dart';
import 'constants/timezone_manager.dart';
import 'screens/auth/auth_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  runApp(SkollerApp());
  //Allow currentTZ to cache through heuristic exploration before we need it
  TimeZoneManager.verifyTzDbActive();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  if (isProd)
    ErrorWidget.builder = (details) {
      FirebaseAnalytics().logEvent(
        name: 'flutter_component_error',
        parameters: {
          'exception_stack': details.stack.toString(),
          'user_id': SKUser.current?.id ?? 0
        },
      );

      return SafeArea(
        child: Container(
          color: Colors.white,
          child: Text(
            'Sorry, something wen\'t wrong 😔',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: SKColors.dark_gray,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
      );
    };

  SKCacheManager.createCacheDir();
  try {
    Auth.requestNotificationPermissions();
  } catch (e) {}
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class SkollerApp extends StatefulWidget {
  @override
  State createState() => _SkollerAppState();
}

class _SkollerAppState extends State<SkollerApp> {
  bool _darkTheme = false;
  AppState currentState = AppState.loading;
  final key = GlobalKey<NavigatorState>();

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

    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    // );
    DartNotificationCenter.subscribe(
      channel: NotificationChannels.appStateChanged,
      observer: this,
      onNotification: changeAppState,
    );
  }

  @override
  void dispose() {
    super.dispose();

    DartNotificationCenter.unsubscribe(observer: this);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme;

    if (_darkTheme) {
      currentTheme = ThemeData(
        primaryColor: SKColors.skoller_blue1,
        accentColor: SKColors.skoller_blue1,
        backgroundColor: SKColors.dark_gray,
        scaffoldBackgroundColor: SKColors.dark_gray,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.35,
          ),
          bodyText2: TextStyle(
            color: SKColors.skoller_blue,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.35,
          ),
          button: TextStyle(color: Colors.white),
        ),
      );
    } else {
      currentTheme = ThemeData(
        primaryColor: SKColors.skoller_blue1,
        accentColor: SKColors.skoller_blue1,
        backgroundColor: SKColors.background_gray,
        scaffoldBackgroundColor: SKColors.background_gray,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: SKColors.dark_gray,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.35,
          ),
          bodyText2: TextStyle(
            color: SKColors.skoller_blue,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.35,
          ),
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
    }

    return MaterialApp(
      builder: (context, widget) => MediaQuery(
        child: Theme(data: currentTheme, child: widget),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      home: DropdownBanner(
        child: currentWidget,
        navigatorKey: key,
      ),
    );
  }
}
