import 'package:flutter/material.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';

class AssignmentAddView extends StatefulWidget {
  final int class_id;

  AssignmentAddView(this.class_id, {Key key}) : super(key: key);

  @override
  State createState() => _AssignmentAddViewState();
}

class _AssignmentAddViewState extends State<AssignmentAddView> {
  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.class_id];
    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        Text('hi'),
        Text('hey'),
      ],
    );
  }
}
