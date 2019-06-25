import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(flex: 2,),
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
                        child: Container(
                          margin: EdgeInsets.only(
                              right: 4, bottom: 6, top: 24, left: 24),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: SKColors.border_gray),
                            boxShadow: [UIAssets.boxShadow],
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
                                style: TextStyle(
                                    fontSize: 15, color: SKColors.dark_gray),
                                decoration: BoxDecoration(border: null),
                                // controller: firstNameController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 4, bottom: 6, top: 24, right: 24),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: SKColors.border_gray),
                            boxShadow: [UIAssets.boxShadow],
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
                                style: TextStyle(
                                    fontSize: 15, color: SKColors.dark_gray),
                                decoration: BoxDecoration(border: null),
                                // controller: firstNameController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Email',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          padding: EdgeInsets.all(1),
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholder: 'School email recommended',
                          placeholderStyle: TextStyle(
                              fontSize: 14, color: SKColors.text_light_gray),
                          decoration: BoxDecoration(border: null),
                          // controller: firstNameController,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
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
                          inputFormatters: [USNumberTextInputFormatter()],
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          decoration: BoxDecoration(border: null),
                          // controller: firstNameController,
                        ),
                      ],
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
                                style: TextStyle(color: SKColors.skoller_blue))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 3,),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: SKColors.dark_gray),
                        ),
                        Text(
                          ' Log In',
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
      );
}
