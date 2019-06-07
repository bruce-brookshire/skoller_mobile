import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'assignment_weight_view.dart';

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

    final weightRows = (studentClass.weights ?? []).map(
      (weight) {
        int assignmentCount = assignmentsPerWeight[weight.id] ?? 0;

        int weightNum = weight.weight.toInt();
        num fractionalWeight;

        if (studentClass.isPoints) {
          fractionalWeight =
              assignmentCount > 0 ? weightNum ~/ assignmentCount : 0;
        } else {
          fractionalWeight =
              ((weightNum * 10) / assignmentCount).truncateToDouble() / 10;
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(weight.name),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: assignmentCount == 0
                          ? Text(
                              'This category has no assignments',
                              style: TextStyle(
                                color: SKColors.warning_red,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            )
                          : Text(
                              '${assignmentCount} assignment${assignmentCount == 1 ? '' : 's'} worth ${fractionalWeight}${studentClass.isPoints ? ' pts.' : '%'} ${assignmentCount == 1 ? '' : 'each'}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                    )
                  ],
                ),
              ),
              Text(
                '${weightNum}${studentClass.isPoints ? ' pt${weightNum == 1 ? '' : 's'}.' : '%'}',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          ),
        );
      },
    );

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      backgroundColor: Colors.white,
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Text(
                  'Weight Breakdown',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                '${assignmentCount} weighted assignments',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                child: Text(
                  'Assignments are equally weighted within each category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
              ...weightRows,
              Padding(
                padding: EdgeInsets.only(top: 24, bottom: 8),
                child: Text(
                  'Need to add an assignment?',
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTapUp: (details) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          AssignmentWeightView(studentClass.id),
                    ),
                  );
                },
                child: Text(
                  'Add an assignment',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
