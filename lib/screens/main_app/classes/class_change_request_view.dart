import 'dart:collection';

import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class ClassChangeRequestView extends StatefulWidget {
  final int classId;

  ClassChangeRequestView(this.classId);

  @override
  State<StatefulWidget> createState() => _ClassChangeRequestState();
}

class _ClassChangeRequestState extends State<ClassChangeRequestView> {
  TextEditingController nameController;
  TextEditingController subjectController;
  TextEditingController codeController;
  TextEditingController sectionController;

  TimeOfDay startTime;
  bool isOnline;
  bool wasEdited = false;

  Map<String, bool> selectedDays = LinkedHashMap.fromIterables(
    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    List.generate(7, (index) => false),
  );

  @override
  void initState() {
    final studentClass = StudentClass.currentClasses[widget.classId];

    nameController = TextEditingController(text: studentClass.name);
    subjectController = TextEditingController(text: studentClass.subject);
    codeController = TextEditingController(text: studentClass.code);
    sectionController = TextEditingController(text: studentClass.section);

    isOnline = studentClass.meetDays == 'online';
    startTime = isOnline ? null : studentClass.meetTime;

    if (!isOnline) {
      for (final day in (studentClass.meetDays ?? '').split('')) {
        String dayStr;
        switch (day) {
          case 'U':
            dayStr = 'Sun';
            break;
          case 'M':
            dayStr = 'Mon';
            break;
          case 'T':
            dayStr = 'Tue';
            break;
          case 'W':
            dayStr = 'Wed';
            break;
          case 'R':
            dayStr = 'Thu';
            break;
          case 'F':
            dayStr = 'Fri';
            break;
          case 'S':
            dayStr = 'Sat';
            break;
          default:
            break;
        }

        selectedDays[dayStr] = true;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    subjectController.dispose();
    codeController.dispose();
    sectionController.dispose();
  }

  void tappedSave() {
    if (!wasEdited) return;

    final meetDays = isOnline
        ? 'online'
        : (selectedDays.keys.toList()..removeWhere((day) => !selectedDays[day]))
            .map((day) {
            if (day == 'Sun') {
              return 'U';
            } else if (day == 'Thu') {
              return 'R';
            } else {
              return day[0];
            }
          }).join();

    final name = nameController.text.trim();
    final subject = subjectController.text.trim();
    final code = codeController.text.trim();
    final section = sectionController.text.trim();

    final studentClass = StudentClass.currentClasses[widget.classId];

    final loader = SKLoadingScreen.fadeIn(context);

    studentClass
        .submitClassChangeRequest(
      name: name == studentClass.name ? null : name,
      subject: subject == studentClass.subject ? null : subject,
      code: code == studentClass.code ? null : code,
      section: section == studentClass.section ? null : section,
      meetDays: meetDays == studentClass.meetDays ? null : meetDays,
      meetTime:
          (isOnline || startTime == studentClass.meetTime) ? null : startTime,
      isOnline: isOnline,
    )
        .then((response) {
      loader.fadeOut();
      if (response) {
        Navigator.pop(context);
      } else {
        DropdownBanner.showBanner(
          text: 'Issue saving assignment',
          color: SKColors.warning_red,
        );
      }
    });
  }

  void tappedStartTime(TapUpDetails details) {
    if (isOnline) return;

    final now = DateTime.now();
    DateTime tempTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime?.hour ?? 9,
      startTime?.minute ?? 30,
    );

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
                        startTime = TimeOfDay.fromDateTime(tempTime);
                      });
                      checkValid(null);
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

  void checkValid(_) {
    final name = nameController.text.trim();
    final subject = subjectController.text.trim();
    final code = codeController.text.trim();
    final section = sectionController.text.trim();

    final studentClass = StudentClass.currentClasses[widget.classId];

    final meetDays = isOnline
        ? 'online'
        : (selectedDays.keys.toList()..removeWhere((day) => !selectedDays[day]))
            .map((day) {
            if (day == 'Sun') {
              return 'U';
            } else if (day == 'Thu') {
              return 'R';
            } else {
              return day[0];
            }
          }).join();

    final newValue = name != studentClass.name ||
        subject != studentClass.subject ||
        code != studentClass.code ||
        section != studentClass.section ||
        (isOnline
            ? (!studentClass.isOnline)
            : (studentClass.meetTime != startTime ||
                studentClass.meetDays != meetDays));

    if (newValue != wasEdited) setState(() => wasEdited = newValue);
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      backgroundColor: SKColors.background_gray,
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SKColors.border_gray),
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Text('Edit class info',
                          style: TextStyle(fontSize: 17)),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.border_gray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Class name',
                            style: TextStyle(
                                color: SKColors.skoller_blue,
                                fontSize: 13,
                                fontWeight: FontWeight.normal),
                          ),
                          CupertinoTextField(
                            cursorColor: SKColors.skoller_blue,
                            padding: EdgeInsets.only(top: 1),
                            placeholder: 'Microeconomics',
                            style: TextStyle(
                                fontSize: 15, color: SKColors.dark_gray),
                            decoration: BoxDecoration(border: null),
                            controller: nameController,
                            onChanged: checkValid,
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(12, 4, 4, 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
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
                                  style: TextStyle(
                                      fontSize: 15, color: SKColors.dark_gray),
                                  decoration: BoxDecoration(border: null),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  controller: subjectController,
                                  onChanged: checkValid,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
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
                                  style: TextStyle(
                                      fontSize: 15, color: SKColors.dark_gray),
                                  decoration: BoxDecoration(border: null),
                                  controller: codeController,
                                  onChanged: checkValid,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(4, 4, 12, 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
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
                                  style: TextStyle(
                                      fontSize: 15, color: SKColors.dark_gray),
                                  decoration: BoxDecoration(border: null),
                                  controller: sectionController,
                                  keyboardType: TextInputType.number,
                                  onChanged: checkValid,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.border_gray),
                      ),
                      margin: EdgeInsets.fromLTRB(12, 4, 12, 12),
                      padding: EdgeInsets.all(12),
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
                              Switch(
                                activeColor: SKColors.skoller_blue,
                                value: isOnline,
                                onChanged: (newVal) {
                                  setState(() => isOnline = newVal);
                                  checkValid(null);
                                },
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 2),
                            child: Text(
                              'Meet days',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 15),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isOnline
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
                            child: Text(
                              'Meet Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 15),
                            ),
                          ),
                          GestureDetector(
                            onTapUp: tappedStartTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: isOnline
                                        ? SKColors.light_gray
                                        : SKColors.skoller_blue),
                              ),
                              child: Text(
                                startTime?.format(context) ?? 'N/A',
                                style: TextStyle(
                                    color: isOnline
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
                      onTapUp: (details) => tappedSave(),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        margin:
                            EdgeInsets.only(left: 12, right: 12, bottom: 12),
                        decoration: BoxDecoration(
                          color: wasEdited
                              ? SKColors.success
                              : SKColors.inactive_gray,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: wasEdited
                                  ? Colors.white
                                  : SKColors.dark_gray),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createDay(String day) {
    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          if (isOnline) return;
          setState(() => selectedDays[day] = !selectedDays[day]);
          checkValid(null);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedDays[day]
                ? (isOnline ? SKColors.light_gray : SKColors.skoller_blue)
                : null,
            border: day == 'Sat'
                ? null
                : Border(
                    right: BorderSide(
                        color: isOnline
                            ? SKColors.light_gray
                            : SKColors.skoller_blue)),
          ),
          child: Text(
            day,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: selectedDays[day]
                    ? Colors.white
                    : (isOnline ? SKColors.light_gray : SKColors.skoller_blue)),
          ),
        ),
      ),
    );
  }
}
