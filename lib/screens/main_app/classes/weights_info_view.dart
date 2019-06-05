import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class WeightsInfoView extends StatefulWidget {
  final int classId;

  WeightsInfoView(this.classId);

  @override
  State createState() => _WeightsInfoViewState();
}

class _WeightsInfoViewState extends State<WeightsInfoView> {
  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    int assignmentCount = 0;

    Map<int, int> assignmentsPerWeight = {};

    for (final Assignment assignment in (studentClass.assignments ?? [])) {
      if (assignment.weight_id != null) {
        assignmentCount++;
        assignmentsPerWeight.update(
          assignment.weight_id,
          (existing) => existing + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        Text('Weight breakdown'),
        Text('${assignmentCount}'),
        Text('Assignments are weighted equally within each category'),
      ],
    );
  }
}
