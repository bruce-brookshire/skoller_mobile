import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class JobsTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;
  final bool showSammi;

  JobsTutorialView(this.onTapDismiss, this.promptMsg, {this.showSammi = true});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Jobs',
          isPop: false,
          leftBtn: SKHeaderProfilePhoto(),
          children: [
            SizedBox(height: 80, child: null),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: SKHeaderCard(
                  leftHeaderItem: Text(
                    'Create Profile',
                    style: TextStyle(fontSize: 17),
                  ),
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            'May 2020',
                            style: TextStyle(color: SKColors.jobs_dark_green),
                          ),
                          Image.asset(ImageNames.navArrowImages.dropdown_green)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                          Expanded(
                            child: Text(
                              'Computer Science',
                              style: TextStyle(color: SKColors.jobs_dark_green),
                            ),
                          ),
                          Image.asset(
                              ImageNames.rightNavImages.magnifying_glass_green)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                            SKUser.current?.student.degreeType?.name ??
                                'Economics',
                            style: TextStyle(color: SKColors.jobs_dark_green),
                          ),
                          Image.asset(ImageNames.navArrowImages.dropdown_green)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                            'Full time',
                            style: TextStyle(color: SKColors.jobs_dark_green),
                          ),
                          Image.asset(ImageNames.navArrowImages.dropdown_green)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: SKColors.jobs_light_green,
                        boxShadow: UIAssets.boxShadow,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(color: Colors.black.withOpacity(0.5)),
        Align(
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTapUp: (_) => DartNotificationCenter.post(
                      channel: NotificationChannels.selectTab,
                      options: 2,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                          color: SKColors.skoller_blue),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTapUp: (details) => onTapDismiss(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              margin: EdgeInsets.only(bottom: 48),
              decoration: BoxDecoration(
                color: SKColors.skoller_blue,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  promptMsg,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 48),
                    child: SammiSpeechBubble(
                      sammiPersonality: SammiPersonality.jobsCool,
                      speechBubbleContents: Text.rich(
                        TextSpan(text: 'Jobs', children: [
                          TextSpan(
                              text:
                                  ' helps you transition from the classroom to your dream job!',
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
