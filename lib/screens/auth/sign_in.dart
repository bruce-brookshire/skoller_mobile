import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';
import 'package:flutter/services.dart';
import 'package:skoller/screens/auth/sign_up.dart';
import '../../requests/requests_core.dart';
import 'package:skoller/tools.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final phoneNumberController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    phoneNumberController.dispose();
  }

  void tappedLogIn(BuildContext context) async {
    final trimStr =
        phoneNumberController.text.replaceAll(RegExp(r'[\(\) \-]+'), '');
    if (trimStr.length != 10) {
      DropdownBanner.showBanner(
          text: 'Please enter a valid US phone number',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white));

      return;
    }

    final loader = SKLoadingScreen.fadeIn(context);

    final status = await Auth.requestLogin(trimStr);

    loader.fadeOut();

    if ([200, 204].contains(status)) {
      final bool result = await showDialog(
        context: context,
        builder: (context) => PhoneVerificationView(phoneNumberController.text),
      );

      if (result is bool && result) {
        await StudentClass.getStudentClasses();

        Navigator.popUntil(context, (route) => route.isFirst);
        DartNotificationCenter.post(
          channel: NotificationChannels.appStateChanged,
          options: AppState.main,
        );
      }
    } else if (status == 404) {
      DropdownBanner.showBanner(
          text: 'User does not exist. Tap to sign up!',
          color: SKColors.warning_red,
          tapCallback: () => tappedSignUp(null),
          textStyle: TextStyle(color: Colors.white));
    } else
      DropdownBanner.showBanner(
          text: 'Failed to log in',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white));
  }

  void tappedSignUp(TapUpDetails details) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => SignUp(),
      ),
    );
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
                      margin: EdgeInsets.only(top: 24, bottom: 16),
                      width: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: SKColors.border_gray),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: UIAssets.boxShadow,
                      ),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        child: CupertinoTextField(
                          controller: phoneNumberController,
                          decoration: BoxDecoration(border: null),
                          placeholder: 'e.g. (800) 555-5555',
                          style: TextStyle(fontSize: 14),
                          placeholderStyle: TextStyle(
                              fontSize: 14, color: SKColors.text_light_gray),
                          inputFormatters: [USNumberTextInputFormatter()],
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                        ),
                      ),
                    ),
                    SKButton(
                      buttonText: 'Log in',
                      width: 240,
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
                          GestureDetector(
                            onTapUp: tappedSignUp,
                            child: Text(
                              ' Sign Up',
                              style: TextStyle(
                                  color: SKColors.skoller_blue,
                                  fontWeight: FontWeight.bold),
                            ),
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
