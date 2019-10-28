import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class ProfileLinkSharingView extends StatefulWidget {
  @override
  State createState() => _ProfileLinkSharingState();
}

enum _SharingType { classmates, anyone }

class _ProfileLinkSharingState extends State<ProfileLinkSharingView> {
  _SharingType sharingType;

  StudentClass studentClass;

  @override
  Widget build(BuildContext context) {
    final classes = StudentClass.currentClasses.values.toList();

    final shareTypeColor =
        sharingType != null && sharingType == _SharingType.classmates
            ? SKColors.light_gray
            : SKColors.skoller_blue;

    List<Widget> shareChildren = [
      Padding(
        padding: EdgeInsets.only(top: 16, bottom: 4, left: 20),
        child: Text(
          'Share Skoller with:',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          textAlign: TextAlign.start,
        ),
      ),
      GestureDetector(
        onTapUp: (detail) {
          showDialog(
            context: context,
            builder: (context) => SKPickerModal(
              title: 'Share type',
              subtitle:
                  'Do you want to share Skoller with anyone or a class enroll link for classmates?',
              items: ['Anyone', 'Classmates'],
              onSelect: (index) {
                setState(() => sharingType =
                    index == 0 ? _SharingType.anyone : _SharingType.classmates);
              },
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: shareTypeColor,
            ),
            color: Colors.white,
            boxShadow: [UIAssets.boxShadow],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            sharingType == null
                ? 'Select...'
                : (sharingType == _SharingType.anyone
                    ? 'Anyone'
                    : 'Classmates'),
            style: TextStyle(color: shareTypeColor),
          ),
        ),
      ),
    ];

    if (sharingType == _SharingType.classmates) {
      shareChildren.addAll(
        [
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 4, left: 20),
            child: Text(
              'Which class?',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              textAlign: TextAlign.start,
            ),
          ),
          GestureDetector(
            onTapUp: (detail) {
              showDialog(
                context: context,
                builder: (context) => SKPickerModal(
                  title: 'Select class',
                  subtitle:
                      'Let your classmates use your class specific link to enroll',
                  items:
                      classes.map((studentClass) => studentClass.name).toList(),
                  onSelect: (index) {
                    setState(() => studentClass = classes[index]);
                  },
                ),
              );
            },
            child: Container(
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
                studentClass == null ? 'Select...' : studentClass.name,
                style: TextStyle(color: SKColors.skoller_blue),
              ),
            ),
          ),
        ],
      );
    }

    if (sharingType != null && (sharingType == _SharingType.anyone) ||
        (sharingType == _SharingType.classmates && studentClass != null)) {
      shareChildren.addAll(
        [
          Spacer(),
          GestureDetector(
            onTapUp: (details) => Share.share(sharingType == _SharingType.anyone
                ? 'Check out this new app that\'s helping me keep up with school... it\'s like the Waze of the classroom!\n\n${SKUser.current.student.enrollmentLink ?? 'https://itunes.apple.com/us/app/skoller/id1314782490?mt=8'}'
                : studentClass.shareMessage),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: SKColors.skoller_blue,
                boxShadow: [
                  UIAssets.boxShadow,
                ],
              ),
              child: Text(
                'Share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

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
                padding: EdgeInsets.symmetric(vertical: 12),
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
              ...shareChildren,
            ],
          ),
        ),
      ),
    );
  }
}
