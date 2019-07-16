import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/classes/weights_info_view.dart';
import 'package:skoller/tools.dart';
import 'class_change_request_view.dart';

class ClassInfoView extends StatefulWidget {
  final int classId;
  final bool isClassesTab;

  ClassInfoView(this.classId, {Key key, this.isClassesTab = true})
      : super(key: key);

  @override
  State createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfoView> {
  void tappedGradeScale(TapUpDetails details) async {
    StudentClass studentClass = StudentClass.currentClasses[widget.classId];

    bool showGradeScale = true;

    if (studentClass.gradeScale == null) {
      final result = await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: GradeScaleModalView(studentClass),
        ),
      );

      showGradeScale = result != null && result;

      if (showGradeScale) {
        studentClass = StudentClass.currentClasses[widget.classId];
        setState(() {});
      }
    }

    if (showGradeScale) {
      List<Map<String, dynamic>> scale = [];

      for (final key in studentClass.gradeScale.keys) {
        final val = studentClass.gradeScale[key];
        scale.add({'letter': key, 'grade': val});
      }

      // scale.sort(
      //   (elem1, elem2) =>
      //       (elem2['grade'] as num).compareTo(elem1['grade'] as num),
      // );

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  // alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(12, 12, 0, 8),
                  decoration: BoxDecoration(
                      color: SKColors.selected_gray,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          child: Image.asset(ImageNames.navArrowImages.down),
                        ),
                      ),
                      Text(
                        'Grade scale',
                        style: TextStyle(fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        width: 36,
                        child:
                            null, //Text('edit', style: TextStyle(color: SKColors.skoller_blue, fontWeight: FontWeight.normal),),
                      ),
                    ],
                  ),
                ),
                ...scale
                    .map(
                      (elem) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(elem['letter']),
                            Text(
                              '> ${elem['grade']}',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      );
    }
  }

  void tappedDropClass(TapUpDetails details) async {
    final bool result = await showDialog(
      context: context,
      builder: (context) => SKAlertDialog(
        title: 'Drop class',
        subTitle: 'Are you sure?',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
      ),
    );
    if (result is bool && result) {
      final bool successfullyDropped =
          await StudentClass.currentClasses[widget.classId].dropClass();
      print(successfullyDropped);
      if (successfullyDropped) {
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);

        if (widget.isClassesTab) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                decoration: BoxDecoration(
                    color: SKColors.selected_gray,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Class info',
                      style: TextStyle(fontSize: 17),
                    ),
                    GestureDetector(
                      onTapUp: (details) => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                ClassChangeRequestView(studentClass.id)),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                            color: SKColors.skoller_blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'School name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: SKColors.light_gray,
                      ),
                    ),
                    Text(
                      'School Period',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: SKColors.light_gray,
                      ),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(top: 8, bottom: 2),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SKColors.selected_gray),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          studentClass.classPeriod.getSchool()?.name ?? 'N/A'),
                    ),
                    Text(
                      studentClass.classPeriod.name,
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(bottom: 8),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Course number',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: SKColors.light_gray,
                      ),
                    ),
                    Text(
                      'Meet time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: SKColors.light_gray,
                      ),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(top: 8, bottom: 2),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SKColors.selected_gray),
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      studentClass.subject +
                          ' ' +
                          studentClass.code +
                          '.' +
                          studentClass.section,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      (studentClass.meetDays ?? '') +
                          (studentClass.meetDays == null ||
                                  studentClass.meetTime == null
                              ? ''
                              : ' @ ') +
                          (studentClass.meetTime == null
                              ? ''
                              : studentClass.meetTime.format(context)),
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Professor name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: SKColors.light_gray,
                      ),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(top: 8, bottom: 2),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  (studentClass.professor?.firstName ?? '') +
                      (studentClass.professor?.firstName == null ? '' : ' ') +
                      (studentClass.professor?.lastName ?? ''),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(bottom: 12),
              ),
            ],
          ),
        ),
        SKColorPicker(
          callback: (newColor) {
            studentClass.setColor(newColor).then((response) {
              if (response.wasSuccessful()) {
                DartNotificationCenter.post(
                    channel: NotificationChannels.classChanged);
              }
            });
            setState(() {});
          },
          child: Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: studentClass.getColor(),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [UIAssets.boxShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Change color',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTapUp: (details) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => WeightsInfoView(studentClass.id),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    margin: EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Weights',
                      style: TextStyle(color: SKColors.skoller_blue),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapUp: tappedGradeScale,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    // padding: EdgeInsets.symmetric(horizontal: 32),
                    margin: EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: studentClass.gradeScale == null
                            ? SKColors.warning_red
                            : SKColors.border_gray,
                      ),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: studentClass.gradeScale == null
                        ? Text(
                            'Add Grade Scale',
                            style: TextStyle(color: SKColors.warning_red),
                          )
                        : Text(
                            'Grade Scale',
                            style: TextStyle(color: SKColors.skoller_blue),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Spacer(
          flex: 1,
        ),
        GestureDetector(
          onTapUp: tappedDropClass,
          child: Container(
            height: 34,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                color: SKColors.warning_red,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [UIAssets.boxShadow]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Drop class',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
