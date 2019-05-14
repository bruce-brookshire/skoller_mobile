import 'package:flutter/material.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:intl/intl.dart';

class _UnsavedAssignment {
  String name;
  DateTime dueDate;

  _UnsavedAssignment({@required this.name, @required this.dueDate});
}

class AssignmentBatchAddView extends StatefulWidget {
  final int class_id;
  final Weight weight;

  AssignmentBatchAddView({Key key, this.class_id, this.weight})
      : super(key: key);

  @override
  State createState() => _AssignmentBatchAddViewState();
}

class _AssignmentBatchAddViewState extends State<AssignmentBatchAddView> {
  List<_UnsavedAssignment> queuedAssignments = [];

  void tappedCreateAssignment(TapUpDetails details) async {
    final _UnsavedAssignment result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: _AddAssignmentSubview(
            weight: widget.weight,
          ),
        );
      },
    );

    if (result != null) {
      int index = queuedAssignments
          .indexWhere((element) => element.dueDate.isAfter(result.dueDate));

      setState(() {
        queuedAssignments.insert(
            index == -1 ? queuedAssignments.length : index, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.class_id];

    List<Widget> children = [
      createInfoContainer(),
    ];

    if (queuedAssignments.length > 0) {
      children.add(createAssignmentQueueContainer(studentClass));
    }

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: children,
    );
  }

  Widget createInfoContainer() {
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
                Text.rich(
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
                )
              ],
            ),
          ),
          GestureDetector(
            onTapUp: tappedCreateAssignment,
            child: Container(
              margin: EdgeInsets.fromLTRB(12, 8, 12, 12),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: SKColors.skoller_blue,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                'Add Assignment',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createAssignmentQueueContainer(StudentClass studentClass) {
    if (queuedAssignments.length == 0) {
      return null;
    }
    final dateFormatter = DateFormat('EEE, MMM d');

    final listElements = queuedAssignments.map((assignment) {
      final due = assignment.dueDate;
      final name = assignment.name;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            name,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            due == null ? 'Not due' : dateFormatter.format(due),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ]),
      );
    }).toList();

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
                'Added Assignments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(
              child: ListView(children: listElements),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: SKColors.success,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AddAssignmentSubview extends StatefulWidget {
  final Weight weight;

  _AddAssignmentSubview({Key key, @required this.weight}) : super(key: key);

  @override
  State createState() => _AddAssignmentSubviewState();
}

class _AddAssignmentSubviewState extends State<_AddAssignmentSubview> {
  DateTime dueDate;

  bool isValidState = false;

  TextEditingController textFieldController = TextEditingController();

  checkState() {
    bool prevState = isValidState;
    bool newState = textFieldController.text.trim() != "" && dueDate != null;
    if (prevState != newState) {
      setState(() {
        isValidState = newState;
      });
    }
  }

  void tappedDateSelector(TapUpDetails details) {
    final now = DateTime.now();

    SKCalendarPicker.presentDateSelector(
            title: 'Due Date',
            subtitle: 'When is this assignment due?',
            context: context,
            startDate: DateTime(now.year, now.month, now.day))
        .then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          dueDate = selectedDate;
          checkState();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            // padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text.rich(
              TextSpan(
                text: '', // default text style
                children: <TextSpan>[
                  TextSpan(
                      text: 'Add: ',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16)),
                  TextSpan(
                      text: widget.weight == null
                          ? 'Not graded'
                          : widget.weight.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 8),
            child: TextField(
              controller: textFieldController,
              decoration: InputDecoration(hintText: 'Assignment name'),
              style: TextStyle(fontSize: 14),
              onChanged: (newStr) {
                checkState();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Due date: ',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
                GestureDetector(
                  onTapUp: tappedDateSelector,
                  child: Text(
                    dueDate == null
                        ? 'Select date'
                        : DateFormat('EEE, MMMM d').format(dueDate),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: SKColors.skoller_blue),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTapUp: (details) {
              if (isValidState) {
                final newAssignment = _UnsavedAssignment(
                    name: textFieldController.text, dueDate: dueDate);

                Navigator.pop(context, newAssignment);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: SKColors.skoller_blue,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Add Assignment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
