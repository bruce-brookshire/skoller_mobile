import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class SKCreateClassModal extends StatefulWidget {
  @override
  State createState() => _SKCreateClassModalState();
}

class _SKCreateClassModalState extends State<SKCreateClassModal> {
  final controller = PageController(initialPage: 0);

  Map<String, bool> selectedDays = {
    'Sun': false,
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
  };

  @override
  Widget build(BuildContext context) {
    // controller.animateToPage(page)x
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        height: 360,
        child: PageView(
          controller: controller,
          children: <Widget>[
            createViewOne(),
            createViewTwo(),
            createViewThree(),
          ],
        ),
      ),
    );
  }

  Widget createViewOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.smile,
            speechBubbleContents: Text.rich(
              TextSpan(text: 'Create your class ', children: [
                TextSpan(
                    text: 'with 3 easy steps',
                    style: TextStyle(fontWeight: FontWeight.normal)),
              ]),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          // margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Class name',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                placeholder: '',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                // controller: lastNameController,
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(12, 4, 4, 4),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.border_gray),
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Subject',
                      style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                    CupertinoTextField(
                      padding: EdgeInsets.all(0),
                      placeholder: '',
                      style: TextStyle(fontSize: 15),
                      decoration: BoxDecoration(border: null),
                      // controller: lastNameController,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.border_gray),
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Code',
                      style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                    CupertinoTextField(
                      padding: EdgeInsets.all(0),
                      placeholder: '',
                      style: TextStyle(fontSize: 15),
                      decoration: BoxDecoration(border: null),
                      // controller: lastNameController,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(4, 4, 12, 4),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.border_gray),
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Section',
                      style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                    CupertinoTextField(
                      padding: EdgeInsets.all(0),
                      placeholder: '',
                      style: TextStyle(fontSize: 15),
                      decoration: BoxDecoration(border: null),
                      // controller: lastNameController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: SKColors.skoller_blue,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          alignment: Alignment.center,
          child: Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget createViewTwo() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.ooo,
            speechBubbleContents: Text('You are halfway there!'),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          // margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Professor',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                placeholder: '',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                // controller: lastNameController,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: <Widget>[
                  Text(
                    'This is an online class',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  )
                ],
              ),
              Text('Meet days'),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: SKColors.skoller_blue,
                    )),
                child: Row(
                  children: <Widget>[
                    createDay('Sun'),
                    createDay('Mon'),
                    createDay('Tue'),
                    createDay('Wed'),
                    createDay('Thu'),
                    createDay('Fri'),
                    createDay('Sat'),
                  ],
                ),
              ),
              Text('Meet Time'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.skoller_blue),
                ),
                child: Text('9:30 am'),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget createDay(String day) {
    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          setState(() {
            selectedDays[day] = !selectedDays[day];
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          color: selectedDays[day] ? SKColors.skoller_blue : null,
          child: Text(
            day,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color:
                    selectedDays[day] ? Colors.white : SKColors.skoller_blue),
          ),
        ),
      ),
    );
  }

  Widget createViewThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Item3'),
        SammiSpeechBubble(
          sammiPersonality: SammiPersonality.smile,
          speechBubbleContents: Text('hi'),
        )
      ],
    );
  }
}
