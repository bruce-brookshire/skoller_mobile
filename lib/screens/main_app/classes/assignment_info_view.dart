import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';

class AssignmentInfoView extends StatefulWidget {
  final Assignment task;

  AssignmentInfoView({Key key, this.task}) : super(key: key);

  @override
  State createState() => _AssignmentInfoViewState();
}

class _AssignmentInfoViewState extends State<AssignmentInfoView> {
  updateGrade(double grade) {}

  toggleComplete() {
    widget.task.toggleComplete().then((response) {
      if (!response.wasSuccessful()) {
        setState(() {
          widget.task.completed = !widget.task.completed;
        });
      }
    });
    setState(() {
      widget.task.completed = !widget.task.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: SKColors.background_gray,
          child: Center(
            child: Column(
              children: <Widget>[
                SKNavBar(
                  task.parentClass.name,
                  backBtnEnabled: true,
                  titleColor: task.parentClass.getColor(),
                ),
                buildAssignmentDetails(task),
                buildPersonalDetails(task)
              ],
            ),
          ),
        ),
      ),
    );
  }

  //------------------//
  //Assignment Details//
  //------------------//

  Widget buildAssignmentDetails(Assignment task) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: SKColors.selected_gray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: <Widget>[
                  Text(
                    'Assignment details',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 12, right: 12, top: 4),
              child: Text(
                task.name,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: SKColors.selected_gray, width: 1))),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 4),
              margin: EdgeInsets.only(left: 12, right: 12, top: 1),
              child: Text(
                task.weight_id == null
                    ? 'Not graded'
                    : 'Worth ${NumberUtilities.formatWeightAsPercentage(task.weight)} of your total grade',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: SKColors.selected_gray, width: 1))),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Grading category:',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Text(
                    task.weight_id == null ? 'Not graded' : '${task.weight_id}',
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12, right: 12, bottom: 6),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Due date:',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Text(
                    task.due == null
                        ? 'No due date'
                        : DateFormat('E, MMM. d').format(task.due),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  //----------------//
  //Personal Details//
  //----------------//

  Widget buildPersonalDetails(Assignment task) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: SKColors.selected_gray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Personal details',
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    'Private info',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: SKColors.selected_gray, width: 1))),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Grade earned:',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  GestureDetector(
                    onTapUp: (_) {
                      print('hi');
                    },
                    child: Text(
                      widget.task.grade == null
                          ? '--%'
                          : NumberUtilities.formatWeightAsPercentage(
                              widget.task.grade),
                      style: TextStyle(color: SKColors.skoller_blue),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: SKColors.selected_gray, width: 1))),
              margin: EdgeInsets.only(left: 12, right: 12, bottom: 6),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 32,
                        width: 32,
                        padding: EdgeInsets.only(right: 8),
                        child:
                            Image.asset(ImageNames.assignmentInfoImages.notes),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Notes',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'Tap to add a personal note',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ],
                  ),
                  Image.asset(ImageNames.navArrowImages.right)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    task.completed
                        ? 'Task marked as complete. '
                        : 'Completed this assignment? ',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                  GestureDetector(
                    onTapUp: (_) {
                      toggleComplete();
                    },
                    child: Text(
                      task.completed ? 'Mark undone' : 'Mark done',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: SKColors.skoller_blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
