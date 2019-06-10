import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class ProfileLinkSharingView extends StatefulWidget {
  @override
  State createState() => _ProfileLinkSharingViewState();
}

class _ProfileLinkSharingViewState extends State<ProfileLinkSharingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTapUp: (details) => Navigator.pop(context),
                    child: Container(
                      height: 32,
                      width: 32,
                      child: Image.asset(ImageNames.navArrowImages.down),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Grow YOUR community',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              // Padding(padding: EdgeInsets.symmetric(horizontal: 40),)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 56, vertical: 24),
                child: Text.rich(
                  TextSpan(
                    text:
                        'Just get one of your classmates to join Skoller and be entered to win a ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                        text: '\$50 Amazon gift card!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Image.asset(ImageNames.signUpImages.happy_classmates),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 4, left: 20),
                child: Text(
                  'Share Skoller with:',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SKColors.skoller_blue,
                  ),
                  color: Colors.white,
                  boxShadow: [UIAssets.boxShadow],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Select...',
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
