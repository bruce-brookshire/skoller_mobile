import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'sign_in.dart';
import 'sign_up.dart';

class AuthHome extends StatelessWidget {
  tappedLogIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  tappedSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(ImageNames.signUpImages.logo_wide_blue),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Keep up with classes, together!',
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),
                  Image(
                    image: AssetImage(ImageNames.signUpImages.happy_classmates),
                  ),
                  SKButton(
                    margin: EdgeInsets.only(top: 16, bottom: 8),
                    width: 180,
                    callback: tappedSignUp,
                    buttonText: 'Sign up',
                  ),
                  SKButton(
                    margin: EdgeInsets.only(top: 8, bottom: 24),
                    width: 180,
                    callback: tappedLogIn,
                    buttonText: 'Log in',
                  ),
                  CircularProgressIndicator()
                ],
              ),
            ),
          ),
        ),
      );
}
