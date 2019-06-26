import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';

class LoadingView extends StatefulWidget {
  @override
  State createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
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
      print(result);
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
        print('failed to load');
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(ImageNames.signUpImages.logo_wide_blue),
            Container(
              margin: EdgeInsets.only(top: 64),
              height: 32,
              width: loading ? 32 : null,
              child: loading
                  ? CircularProgressIndicator()
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
    );
  }
}
