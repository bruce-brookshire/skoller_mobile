import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SkollerJobsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.only(bottom: 24),
                        alignment: Alignment.centerLeft,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 8, bottom: 8),
                            child: Image.asset(ImageNames.sammiImages.cool),
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'Skoller',
                              children: [
                                TextSpan(
                                  text: 'Jobs',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                              style: TextStyle(
                                  fontSize: 32, color: SKColors.skoller_blue),
                            ),
                          ),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'From the classroom to your ',
                          children: [
                            TextSpan(
                              text: 'dream job',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
              Spacer(),
              Text(
                'Let us help you find your dream job in under 5 minutes!\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Skoller wants to make the transition from graduation to a meaningful career as easy as possible by connecting you with the right employers.\n\nAnswer a few short questions, and you\'ll be on the way to a job you love!',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              GestureDetector(
                onTapUp: (details) async {
                  final url = 'https://airtable.com/shrciIOPyDKX39DV1';

                  if (await canLaunch(url)) {
                    launch(url);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: SKColors.skoller_blue,
                      boxShadow: [UIAssets.boxShadow]),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  margin: EdgeInsets.only(top: 24),
                  child: Text(
                    'Get started',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
