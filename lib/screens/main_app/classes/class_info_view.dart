import 'package:skoller/screens/main_app/classes/modals/change_request_explanation_modal.dart';
import 'package:skoller/screens/main_app/classes/professor_change_request_view.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'class_change_request_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class ClassInfoView extends StatefulWidget {
  final int classId;
  final bool isClassesTab;

  ClassInfoView(this.classId, {this.isClassesTab = true});

  @override
  State createState() => _ClassInfoViewState();
}

class _ClassInfoViewState extends State<ClassInfoView> {
  @override
  void initState() {
    DartNotificationCenter.subscribe(
      observer: this,
      channel: NotificationChannels.classChanged,
      onNotification: (_) => setState(() {}),
    );

    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    
    super.dispose();
  }

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
          await StudentClass.currentClasses[widget.classId]!.dropClass();
      if (successfullyDropped) {
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);

        if (widget.isClassesTab) {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  void tappedEditProfessor(_) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => ProfessorChangeRequestView(widget.classId),
      ),
    );
  }

  void tappedChangeRequestExplanation(_) => showDialog(
        context: context,
        builder: (context) => ChangeRequestExplanationModal(),
      );

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    final classChangeRequests = studentClass!.classInfoChangeRequests
        .map((c) => buildChangeRequest('Pending class change request', c));
    final professorChangeRequests = studentClass.professorInfoChangeRequests
        .map((c) => buildChangeRequest('Pending professor change request', c));

    return SKNavView(
      title: studentClass.name!,
      titleColor: studentClass.getColor(),
      children: [
        Expanded(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16),
              ...classChangeRequests,
              createClassInfoCard(studentClass),
              ...professorChangeRequests,
              createProfessorCard(studentClass),
            ],
          ),
        ),
      ],
    );
  }

  Widget createClassInfoCard(StudentClass studentClass) => Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                            : studentClass.meetTime!.format(context)),
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

  Widget createProfessorCard(StudentClass studentClass) {
    final professor = studentClass.professor;

    return SKHeaderCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      leftHeaderItem: Text(
        'Professor info',
        style: TextStyle(fontSize: 17),
      ),
      rightHeaderItem: GestureDetector(
        onTapUp: tappedEditProfessor,
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
                  onTapUp: tappedEditProfessor,
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
              ? Text(studentClass.professor.phoneNumber??'')
              : GestureDetector(
                  onTapUp: tappedEditProfessor,
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
              ? Text(studentClass.professor.officeLocation??'')
              : GestureDetector(
                  onTapUp: tappedEditProfessor,
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
            ? Text(studentClass.professor.availability??'')
            : GestureDetector(
                onTapUp: tappedEditProfessor,
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

  Widget buildChangeRequest(String title, ChangeRequest changeRequest) {
    final labelConverter = {
      'name_first': 'First name',
      'name_last': 'Last name',
      'email': 'Email',
      'phone': 'Phone',
      'office_location': 'Office location',
      'office_availability': 'Availability',
      'name': 'Name',
      'meet_days': 'Meet days',
      'meet_start_time': 'Meet time',
      'subject': 'Subject',
      'section': 'Section',
      'code': 'Code',
    };

    final members =
        (changeRequest.members..sort((m1, m2) => m1.name.compareTo(m2.name)))
            .map((m) {
              final name = labelConverter[m.name] ?? m.name;
              String value = m.value;
              if (m.name == 'meet_start_time' && value != null) {
                final timeSegments =
                    value.split(':').map((n) => int.tryParse(n)).toList();
                value =
                    TimeOfDay(hour: timeSegments[0]!, minute: timeSegments[1]!)
                        .format(context);
              }

              return {'name': name, 'value': value};
            })
            .map(buildChangeMemberRow)
            .toList();

    return SKHeaderCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      leftHeaderItem: Row(children: [
        Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.access_time,
            size: 22,
            color: SKColors.alert_orange,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: SKColors.alert_orange, fontSize: 13),
        ),
      ]),
      rightHeaderItem: GestureDetector(
        onTapUp: tappedChangeRequestExplanation,
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Icon(
            Icons.help_outline,
            color: SKColors.skoller_blue,
          ),
        ),
      ),
      children: members,
    );
  }

  Widget buildChangeMemberRow(Map member) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                member['name'],
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              member['value'],
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
}
