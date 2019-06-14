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
        height: 348,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
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
                cursorColor: SKColors.skoller_blue,
                padding: EdgeInsets.only(top: 1),
                placeholder: 'Intro to Calculus',
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
                      cursorColor: SKColors.skoller_blue,
                padding: EdgeInsets.only(top: 1),
                      placeholder: 'MATH',
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
                      cursorColor: SKColors.skoller_blue,
                padding: EdgeInsets.only(top: 1),
                      placeholder: '1300',
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
                      cursorColor: SKColors.skoller_blue,
                padding: EdgeInsets.only(top: 1),
                      placeholder: '2',
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
            boxShadow: [UIAssets.boxShadow],
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
    final now = DateTime.now();
    final initTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute - (now.minute % 5),
    );

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.ooo,
            sammiSide: SammiSide.right,
            speechBubbleContents: Text('You are halfway there!'),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.only(top: 1),
                placeholder: 'Search your professor...',
                cursorColor: SKColors.skoller_blue,
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
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Text(
                    'This is an online class',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 2),
                child: Text('Meet days'),
              ),
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
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 2),
                child: Text('Meet Time'),
              ),
              GestureDetector(
                onTapUp: (details) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'Start time',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'What time does your class start?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            height: 160,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: initTime,
                              minuteInterval: 5,
                              onDateTimeChanged: (dateTime) {},
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  onTapUp: (details) {
                                    //TODO date set null
                                    Navigator.pop(context);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: SKColors.skoller_blue,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTapUp: (details) => Navigator.pop(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Select',
                                      style: TextStyle(
                                          color: SKColors.skoller_blue),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.skoller_blue),
                  ),
                  child: Text(
                    '9:30 am',
                    style: TextStyle(color: SKColors.skoller_blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: [UIAssets.boxShadow],
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Next ->',
              style: TextStyle(color: Colors.white),
            ),
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
          padding: EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedDays[day] ? SKColors.skoller_blue : null,
            border: day == 'Sat'
                ? null
                : Border(right: BorderSide(color: SKColors.skoller_blue)),
          ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.cool,
            speechBubbleContents: Text.rich(
              TextSpan(
                text: 'Review ',
                children: [
                  TextSpan(
                      text: 'your info! 🧐',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Class name',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Microeconomics',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Subject',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'ECONL',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Code',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '52896',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Section',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '2',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Meet times',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Microeconomics',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Professor',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Microeconomics',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: SKColors.success,
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Text(
            'Done! 🎉',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}

// class _CreateClassScreens extends StatefulWidget {

// }

// class _CreateClassScreenOneState extends State<StatefulWidget> {

// }
