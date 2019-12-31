import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'dart:io';

class LoadingView extends StatefulWidget {
  @override
  State createState() => _LoadingState();
}

class _LoadingState extends State<LoadingView> {
  bool loading = false;
  bool validVersion;

  @override
  void initState() {
    super.initState();

    attemptLogin();
  }

  void attemptLogin() async {
    if (!loading) {
      setState(() {
        loading = true;
      });
    }

    final versionValid = await Auth.enforceMinVersion();
    validVersion = versionValid;

    if (!versionValid)
      setState(() => loading = false);
    else {
      final result = await Auth.attemptLogin();
      AppState nextState;
      switch (result) {
        case LogInResponse.success:
          nextState = AppState.main;
          Session.startSession();
          break;
        case LogInResponse.needsVerification:
          final success = await showDialog(
            context: context,
            builder: (context) => PhoneVerificationView(Auth.userPhone),
          );

          if (success is bool && success) {
            nextState = AppState.main;
            Session.startSession();
          } else
            nextState = AppState.auth;

          break;
        case LogInResponse.failed:
          nextState = AppState.auth;
          break;
        case LogInResponse.internetError:
          break;
      }

      if (nextState != null) {
        if (nextState == AppState.main) {
          final classResult = await StudentClass.getStudentClasses();
          SKUser.current.getJobProfile();

          if (!classResult.wasSuccessful()) {
            return;
          }
        }
        DartNotificationCenter.post(
            channel: NotificationChannels.appStateChanged, options: nextState);
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to log in. Tap to try again',
          duration: Duration(days: 1),
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
          tapCallback: () => attemptLogin(),
        );
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValidVersion = validVersion is bool && validVersion;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.35, 0.55, 1],
            colors: [
              Color(0xFF98D2EB),
              SKColors.skoller_blue,
              Color(0xFF27A9D9),
              Color(0xFF0F7599),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Image.asset(ImageNames.signUpImages.logo_wide_white),
              ),
              if (loading) createLoadingIndicator(),
              if (!loading && isValidVersion) createRetryPrompt(),
              if (!loading && !isValidVersion) ...createUpdatePrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget createLoadingIndicator() => Padding(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 48),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      );

  Widget createRetryPrompt() => Padding(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 48),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => attemptLogin(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray),
              boxShadow: UIAssets.boxShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.settings_backup_restore,
                    color: SKColors.warning_red,
                  ),
                ),
                Text(
                  'Failed to load. Tap to retry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SKColors.warning_red,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> createUpdatePrompt() => [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
          child: Text(
            'We have improvements that require an upgrade!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (_) async {
            final appleUrl = 'appstore.com/skoller';
            if (Platform.isIOS && await canLaunch(appleUrl))
              launch(appleUrl);
            else
              DropdownBanner.showBanner(
                text:
                    'Unable to open the ${Platform.isIOS ? 'App' : 'Google Play'} Store. Please manually update the app.',
                color: SKColors.alert_orange,
                textStyle: TextStyle(color: Colors.white),
              );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray),
              boxShadow: UIAssets.boxShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.cloud_download,
                        color: SKColors.skoller_blue)),
                Text('Update', style: TextStyle(color: SKColors.skoller_blue)),
              ],
            ),
          ),
        ),
      ];
}
