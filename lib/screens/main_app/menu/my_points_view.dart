import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class MyPointsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Skoller Points',
      isDown: true,
      isBack: false,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [UIAssets.boxShadow],
          ),
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You have ${100} points',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(ImageNames.signUpImages.happy_classmates),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 44),
                child: Text.rich(
                  TextSpan(
                    text: 'Earn points',
                    children: [
                      TextSpan(
                          text: ' for getting students to ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'sign up'),
                      TextSpan(
                          text: ' or ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: ' join your classes '),
                      TextSpan(text: ' using your personal link below! '),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                decoration: BoxDecoration(
                  color: SKColors.skoller_blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Tap to share',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTapUp: (details) {},
          child: Container(
            margin: EdgeInsets.only(top: 16),
            child: Text(
              'What are Skoller points?',
              style: TextStyle(color: SKColors.skoller_blue),
            ),
          ),
        )
      ],
    );
  }
}
