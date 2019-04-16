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
                          fontWeight: FontWeight.normal, fontSize: 15),
                    )
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(vertical: 12),
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
                      studentClass.meetDays + studentClass.meetTime ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                    )
                  ],
                ),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.only(top: 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
