import 'package:flutter/material.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';

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
                    Container(
                      child: RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 48, vertical: 10),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: SKColors.skoller_blue),
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ),
      );
}
