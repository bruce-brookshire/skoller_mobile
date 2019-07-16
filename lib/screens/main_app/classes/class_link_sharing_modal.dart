import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class ClassLinkSharingModal extends StatelessWidget {
  final classId;

  ClassLinkSharingModal(this.classId) : super();

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
                  Text(
                    'Share with classmates',
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
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
                                  '${5 - studentClass.enrollment} classmate${(5 - studentClass.enrollment) == 1 ? '' : 's'}',
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
                    child:
                        Image.asset(ImageNames.signUpImages.happy_classmates),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Share with classmates'),
                          TextSpan(
                              text: ' to earn points!',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTapUp: (details) {
                      Share.share(
                          'School is hard. But this new app called Skoller makes it easy! Our class \(studentClass.name ?? "") is already in the app. Download so we can keep up together!\n\n${studentClass.enrollmentLink}');
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
