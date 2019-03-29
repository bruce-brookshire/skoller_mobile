import 'package:flutter/material.dart';
import 'requests/requests_core.dart';
import 'constants/constants.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: SKColors.background_gray),
        padding: EdgeInsets.symmetric(horizontal: 64.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage(ImageNames.signUpImages.happy_classmates),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 64, 0, 4),
                  child: Material(
                    type: MaterialType.card,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: TextField(
                        decoration:
                            InputDecoration.collapsed(hintText: 'email'),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: Material(
                    type: MaterialType.card,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: TextField(
                        obscureText: true,
                        decoration:
                            InputDecoration.collapsed(hintText: 'password'),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                  child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      'hi',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SKColors.skoller_blue),
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
                  child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      'hi',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SKColors.skoller_blue),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
