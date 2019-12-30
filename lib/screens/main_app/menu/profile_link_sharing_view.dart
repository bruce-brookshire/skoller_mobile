import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class ProfileLinkSharingView extends StatefulWidget {
  final int startingClassId;

  ProfileLinkSharingView([this.startingClassId]);

  @override
  State createState() => _ProfileLinkSharingState();
}

enum _SharingType { classmates, anyone }

class _ProfileLinkSharingState extends State<ProfileLinkSharingView> {
  var sharingType = _SharingType.classmates;

  StudentClass studentClass;

  @override
  void initState() {
    super.initState();

    if (widget.startingClassId != null) {
      studentClass = StudentClass.currentClasses[widget.startingClassId];
      sharingType = _SharingType.classmates;
    }
  }

  void tappedShare(_) {
    final shareMessage = sharingType == _SharingType.anyone
        ? 'Check out this new app that\'s helping me keep up with school... it\'s like the Waze of the classroom!\n\n${SKUser.current.student.enrollmentLink ?? 'https://itunes.apple.com/us/app/skoller/id1314782490?mt=8'}'
        : studentClass.shareMessage;

    Share.share(shareMessage);
  }

  @override
  Widget build(BuildContext context) {
    final classes = StudentClass.currentClasses.values.toList();
    final linkStripper = (String link) => link.split('//')[1];

    final raiseEffort = SKUser.current.student.raiseEffort;

    return SafeArea(
      child: Column(
        children: [
          Flexible(
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
                                child:
                                    Image.asset(ImageNames.navArrowImages.down),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Share Skoller',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
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
                                                index == 0
                                                    ? _SharingType.anyone
                                                    : _SharingType.classmates);
                                          },
                                        ),
                                      );
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'with ${sharingType == _SharingType.anyone ? 'anyone' : 'classmates'}',
                                            style: TextStyle(
                                                color: SKColors.skoller_blue,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 4, top: 1),
                                            child: Image.asset(ImageNames
                                                .navArrowImages.dropdown_blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 32),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 24),
                          child: raiseEffort?.orgId == null
                              ? Text.rich(
                                  TextSpan(
                                    text: 'Get ',
                                    children: [
                                      TextSpan(
                                        text: '5 classmates',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                          text:
                                              ' on Skoller and earn a \$10 Gift Card!')
                                    ],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Text.rich(
                                  TextSpan(
                                    text: '',
                                    children: [
                                      TextSpan(
                                        text: 'Raise THOUSANDS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                          text:
                                              ' by sharing\n with any student!')
                                    ],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: buildShareImage(),
                          ),
                        ),
                        if (raiseEffort?.orgId != null)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text.rich(
                              TextSpan(
                                text: 'You\'ve raised ',
                                children: [
                                  TextSpan(
                                      text: '\$${raiseEffort.orgSignups}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          ' for the ${raiseEffort.orgName == 'AOII' ? 'Arthritis Foundation' : 'ASA Foundation'}!')
                                ],
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (sharingType == _SharingType.classmates)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: GestureDetector(
                              onTapUp: (detail) {
                                showDialog(
                                  context: context,
                                  builder: (context) => SKPickerModal(
                                    title: 'Select class',
                                    subtitle:
                                        'Let your classmates use your class specific link to enroll',
                                    items: classes
                                        .map(
                                            (studentClass) => studentClass.name)
                                        .toList(),
                                    onSelect: (index) {
                                      setState(
                                          () => studentClass = classes[index]);
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: SKColors.skoller_blue),
                                ),
                                child: Text(
                                  studentClass == null
                                      ? 'Select class...'
                                      : studentClass.name,
                                  style:
                                      TextStyle(color: SKColors.skoller_blue),
                                ),
                              ),
                            ),
                          ),
                        if (sharingType == _SharingType.anyone ||
                            studentClass != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: GestureDetector(
                              onTapUp: tappedShare,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: sharingType == _SharingType.anyone
                                      ? SKColors.skoller_blue
                                      : studentClass.getColor(),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: UIAssets.boxShadow,
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Image.asset(
                                          ImageNames.peopleImages.people_white),
                                    ),
                                    Text(
                                      linkStripper(
                                        sharingType == _SharingType.anyone
                                            ? SKUser
                                                .current.student.enrollmentLink
                                            : studentClass.enrollmentLink,
                                      ),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Text(
                            raiseEffort?.orgId == null
                                ? '5 new signups = \$10 Gift Card. Signups must come from your link. Offer ends 2/14/20'
                                : '1 new sign up  = \$1 raised. Sign ups must come from your links to count towards the donation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: SKColors.text_light_gray,
                                fontWeight: FontWeight.normal,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Image buildShareImage() {
    final orgName = SKUser.current.student.raiseEffort?.orgName;

    if (orgName == 'AOII')
      return Image.asset(ImageNames.shareImages.aoii_share_image);
    else if (orgName == 'Alpha Sigma Alpha')
      return Image.asset(ImageNames.shareImages.asa_share_image);
    else
      return Image.asset(ImageNames.shareImages.amazon_card_image);
  }
}
