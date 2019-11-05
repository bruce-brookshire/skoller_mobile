import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:skoller/tools.dart';

class MyPointsView extends StatelessWidget {
  void tappedWhatArePoints(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.only(left: 12, right: 12, top: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: SKColors.border_gray),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Points are rewards!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Text(
                    'You can get them when someone:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Signs up with your link (100 pts)',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'Enrolls in a class with your link (100 pts)',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 12),
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: SKColors.alert_orange,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Partyin\' 🎉',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                '1,000 pts.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(
                            'Your choice of: ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'A Skoller sticker or a Skoller coozie',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: SKColors.skoller_blue,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ballin\' 😎',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                '10,000 pts.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(
                            'Partyin\' + your choice of: ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'A Skoller t-shirt or a \$25 gift card',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: SKColors.success,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Flexin\' 💪',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                '25,000 pts.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(
                            'Ballin\' + your choice of: ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'A Skoller backpack and t-shirt or a \$50 gift card',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Skoller Points',
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
            boxShadow: UIAssets.boxShadow,
          ),
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  'You have ${SKUser.current.student.points} points',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(ImageNames.signUpImages.happy_classmates),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 44),
                child: Text.rich(
                  TextSpan(
                    text: 'Earn points',
                    children: [
                      TextSpan(
                          text: ' for getting students to ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'sign up'),
                      TextSpan(
                          text: ' or ',
                          style: TextStyle(fontWeight: FontWeight.normal)),
                      TextSpan(text: 'join your classes'),
                      TextSpan(text: ' using your personal link below! '),
                    ],
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
                  margin: EdgeInsets.symmetric(horizontal: 44, vertical: 12),
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
            ],
          ),
        ),
        GestureDetector(
          onTapUp: (details) => tappedWhatArePoints(context),
          child: Container(
            margin: EdgeInsets.only(top: 12),
            child: Text(
              'What are Skoller points?',
              style: TextStyle(
                  color: SKColors.skoller_blue, fontWeight: FontWeight.normal),
            ),
          ),
        )
      ],
    );
  }
}
