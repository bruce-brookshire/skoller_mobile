import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class JobsView extends StatefulWidget {
  State createState() => _JobsViewState();
}

enum _ProfileState { intro, start, resume, profile }

class _JobsViewState extends State<JobsView> {
  _ProfileState profileState;

  @override
  void initState() {
    super.initState();

    if (JobProfile.currentProfile == null) profileState = _ProfileState.intro;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    switch (profileState) {
      case _ProfileState.intro:
        children = createIntro();
        break;
      case _ProfileState.start:
        children = createStart();
        break;
      case _ProfileState.resume:
        children = createIntro();
        break;
      case _ProfileState.profile:
        children = createIntro();
        break;
    }

    return SKNavView(
      title: 'Jobs',
      isPop: false,
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      children: children,
    );
  }

  List<Widget> createIntro() => [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SKColors.border_gray),
                color: Colors.white,
                boxShadow: UIAssets.boxShadow),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(ImageNames.sammiImages.big_smile),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'Use your progress in Skoller to help you land the',
                      children: [
                        TextSpan(
                          text: ' job you love!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Image.asset(ImageNames.jobsImages.jobs_cover_art),
                ),
                GestureDetector(
                  onTapUp: (_) =>
                      setState(() => profileState = _ProfileState.start),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: EdgeInsets.only(top: 24),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: SKColors.jobs_dark_green,
                      boxShadow: UIAssets.boxShadow,
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

  List<Widget> createStart() => [
        Padding(
          padding: EdgeInsets.all(16),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.cool,
            speechBubbleContents: Text(
              'So what\'s the plan post grad?',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        // Flexible(
        //   fit: FlexFit.tight,
        //   child:
        SKHeaderCard(
          leftHeaderItem: Text(
            'Start',
            style: TextStyle(fontSize: 17),
          ),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: EdgeInsets.all(24),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                'Graduation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: SKColors.light_gray,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.jobs_dark_green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Month',
                          style: TextStyle(color: SKColors.jobs_dark_green),
                        ),
                        Image.asset(ImageNames.navArrowImages.dropdown_blue)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(6),
                    margin: EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.jobs_dark_green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Padding(
                        // padding: EdgeInsets.only(right: 24),
                        // child:
                        Text(
                          'Year',
                          style: TextStyle(color: SKColors.jobs_dark_green),
                        ),
                        // ),
                        Image.asset(ImageNames.navArrowImages.dropdown_blue)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
              child: Text(
                'Major(s)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: SKColors.light_gray,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: SKColors.jobs_dark_green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add majors',
                    style: TextStyle(color: SKColors.jobs_dark_green),
                  ),
                  Image.asset(ImageNames.rightNavImages.magnifying_glass)
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
              child: Text(
                'Pursuing degree',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: SKColors.light_gray,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: SKColors.jobs_dark_green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select...',
                    style: TextStyle(color: SKColors.jobs_dark_green),
                  ),
                  Image.asset(ImageNames.navArrowImages.dropdown_blue)
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
              child: Text(
                'Your next job',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: SKColors.light_gray,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: SKColors.jobs_dark_green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select...',
                    style: TextStyle(color: SKColors.jobs_dark_green),
                  ),
                  Image.asset(ImageNames.navArrowImages.dropdown_blue)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 24),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: SKColors.jobs_dark_green,
                boxShadow: UIAssets.boxShadow,
              ),
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        // ),
      ];
}
