import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
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

    return SKNavView(
      title: task.parentClass.name,
      titleColor: task.parentClass.getColor(),
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              buildAssignmentDetails(task),
              buildPersonalDetails(task),
              ...chatViews(),
            ],
          ),
        ),
        composePostView(),
      ],
    );
  }

  //------------------//
  //Assignment Details//
  //------------------//

  Widget buildAssignmentDetails(Assignment task) {
    String weightDescr;

    if (task.weight_id == null) {
      weightDescr = 'Not graded';
    } else if (task.weight == null) {
      weightDescr = '';
    } else {
      weightDescr =
          'Worth ${NumberUtilities.formatWeightAsPercent(task.weight)} of your total grade';
    }
    return Container(
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
              weightDescr,
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
                  task.getWeightName(),
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
  }

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
                          : '${widget.task.grade}%',
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

  //------------//
  //Comment Rows//
  //------------//

  List<Widget> chatViews() {
    final task = widget.task;

    //Initialize with top cell
    List<Widget> cells = [
      Container(
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              offset: Offset(0, 2.5),
              blurRadius: 4.5,
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
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
                  Container(
                    margin: EdgeInsets.only(right: 4),
                    child: Image.asset(ImageNames.assignmentInfoImages.comment),
                  ),
                  Text(
                    'Comments',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Notify me about new comments:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                      value: true,
                      onChanged: (result) {},
                      activeColor: SKColors.skoller_blue),
                ],
              ),
            )
          ],
        ),
      )
    ];

    final int numPosts = task.posts.length;

    if (numPosts == 0) {
      cells.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                offset: Offset(0, 3.5),
                blurRadius: 3,
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Text(
            'Talk about ${task.name} with your classmates here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SKColors.light_gray,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      for (var i = 0; i < task.posts.length - 1; i++) {
        final currentChat = task.posts[i];
        cells.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  offset: Offset(0, 3.5),
                  blurRadius: 3,
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 8, bottom: 4, top: 4),
                      padding: EdgeInsets.only(left: 1),
                      decoration: BoxDecoration(
                          color: SKColors.light_gray, shape: BoxShape.circle),
                      child: Text(
                        '${currentChat.student.name_first[0]}${currentChat.student.name_last[0]}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${currentChat.student.name_first} ${currentChat.student.name_last}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      DateUtilities.getPastRelativeString(
                        currentChat.inserted_at,
                      ),
                      style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 2,
                        margin: EdgeInsets.only(left: 13, right: 20),
                        color: SKColors.border_gray,
                        child: null,
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          currentChat.post,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final lastChat = task.posts.last;

      cells.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                offset: Offset(0, 3.5),
                blurRadius: 3,
              )
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 8, bottom: 4, top: 4),
                    padding: EdgeInsets.only(left: 1),
                    decoration: BoxDecoration(
                        color: SKColors.light_gray, shape: BoxShape.circle),
                    child: Text(
                      '${lastChat.student.name_first[0]}${lastChat.student.name_last[0]}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${lastChat.student.name_first} ${lastChat.student.name_last}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    DateUtilities.getPastRelativeString(
                      lastChat.inserted_at,
                    ),
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontSize: 13,
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 35),
                child: Text(
                  lastChat.post,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return cells;
  }

  //------------//
  //Compose Post//
  //------------//

  Widget composePostView() {
    return Container(
      margin: EdgeInsets.fromLTRB(6, 0, 6, 6),
      padding: EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(22)),
      height: 44,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 12, right: 4),
            child: Image.asset(ImageNames.peopleImages.person_blue),
          ),
          Expanded(
            child: Container(
              child: CupertinoTextField(
                placeholder: 'Ask your classmates a question',
                decoration: BoxDecoration(border: null),
                // decoration:
                // InputDecoration(hintText: 'Ask your classmates a question', bo),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          GestureDetector(
            onTapUp: (details) {
              //TODO post comment for assignment
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Post',
                style: TextStyle(color: SKColors.skoller_blue, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
