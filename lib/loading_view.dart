import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

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
              Container(
                margin: EdgeInsets.fromLTRB(12, 24, 12, 48),
                width: loading ? 32 : null,
                height: loading ? 32 : null,
                child: loading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : GestureDetector(
                        onTapUp: (details) async {
                          if (isValidVersion)
                            attemptLogin();
                          else {
                            final url = 'appstore.com/skoller';

                            if (await canLaunch(url)) launch(url);
                          }
                        },
                        child: Text(
                          isValidVersion
                              ? 'Failed loading. Tap to retry'
                              : 'We have improvements that require an update. Tap here to do so!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
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
