import 'package:flutter/material.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';

class ClassInfoView extends StatefulWidget {
  final int classId;

  ClassInfoView(this.classId, {Key key}) : super(key: key);

  @override
  State createState() => _ClassInfoViewState();
}

class _ClassInfoViewState extends State<ClassInfoView> {
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
                  children: <Widget>[
                    Text(
                      'Class info',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
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
                    Text('Vanderbilt University'),
                    Text(
                      'Spring 2019',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14),
                    )
                  ],
                ),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.only(top: 4),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      studentClass.name,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                    ),
                    Text(
                      (studentClass.meetDays ?? '') +
                          (studentClass.meetDays == null ? '' : ' ') +
                          (studentClass.meetTime == null
                              ? ''
                              : studentClass.meetTime.format(context)),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14),
                    )
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SKColors.selected_gray),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  studentClass.subject +
                      ' ' +
                      studentClass.code +
                      '.' +
                      studentClass.section,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(bottom: 12, top: 4),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(studentClass.professor.first_name ??
                    '' + studentClass.professor.last_name ??
                    ''),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.only(bottom: 12, top: 4),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTapUp: (details) {
            //Change color
          },
          child: Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: studentClass.getColor(),
              border: Border.all(color: SKColors.border_gray),
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
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    margin: EdgeInsets.only(right: 8),
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
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Grade Scale',
                      style: TextStyle(color: SKColors.skoller_blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
