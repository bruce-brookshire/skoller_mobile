import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';

class LoadingView extends StatefulWidget {
  @override
  State createState() => _LoadingState();
}

class _LoadingState extends State<LoadingView> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    attemptLogin();
  }

  void attemptLogin() {
    if (!loading) {
      setState(() {
        loading = true;
      });
    }

    Auth.attemptLogin().then((result) async {
      AppState nextState;
      switch (result) {
        case LogInResponse.success:
          nextState = AppState.main;
          break;
        case LogInResponse.needsVerification:
          final success = await showDialog(
            context: context,
            builder: (context) => PhoneVerificationView(Auth.userPhone),
          );

          if (success is bool && success)
            nextState = AppState.main;
          else
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5, 1],
            colors: [
              SKColors.skoller_blue,
              SKColors.skoller_blue,
              Color(0xFF2966D8),
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
              Container(
                margin: EdgeInsets.only(top: 24, bottom: 48),
                height: 32,
                width: loading ? 32 : null,
                child: loading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : GestureDetector(
                        onTapUp: (details) {
                          attemptLogin();
                        },
                        child: Text(
                          'Failed loading. Tap to retry',
                          style: TextStyle(
                              color: SKColors.warning_red,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
