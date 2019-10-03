import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/classes/professor_change_request_view.dart';
import 'package:skoller/tools.dart';

class ProfessorInfoView extends StatelessWidget {
  final int classId;

  ProfessorInfoView(this.classId);

  void tappedEdit(BuildContext context) {
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
    final professor = studentClass.professor;

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        SKHeaderCard(
          leftHeaderItem: Text(
            'Professor info',
            style: TextStyle(fontSize: 17),
          ),
          rightHeaderItem: GestureDetector(
            onTapUp: (_) => tappedEdit(context),
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
                      onTapUp: (_) => tappedEdit(context),
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
                      onTapUp: (_) => tappedEdit(context),
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
                      onTapUp: (_) => tappedEdit(context),
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
                    onTapUp: (_) => tappedEdit(context),
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
        ),
      ],
    );
  }
}
