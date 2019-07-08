import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class CreateClassModal extends StatefulWidget {
  @override
  State createState() => _CreateClassModalState();
}

class _CreateClassModalState extends State<CreateClassModal> {
  final pageController = PageController(initialPage: 0);


  final classNameController = TextEditingController();
  final subjectController = TextEditingController();
  final codeController = TextEditingController();
  final sectionController = TextEditingController();

  Map<String, bool> selectedDays = {
    'Sun': false,
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
  };
  bool isOnline = false;

  DateTime time;

  @override
  void initState() {
    final now = DateTime.now();
    time = DateTime(now.year, now.month, now.day, 9, 30);

    super.initState();
  }

  void advanceController() {
    final page = pageController.page.toInt();
    if (page < 2) {
      pageController.animateToPage(page + 1,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    }
  }

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
          controller: pageController,
          // physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            _CreateClassScreenOne(this),
            _CreateClassScreenTwo(this),
            _CreateClassScreenThree(this),
          ],
        ),
      ),
    );
  }
}

class _CreateClassScreenOne extends StatefulWidget {
  final _CreateClassModalState subviewParent;

  _CreateClassScreenOne(this.subviewParent);

  @override
  State<StatefulWidget> createState() => _CreateClassScreenOneState();
}

class _CreateClassScreenOneState extends State<_CreateClassScreenOne> {

  bool isValid = false;

  void checkValid(String _str) {
    final parent = widget.subviewParent;

    final className = parent.classNameController.text.trim();
    final subject = parent.subjectController.text.trim();
    final code = parent.codeController.text.trim();
    final section = parent.sectionController.text.trim();

    final newIsValid =
        className != '' && subject != '' && code != '' && section != '';
    if (newIsValid != isValid) {
      setState(() {
        isValid = newIsValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) { 
    final parent = widget.subviewParent;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
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
                  controller: parent.classNameController,
                  onChanged: checkValid,
                  autofocus: true,
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
                        controller: parent.subjectController,
                        onChanged: checkValid,
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
                        controller: parent.codeController,
                        onChanged: checkValid,
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
                        controller: parent.sectionController,
                        onChanged: checkValid,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTapUp: (details) =>
                isValid ? widget.subviewParent.advanceController() : null,
            child: Container(
              decoration: BoxDecoration(
                color: isValid ? SKColors.skoller_blue : SKColors.inactive_gray,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [UIAssets.boxShadow],
              ),
              padding: EdgeInsets.symmetric(vertical: 4),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              alignment: Alignment.center,
              child: Text(
                'Next 👉',
                style: TextStyle(
                    color: isValid ? Colors.white : SKColors.dark_gray),
              ),
            ),
          ),
        ],
      );
  }
}

class _CreateClassScreenTwo extends StatefulWidget {
  final _CreateClassModalState subviewParent;

  _CreateClassScreenTwo(this.subviewParent);

  @override
  State<StatefulWidget> createState() => _CreateClassScreenTwoState();
}

class _CreateClassScreenTwoState extends State<_CreateClassScreenTwo> {
  bool isValid = false;
  
  @override
  void initState() {
    validState();
    super.initState();
  }

  void validState() {
    final parent = widget.subviewParent;

    final newIsValid =
        parent.isOnline || parent.selectedDays.containsValue(true);

    if (newIsValid != isValid) {
      setState(() {
        isValid = newIsValid;
      });
    }
  }

  void tappedStartTime(TapUpDetails details) {
    final parent = widget.subviewParent;

    if (parent.isOnline) return;

    DateTime tempTime = parent.time;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                initialDateTime: tempTime,
                minuteInterval: 5,
                onDateTimeChanged: (dateTime) => tempTime = dateTime,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context),
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
                    onTapUp: (details) {
                      setState(() {
                        parent.time = tempTime;
                      });
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Select',
                        style: TextStyle(color: SKColors.skoller_blue),
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
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.subviewParent;
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
            borderRadius: BorderRadius.circular(5),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'This is an online class',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  CupertinoSwitch(
                    activeColor: SKColors.skoller_blue,
                    value: parent.isOnline,
                    onChanged: (newVal) {
                      setState(() => parent.isOnline = newVal);
                      validState();
                    },
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 2),
                child: Text('Meet days'),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: parent.isOnline
                          ? SKColors.light_gray
                          : SKColors.skoller_blue,
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
                onTapUp: tappedStartTime,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: parent.isOnline
                            ? SKColors.light_gray
                            : SKColors.skoller_blue),
                  ),
                  child: Text(
                    TimeOfDay.fromDateTime(parent.time).format(context),
                    style: TextStyle(
                        color: parent.isOnline
                            ? SKColors.light_gray
                            : SKColors.skoller_blue,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTapUp: (details) {
            if (isValid) widget.subviewParent.advanceController();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SKColors.border_gray),
              color: isValid ? SKColors.skoller_blue : SKColors.inactive_gray,
              boxShadow: [UIAssets.boxShadow],
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Next',
              style:
                  TextStyle(color: isValid ? Colors.white : SKColors.dark_gray),
            ),
          ),
        )
      ],
    );
  }

  Widget createDay(String day) {
    final parent = widget.subviewParent;

    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          if (parent.isOnline) return;
          setState(() {
            parent.selectedDays[day] = !parent.selectedDays[day];
          });
          validState();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: parent.selectedDays[day]
                ? (parent.isOnline
                    ? SKColors.light_gray
                    : SKColors.skoller_blue)
                : null,
            border: day == 'Sat'
                ? null
                : Border(
                    right: BorderSide(
                        color: parent.isOnline
                            ? SKColors.light_gray
                            : SKColors.skoller_blue)),
          ),
          child: Text(
            day,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: parent.selectedDays[day]
                    ? Colors.white
                    : (parent.isOnline
                        ? SKColors.light_gray
                        : SKColors.skoller_blue)),
          ),
        ),
      ),
    );
  }
}

class _CreateClassScreenThree extends StatefulWidget {
  final _CreateClassModalState subviewParent;

  _CreateClassScreenThree(this.subviewParent);

  @override
  State<StatefulWidget> createState() => _CreateClassScreenThreeState();
}

class _CreateClassScreenThreeState extends State<_CreateClassScreenThree> {
  @override
  Widget build(BuildContext context) => Column(
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
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
