import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/classes/assignment_info_view.dart';
import 'package:skoller/tools.dart';

class DatelessAssignmentsModal extends StatelessWidget {
  final List<int> datelessAssignmentIds;

  DatelessAssignmentsModal(this.datelessAssignmentIds);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = datelessAssignmentIds
        .fold<Map<StudentClass, List<Assignment>>>({}, (acc, val) {
          final assignment = Assignment.currentAssignments[val];
          final parentClass = assignment.parentClass;

          if (acc[parentClass] == null)
            acc[parentClass] = [assignment];
          else
            acc[parentClass].add(assignment);

          return acc;
        })
        .entries
        .map((e) {
          final assignments = (e.value
                ..sort((a1, a2) => a2.name.compareTo(a1.name)))
              .map(
                (a) => GestureDetector(
                  onTapUp: (_) => Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          AssignmentInfoView(assignmentId: a.id),
                      settings: RouteSettings(name: 'AssignmentWeightView'),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.name,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: SKColors.skoller_blue,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                ),
              )
              .toList();

          final classCard = Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SKColors.border_gray),
              boxShadow: UIAssets.boxShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: SKColors.light_gray))),
                  padding: EdgeInsets.fromLTRB(4, 4, 0, 4),
                  child: Text(
                    e.key.name,
                    // textAlign: TextAlign.left,
                    style: TextStyle(
                        color: e.key.getColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
                ...assignments
              ],
            ),
          );
          return classCard;
        })
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: UIAssets.boxShadow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (_) => Navigator.pop(context),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.asset(ImageNames.navArrowImages.down),
                  ),
                ),
                Text(
                  'Missing Due Dates',
                  style: TextStyle(fontSize: 18, color: SKColors.alert_orange),
                ),
                SizedBox(width: 44),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text.rich(
                TextSpan(
                  text: '${datelessAssignmentIds.length} assignments',
                  children: [
                    TextSpan(
                      text: ' need due dates added to them.',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListView(
                shrinkWrap: true,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
