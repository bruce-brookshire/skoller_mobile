import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class AlreadyPremiumView extends StatefulWidget {
  @override
  State createState() => _AlreadyPremiumViewState();
}

class _AlreadyPremiumViewState extends State<AlreadyPremiumView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (_) => Navigator.pop(context),
                          child: SizedBox(
                            width: 32,
                            height: 24,
                            child: Image.asset(ImageNames.navArrowImages.down),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'You are a Premium user!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Login on desktop at Skoller.co to\nmanage your account settings.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
