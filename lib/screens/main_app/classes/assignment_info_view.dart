import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';

class AssignmentInfoView extends StatefulWidget {
  final int assignment_id;

  AssignmentInfoView({Key key, this.assignment_id}) : super(key: key);

  @override
  State createState() => _AssignmentInfoViewState();
}

class _AssignmentInfoViewState extends State<AssignmentInfoView> {
  Assignment assignment;

  TextEditingController postFieldController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    assignment = Assignment.currentAssignments[widget.assignment_id];
  }

  updateGrade(double grade) {}

  void toggleComplete() {
    assignment.toggleComplete().then((response) {
      if (!response.wasSuccessful()) {
        setState(() {
          assignment.completed = !assignment.completed;
        });
      }
    });
    setState(() {
      assignment.completed = !assignment.completed;
    });
  }

  void presentGradeSelector(BuildContext context) async {
    num grade = await _GradeSelection.presentDateSelector(
      context: context,
      assignment: assignment,
    );

    if (grade != null) {
      assignment.saveGrade(grade).then((response) {
        if (response.wasSuccessful()) {
          setState(() {
            assignment.grade = response.obj.grade;
          });
        }
      });
    }
  }

  void tappedRemoveGrade(TapUpDetails details) {
    assignment.removeGrade().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          assignment.grade = null;
        });
      }
    });
  }

  void tappedPost(TapUpDetails details) {
    String currentStr = postFieldController.text.trim();

    if (currentStr.length > 0) {
      postFieldController.clear();

      assignment.savePost(currentStr).then((response) {
        if (response.wasSuccessful()) {
          setState(() {
            assignment.posts.insert(0, response.obj);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: assignment.parentClass.name,
      titleColor: assignment.parentClass.getColor(),
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 64),
                    children: <Widget>[
                      buildAssignmentDetails(),
                      buildPersonalDetails(context),
                      ...chatViews(),
                    ],
                  ),
                ),
              ),
              Align(
                child: composePostView(),
                alignment: Alignment.bottomCenter,
              )
            ],
          ),
        ),
      ],
    );
  }

  //------------------//
  //Assignment Details//
  //------------------//

  Widget buildAssignmentDetails() {
    String weightDescr;

    if (assignment.weight_id == null) {
      weightDescr = 'Not graded';
    } else if (assignment.weight == null) {
      weightDescr = '';
    } else {
      weightDescr =
          'Worth ${NumberUtilities.formatWeightAsPercent(assignment.weight)} of your total grade';
    }
    return Container(
      margin: EdgeInsets.all(12),
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
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
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
            margin: EdgeInsets.only(left: 12, right: 12, top: 6),
            child: Text(
              assignment.name,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(color: SKColors.selected_gray, width: 1))),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 6),
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
                  assignment.getWeightName(),
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
                  assignment.due == null
                      ? 'No due date'
                      : DateFormat('E, MMM. d').format(assignment.due),
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

  Widget buildPersonalDetails(BuildContext context) {
    List<Widget> gradeElems = [
      GestureDetector(
        onTapUp: (_) {
          presentGradeSelector(context);
        },
        child: Text(
          assignment.grade == null ? '--%' : '${assignment.grade}%',
          style: TextStyle(color: SKColors.skoller_blue),
        ),
      ),
    ];

    if (assignment.grade != null) {
      gradeElems.add(
        GestureDetector(
          onTapUp: tappedRemoveGrade,
          child: Container(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Remove grade',
              style: TextStyle(
                color: SKColors.warning_red,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Personal details',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  'Private info',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: gradeElems,
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
                      child: Image.asset(ImageNames.assignmentInfoImages.notes),
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
                  assignment.completed
                      ? 'Task marked as complete. '
                      : 'Completed this assignment? ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                ),
                GestureDetector(
                  onTapUp: (_) {
                    toggleComplete();
                  },
                  child: Text(
                    assignment.completed ? 'Mark undone' : 'Mark done',
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

  //------------//
  //Comment Rows//
  //------------//

  List<Widget> chatViews() {
    //Initialize with top cell
    List<Widget> cells = [
      Container(
        margin: EdgeInsets.only(top: 12, left: 12, right: 12),
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
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
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
                    margin: EdgeInsets.only(left: 4),
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
                      onChanged: (result) {
                        //TODO hook this up
                      },
                      activeColor: SKColors.skoller_blue),
                ],
              ),
            )
          ],
        ),
      )
    ];

    final int numPosts = assignment.posts.length;

    if (numPosts == 0) {
      cells.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
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
            'Talk about ${assignment.name} with your classmates here!',
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
      for (var i = 0; i < assignment.posts.length - 1; i++) {
        final currentChat = assignment.posts[i];
        cells.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
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
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 16, right: 4),
                          child: Text(
                            currentChat.post,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
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

      final lastChat = assignment.posts.last;

      cells.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
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
                margin: EdgeInsets.only(left: 35, right: 4),
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
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              offset: Offset(0, 1),
              blurRadius: 3.5,
            )
          ],
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
                placeholder: 'Write a post...',
                decoration: BoxDecoration(border: null),
                controller: postFieldController,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          GestureDetector(
            onTapUp: tappedPost,
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

class _GradeSelection extends StatefulWidget {
  final Assignment assignment;

  final TextEditingController numerator = TextEditingController();
  final TextEditingController denominator = TextEditingController();

  _GradeSelection(this.assignment);

  @override
  State createState() => _GradeSelectionState();

  static Future<num> presentDateSelector({
    @required BuildContext context,
    @required Assignment assignment,
  }) async {
    _GradeSelection controller = _GradeSelection(assignment);
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Grade',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SKColors.dark_gray,
                          fontSize: 15),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 6, top: 4),
                    child: Text(
                      'Enter what grade you made in this class',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: SKColors.dark_gray),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: null,
                          margin: EdgeInsets.only(bottom: 8),
                          height: 1.25,
                          color: SKColors.border_gray,
                        ),
                      ),
                    ],
                  ),
                  controller,
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              'Dismiss',
                              style: TextStyle(
                                  color: SKColors.skoller_blue,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            String grade = controller.numerator.text.trim();
                            String basis = controller.denominator.text.trim();

                            if (grade.length != 0) {
                              int grade_num = int.tryParse(grade);
                              int basis_num =
                                  int.tryParse(basis == '' ? '100' : basis);

                              Navigator.pop(
                                  context, (grade_num / basis_num) * 100);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              'Select',
                              style: TextStyle(color: SKColors.skoller_blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _GradeSelectionState extends State<_GradeSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Center(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: CupertinoTextField(
                      placeholder: '100',
                      controller: widget.numerator,
                      keyboardType: TextInputType.number,
                      //TODO has this been fixed on Flutter yet?
                      // textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    )),
              ),
              Text('out of'),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: CupertinoTextField(
                    placeholder: '100',
                    controller: widget.denominator,
                    keyboardType: TextInputType.number,
                    //TODO has this been fixed on Flutter yet?
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
