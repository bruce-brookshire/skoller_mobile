import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class ClassLinkSharingModal extends StatelessWidget {
  final classId;
  final showClassName;

  ClassLinkSharingModal(this.classId, {this.showClassName = false}) : super();

  @override
  Widget build(BuildContext context) {
    StudentClass studentClass = StudentClass.currentClasses[classId];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showClassName) ...[
              Container(
                margin: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                padding: EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SKColors.border_gray, width: 1),
                  ),
                ),
                child: Text(
                  studentClass.name,
                  style:
                      TextStyle(color: studentClass.getColor(), fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Text(
              'Share with classmates',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            if (studentClass.enrollment < 4)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: 'You\'re ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(
                          text:
                              '${4 - studentClass.enrollment} classmate${(4 - studentClass.enrollment) == 1 ? '' : 's'}',
                          style: TextStyle(color: studentClass.getColor())),
                      TextSpan(
                          text: ' away from a ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'PARTY 🎉'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Image.asset(ImageNames.signUpImages.happy_classmates),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Share with classmates'),
                    TextSpan(
                        text: ' to earn points and unlock community features!',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTapUp: (details) {
                Share.share(
                    'School is hard. But this new app called Skoller makes it easy! Our class ${studentClass.name ?? ''} is already in the app. Download so we can keep up together!\n\n${studentClass.enrollmentLink}');
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  'Add classmates',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
