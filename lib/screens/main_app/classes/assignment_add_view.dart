import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:intl/intl.dart';

class AssignmentAddView extends StatefulWidget {
  final int class_id;
  final Weight weight;

  AssignmentAddView(this.class_id, this.weight, {Key key}) : super(key: key);

  @override
  State createState() => _AssignmentAddState();
}

class _AssignmentAddState extends State<AssignmentAddView> {
  DateTime dueDate;

  String assignmentName;

  bool isPrivate = false;

  void tappedDateSelector(TapUpDetails details) {
    final now = DateTime.now();

    SKCalendarPicker.presentDateSelector(
      title: 'Due Date',
      subtitle: 'When is this assignment due?',
      context: context,
      startDate: DateTime(now.year, now.month, now.day),
      onSelect: (selectedDate) {
        setState(() {
          dueDate = selectedDate;
        });
      },
    );
  }

  bool validState() {
    return assignmentName != null && dueDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.class_id];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        createInfoContainer(),
        createCurrentAssignments(studentClass),
      ],
    );
  }

  Widget createInfoContainer() {
    final isValid = validState();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SKColors.border_gray),
        boxShadow: [UIAssets.boxShadow],
      ),
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
                color: SKColors.selected_gray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )),
            padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 8, left: 4),
                  child: Image.asset(ImageNames.peopleImages.people_gray),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '', // default text style
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Add: ',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 15)),
                        TextSpan(
                            text: widget.weight == null
                                ? 'Not graded'
                                : widget.weight.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 4),
            child: TextField(
              decoration: InputDecoration(hintText: 'Assignment name'),
              style: TextStyle(fontSize: 14),
              textCapitalization: TextCapitalization.words,
              onChanged: (newStr) {
                String trimmedString = newStr.trim();
                bool makeNull =
                    trimmedString == "" && this.assignmentName != null;

                if (makeNull) {
                  setState(() {
                    this.assignmentName = null;
                  });
                } else if (this.assignmentName == null) {
                  setState(() {
                    this.assignmentName = trimmedString;
                  });
                } else {
                  this.assignmentName = trimmedString;
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Due date',
                    style: TextStyle(fontWeight: FontWeight.normal)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: tappedDateSelector,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dueDate == null
                          ? 'Select date'
                          : DateFormat('EEE, MMMM d').format(dueDate),
                      style:
                          TextStyle(fontSize: 15, color: SKColors.skoller_blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Share with classmates',
                    style: TextStyle(fontWeight: FontWeight.normal)),
                CupertinoSwitch(
                  onChanged: (newVal) => setState(() => isPrivate = !newVal),
                  value: !isPrivate,
                  activeColor: SKColors.skoller_blue,
                )
              ],
            ),
          ),
          GestureDetector(
            onTapUp: (details) {
              if (isValid) {
                final loadingScreen = SKLoadingScreen.fadeIn(context);

                StudentClass.currentClasses[widget.class_id]
                    .createAssignment(
                        assignmentName, widget.weight, dueDate, isPrivate)
                    .then((response) async {
                  loadingScreen.dismiss();

                  if (response.wasSuccessful()) {
                    await StudentClass.currentClasses[widget.class_id]
                        .refetchSelf();

                    DartNotificationCenter.post(
                        channel: NotificationChannels.assignmentChanged);
                    Navigator.pop(context);
                  } else {
                    DropdownBanner.showBanner(
                      text: 'Failed to create assignment',
                      color: SKColors.warning_red,
                      textStyle: TextStyle(color: Colors.white),
                    );
                  }
                });
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(12, 8, 12, 12),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: isValid
                      ? (isPrivate ? SKColors.skoller_blue : SKColors.success)
                      : SKColors.inactive_gray,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    padding: EdgeInsets.only(right: 8),
                    child: Image.asset(isPrivate
                        ? (isValid
                            ? ImageNames.peopleImages.person_white
                            : ImageNames.peopleImages.person_dark_gray)
                        : (isValid
                            ? ImageNames.peopleImages.people_white
                            : ImageNames.peopleImages.people_gray)),
                  ),
                  Text(
                    isPrivate ? 'Keep private' : 'Share assignment',
                    style: TextStyle(
                      color: isValid ? Colors.white : SKColors.dark_gray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createCurrentAssignments(StudentClass studentClass) {
    final weightId = widget.weight == null ? null : widget.weight.id;
    final weightAssignments = (studentClass.assignments ?? []).toList();
    final dateFormatter = DateFormat('EEE, MMM d');

    weightAssignments
        .removeWhere((assignment) => weightId != assignment.weight_id);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SKColors.border_gray),
          boxShadow: [UIAssets.boxShadow],
        ),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: SKColors.selected_gray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )),
              padding: EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Text(
                'Current Assignments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: weightAssignments.length,
                itemBuilder: (BuildContext context, int index) {
                  final due = weightAssignments[index].due;
                  final name = weightAssignments[index].name;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        due == null ? 'Not due' : dateFormatter.format(due),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
