import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/auth/phone_verification_view.dart';
import 'package:skoller/tools.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sign_in.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final phoneFocus = FocusNode();

  bool validState = false;

  @override
  void dispose() {
    [
      firstNameController,
      lastNameController,
      phoneController,
      firstNameFocus,
      lastNameFocus,
      phoneFocus,
    ].forEach((obj) => (obj as dynamic).dispose());

    super.dispose();
  }

  void verifyState(String _) {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    final isValid =
        firstName.length > 0 && lastName.length > 0 && phone.length == 14;

    if (isValid != validState) {
      setState(() => validState = isValid);
    }
  }

  void tappedSignUp(TapUpDetails details) {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    final loadingScreen = SKLoadingScreen.fadeIn(context);

    Auth.createUser(
      nameFirst: firstName,
      nameLast: lastName,
      phone: phone.replaceAll(RegExp(r'[\(\) \-]+'), ''),
    ).then((response) async {
      loadingScreen.fadeOut();

      if (response.wasSuccessful()) {
        final result = await showDialog(
          context: context,
          builder: (context) => PhoneVerificationView(phone),
        );

        if (result == null) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => SignIn()),
          );
        } else if (result is bool && result) {
          Session.startSession();

          Navigator.popUntil(context, (route) => route.isFirst);

          DartNotificationCenter.post(
            channel: NotificationChannels.appStateChanged,
            options: AppState.main,
          );
        } else {
          setState(() => validState = false);
          DropdownBanner.showBanner(
            text: 'Failed to authenticate',
            color: SKColors.warning_red,
            textStyle: TextStyle(color: Colors.white),
          );
        }
      } else {
        setState(() => validState = false);

        String message = [422, 401].contains(response.status)
            ? 'A user already exists with that phone number. Try logging in!'
            : 'Failed to create account. Try again later, or visit skoller.co';

        DropdownBanner.showBanner(
          text: message,
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  double? dist;

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: (details) =>
                    dist = details.localPosition.dy,
                onVerticalDragCancel: () => dist = null,
                onVerticalDragEnd: (details) => dist = null,
                onVerticalDragUpdate: (details) {
                  if (dist != null && details.localPosition.dy - dist! > 30) {
                    [
                      firstNameFocus,
                      lastNameFocus,
                      phoneFocus,
                    ].forEach((node) => node.hasFocus ? node.unfocus() : null);

                    dist = null;
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Spacer(
                      flex: 2,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('Sign up', style: TextStyle(fontSize: 28)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              '(its free!)',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: SKColors.light_gray),
                            ),
                          ),
                          Spacer(
                            flex: 2,
                          ),
                          Image.asset(ImageNames.signUpImages.activities),
                          Spacer(
                            flex: 5,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) => firstNameFocus.requestFocus(),
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: 4, bottom: 6, top: 24, left: 24),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: SKColors.border_gray),
                                boxShadow: UIAssets.boxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'First name',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  CupertinoTextField(
                                    padding: EdgeInsets.all(1),
                                    controller: firstNameController,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: SKColors.dark_gray),
                                    decoration: BoxDecoration(border: null),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) {
                                      lastNameFocus.requestFocus();
                                      // firstNameFocus.nextFocus();
                                    },
                                    autofocus: true,
                                    onChanged: verifyState,
                                    focusNode: firstNameFocus,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) => lastNameFocus.requestFocus(),
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 4, bottom: 6, top: 24, right: 24),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: SKColors.border_gray),
                                boxShadow: UIAssets.boxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Last name',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  CupertinoTextField(
                                    padding: EdgeInsets.all(1),
                                    controller: lastNameController,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: SKColors.dark_gray),
                                    decoration: BoxDecoration(border: null),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) {
                                      phoneFocus.requestFocus();
                                      // return lastNameFocus.nextFocus();
                                    },
                                    onChanged: verifyState,
                                    focusNode: lastNameFocus,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTapUp: (details) => phoneFocus.requestFocus(),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: SKColors.border_gray),
                          boxShadow: UIAssets.boxShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Phone',
                              style: TextStyle(
                                  color: SKColors.skoller_blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal),
                            ),
                            CupertinoTextField(
                              padding: EdgeInsets.all(1),
                              controller: phoneController,
                              inputFormatters: [USNumberTextInputFormatter()],
                              style: TextStyle(
                                  fontSize: 15, color: SKColors.dark_gray),
                              decoration: BoxDecoration(border: null),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => phoneFocus.unfocus(),
                              onChanged: verifyState,
                              focusNode: phoneFocus,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: GestureDetector(
                        onTapUp: (details) async {
                          final url = 'https://skoller.co/useragreement';

                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'By signing up you agree to our ',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: SKColors.light_gray),
                            children: [
                              TextSpan(
                                  text: 'User Agreement',
                                  style:
                                      TextStyle(color: SKColors.skoller_blue1))
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                    validState
                        ? GestureDetector(
                            onTapUp: tappedSignUp,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              alignment: Alignment.center,
                              color: SKColors.skoller_blue1,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Sign up',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(color: Colors.white),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(color: SKColors.dark_gray),
                                ),
                                GestureDetector(
                                  onTapUp: (details) {
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => SignIn(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    ' Log In',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue1,
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
