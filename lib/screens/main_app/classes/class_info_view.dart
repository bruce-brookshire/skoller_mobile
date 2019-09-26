import 'package:skoller/screens/main_app/classes/class_document_view.dart';
import 'package:skoller/screens/main_app/classes/weights_info_view.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import './modals/add_grade_scale_modal.dart';
import 'class_change_request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';
import 'grade_scale_view.dart';

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

    if (studentClass.gradeScale == null) {
      await Navigator.push(
        context,
        SKNavOverlayRoute(
          builder: (context) => AddGradeScaleModal(
            classId: widget.classId,
            onCompletionShowGradeScale: true,
          ),
        ),
      );
      setState(() {});
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => GradeScaleView(widget.classId),
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

  void tappedViewDocuments(TapUpDetails details) async {
    final docs = StudentClass.currentClasses[widget.classId].documents;

    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Class documents',
        subtitle: 'Which would you like to view?',
        onSelect: (index) => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ClassDocumentView(docs[index]),
          ),
        ),
        items: docs.map((d) => d.name).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: [
        Expanded(
          child: ListView(
            children: <Widget>[
              createGrowCommunityCard(studentClass),
              createClassInfoCard(studentClass),
              createClassToolsCard(studentClass),
            ],
          ),
        ),
      ],
    );
  }

  Widget createGrowCommunityCard(StudentClass studentClass) => Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [UIAssets.boxShadow],
            color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: SKColors.selected_gray,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child:
                            Image.asset(ImageNames.peopleImages.people_gray),
                      ),
                      Text(
                        'Grow community',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  // Padding(
                  // padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                  // child:
                  Text(
                    'Share this class specific link so your classmates can collaborate!🎉',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                  // ),
                ],
              ),
            ),
            GestureDetector(
              onTapUp: (details) => Share.share(
                  'School is hard. But this new app called Skoller makes it easy! Our class ${studentClass.name ?? ''} is already in the app. Download so we can keep up together!\n\n${studentClass.enrollmentLink}'),
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SKColors.skoller_blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      studentClass.enrollmentLink.split('//')[1],
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget createClassInfoCard(StudentClass studentClass) => Container(
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
                    'Details',
                    style: TextStyle(fontSize: 17),
                  ),
                  GestureDetector(
                    onTapUp: (details) => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) =>
                            ClassChangeRequestView(studentClass.id),
                        settings: RouteSettings(name: 'ClassChangeRequestView'),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style:
                          TextStyle(color: SKColors.skoller_blue, fontSize: 14),
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
                    (studentClass.subject ?? '') +
                        ' ' +
                        (studentClass.code ?? '') +
                        '.' +
                        (studentClass.section ?? ''),
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
      );

  Widget createClassToolsCard(StudentClass studentClass) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SKColors.border_gray),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [UIAssets.boxShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )),
              child: Text(
                'Tools',
                style: TextStyle(fontSize: 17),
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
                padding: EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
                decoration: BoxDecoration(
                  color: studentClass.getColor(),
                  borderRadius: BorderRadius.circular(5),
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
              margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTapUp: (details) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                WeightsInfoView(studentClass.id),
                            settings: RouteSettings(name: 'WeightsInfoView'),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 9),
                        margin: EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: SKColors.skoller_blue),
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
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 9),
                        margin: EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: studentClass.gradeScale == null
                                ? SKColors.warning_red
                                : SKColors.skoller_blue,
                          ),
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
            if (studentClass.documents.length > 0)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: tappedViewDocuments,
                child: Container(
                  margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: studentClass.gradeScale == null
                          ? SKColors.warning_red
                          : SKColors.border_gray,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Documents (${studentClass.documents.length})',
                    style: TextStyle(color: SKColors.skoller_blue),
                  ),
                ),
              ),
            GestureDetector(
              onTapUp: tappedDropClass,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.warning_red),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Drop class',
                      style: TextStyle(color: SKColors.warning_red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
