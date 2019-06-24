import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final phoneNumberController = TextEditingController();

  void tappedLogIn(BuildContext context) {
    Auth.requestLogin("9032452355").then((success) async {
      if (success) {
        final bool result = await showDialog(
            context: context, builder: (context) => PhoneVerificationView());
        print(result);
        if (result is bool) {
          if (result) {
            Navigator.popUntil(context, (route) => route.isFirst);

            DartNotificationCenter.post(
              channel: NotificationChannels.appStateChanged,
              options: AppState.mainApp,
            );
          } else {
            throw 'Verification was unsuccessful. Try again';
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: SafeArea(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Image(
                      image: AssetImage(ImageNames.signUpImages.logo_wide_blue),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(64, 24, 64, 18),
                      child: Material(
                        type: MaterialType.card,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: TextField(
                            decoration:
                                InputDecoration.collapsed(hintText: 'email'),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(64, 0, 64, 18),
                      child: Material(
                        type: MaterialType.card,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          margin: EdgeInsets.all(4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: TextField(
                            obscureText: true,
                            decoration:
                                InputDecoration.collapsed(hintText: 'password'),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    SKButton(
                      buttonText: 'Log in',
                      width: 180,
                      callback: tappedLogIn,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Don\'t have an account yet?',
                            style: TextStyle(color: SKColors.dark_gray),
                          ),
                          Text(
                            ' Sign Up',
                            style: TextStyle(
                                color: SKColors.skoller_blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
