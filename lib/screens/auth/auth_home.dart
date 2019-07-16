import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/constants.dart';
import 'sign_in.dart';
import 'sign_up.dart';

class AuthHome extends StatelessWidget {
  void tappedLogIn(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SignIn()),
    );
  }

  void tappedSignUp(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    'One syllabus, endless opportunity',
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Image(
                      image: AssetImage(
                          ImageNames.signUpImages.syllabus_activity)),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
