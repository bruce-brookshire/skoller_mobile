import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:skoller/tools.dart';

class RewardsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final raiseEffort = SKUser.current.student.raiseEffort;
    return SKNavView(
      title: 'My Rewards',
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Flexible(
            child: raiseEffort?.orgId == null
                ? createPoints()
                : createRaiseEffort(raiseEffort)),
      ],
    );
  }

  Widget createRaiseEffort(RaiseEffort raiseEffort) {
    final orgColor =
        raiseEffort.orgName == 'AOII' ? Color(0xFFD73F76) : Color(0xFF822521);
    final raiseDescStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final raiseValStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: orgColor);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: SKColors.border_gray),
          borderRadius: BorderRadius.circular(10),
          boxShadow: UIAssets.boxShadow,
          color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$1 is donated to the ${raiseEffort.orgName == 'AOII' ? 'Arthritis Foundation' : 'ASA Foundation'} every time a classmate signs up through your class links!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
            ),
          ),
          Container(
            width: 144,
            padding: EdgeInsets.only(top: 20),
            child: Image.asset(raiseEffort.orgName == 'AOII'
                ? ImageNames.shareImages.aoii_share_image
                : ImageNames.shareImages.asa_share_image),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('My Raise', style: raiseDescStyle),
                Text(
                    '${NumberUtilities.formatNumberAsDollar(raiseEffort.personalSignups + 1)}',
                    style: raiseValStyle)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('My Chapter', style: raiseDescStyle),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          SKUser.current.student.primarySchool.name,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: SKColors.text_light_gray),
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                    '${NumberUtilities.formatNumberAsDollar(raiseEffort.chapterSignups)}',
                    style: raiseValStyle)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Total Raise', style: raiseDescStyle),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Nationwide',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: SKColors.text_light_gray),
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                    '${NumberUtilities.formatNumberAsDollar(raiseEffort.orgSignups)}',
                    style: raiseValStyle)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              '${NumberUtilities.formatNumberAsDollar(raiseEffort.orgSignups)} raised of \$10,000',
              style: TextStyle(color: orgColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: LinearProgressIndicator(
              value: raiseEffort.orgSignups <= 10000
                  ? raiseEffort.orgSignups / 10000
                  : 1,
              valueColor: AlwaysStoppedAnimation(orgColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget createPoints() => Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            boxShadow: UIAssets.boxShadow),
        child: Column(children: [
          Text(
            'You earn rewards when other \nstudents sign up using your links.',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Image.asset(ImageNames.shareImages.amazon_card_image),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text.rich(
              TextSpan(
                text:
                    '${SKUser.current.student.raiseEffort?.personalSignups ?? 0} students\n',
                children: [
                  TextSpan(
                      text: 'have signed up using your links',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14))
                ],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTapUp: (details) {
              Share.share(
                  'Check out this new app that\'s helping me keep up with school... it\'s like the Waze of the classroom!\n\n${SKUser.current.student.enrollmentLink ?? 'https://itunes.apple.com/us/app/skoller/id1314782490?mt=8'}');
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SKColors.skoller_blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Tap to share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Text(
            'A Skoller employee will email you when you qualify!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: SKColors.text_light_gray),
          ),
        ]),
      );
}
