import 'package:skoller/screens/main_app/classes/professor_change_request_view.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'class_change_request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class ClassInfoView extends StatelessWidget {
  final int classId;
  final bool isClassesTab;

  ClassInfoView(this.classId, {Key key, this.isClassesTab = true})
      : super(key: key);

  void tappedDropClass(BuildContext context) async {
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
          await StudentClass.currentClasses[classId].dropClass();
      if (successfullyDropped) {
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);

        if (isClassesTab) {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  void tappedEditProfessor(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => ProfessorChangeRequestView(classId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[classId];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: [
        Expanded(
          child: ListView(
            children: <Widget>[
              createClassInfoCard(studentClass, context),
              createProfessorCard(studentClass, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget createClassInfoCard(StudentClass studentClass, BuildContext context) =>
      Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SKColors.border_gray),
          borderRadius: BorderRadius.circular(10),
          boxShadow: UIAssets.boxShadow,
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
                      style: TextStyle(color: SKColors.skoller_blue),
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
            GestureDetector(
              onTapUp: (_) => tappedDropClass(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
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

  Widget createProfessorCard(StudentClass studentClass, BuildContext context) {
    final professor = studentClass.professor;

    return SKHeaderCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      leftHeaderItem: Text(
        'Professor info',
        style: TextStyle(fontSize: 17),
      ),
      rightHeaderItem: GestureDetector(
        onTapUp: (_) => tappedEditProfessor(context),
        child: Text(
          'Edit',
          style: TextStyle(color: SKColors.skoller_blue),
        ),
      ),
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: SKColors.light_gray,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SKColors.selected_gray),
            ),
          ),
          child: Text(studentClass.professor.fullName ?? ''),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Email address',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: SKColors.light_gray,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SKColors.selected_gray),
            ),
          ),
          child: professor.email != null
              ? Text(studentClass.professor.email ?? '')
              : GestureDetector(
                  onTapUp: (_) => tappedEditProfessor(context),
                  child: Text(
                    'Add email',
                    style: TextStyle(
                      color: SKColors.warning_red,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Phone number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: SKColors.light_gray,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SKColors.selected_gray),
            ),
          ),
          child: professor.phoneNumber != null
              ? Text(studentClass.professor.phoneNumber)
              : GestureDetector(
                  onTapUp: (_) => tappedEditProfessor(context),
                  child: Text(
                    'Add phone',
                    style: TextStyle(
                      color: SKColors.warning_red,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Office location',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: SKColors.light_gray,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8),
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SKColors.selected_gray),
            ),
          ),
          child: professor.officeLocation != null
              ? Text(studentClass.professor.officeLocation)
              : GestureDetector(
                  onTapUp: (_) => tappedEditProfessor(context),
                  child: Text(
                    'Add office location',
                    style: TextStyle(
                      color: SKColors.warning_red,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Availability',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: SKColors.light_gray,
            ),
          ),
        ),
        professor.availability != null
            ? Text(studentClass.professor.availability)
            : GestureDetector(
                onTapUp: (_) => tappedEditProfessor(context),
                child: Text(
                  'Add availability',
                  style: TextStyle(
                    color: SKColors.warning_red,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
      ],
    );
  }
}
