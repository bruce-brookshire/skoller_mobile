import 'package:flutter/material.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';
import '../main_app/tab_bar.dart';

class SignIn extends StatefulWidget {
  final AppStateCallback appStateCallback;

  SignIn(this.appStateCallback, {Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  tappedLogIn(BuildContext context) {
    Auth.logIn('bruce@skoller.co', 'password1').then((success) {
      if (success) {
        return StudentClass.getStudentClasses();
      } else {
        print('FAILURE');
      }
    }).then((response) {
      if (response.wasSuccessful()) {
        Navigator.pop(context);
        widget.appStateCallback(AppState.mainApp);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
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
