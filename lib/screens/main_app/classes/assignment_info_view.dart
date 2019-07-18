import 'dart:collection';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:skoller/screens/main_app/classes/student_profile_modal.dart';
import 'package:skoller/tools.dart';
import '../activity/update_info_view.dart';

class AssignmentInfoView extends StatefulWidget {
  final int assignment_id;

  AssignmentInfoView({Key key, this.assignment_id}) : super(key: key);

  @override
  State createState() => _AssignmentInfoState();
}

class _AssignmentInfoState extends State<AssignmentInfoView> {
  Assignment assignment;
  Map<int, List<Mod>> assignmentMods = {};

  TextEditingController postFieldController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    assignment = Assignment.currentAssignments[widget.assignment_id];

    for (final mod in Mod.currentMods.values) {
      if (mod.modType != ModType.newAssignment && mod.parentAssignment?.id == assignment.id) {
        if (assignmentMods[mod.modType.index] == null) {
          assignmentMods[mod.modType.index] = [];
        }
        assignmentMods[mod.modType.index].add(mod);
      }
    }

    List<int> removalKeys = [];

    for (final key in assignmentMods.keys) {
      bool shouldRemove = true;

      for (final mod in assignmentMods[key])
        if (mod.isAccepted == null) shouldRemove = false;

      if (shouldRemove) removalKeys.add(key);
    }

    removalKeys.forEach((key) => assignmentMods.remove(key));
  }

  void toggleComplete() {
    assignment.toggleComplete().then((success) {
      if (!success) {
        setState(() {
          assignment.completed = !assignment.completed;
        });
      }
    });
    setState(() {
      assignment.completed = !assignment.completed;
    });
  }

  void tappedEditNotes(TapUpDetails details) async {
    TextEditingController controller =
        TextEditingController(text: assignment.notes);

    final successful = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTapUp: (details) {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: SKColors.warning_red,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Personal Notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTapUp: (details) {
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          padding: EdgeInsets.only(right: 8),
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(8),
                  child: CupertinoTextField(
                    decoration: BoxDecoration(border: null),
                    maxLength: 2000,
                    maxLengthEnforced: true,
                    autofocus: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: controller,
                    placeholder: 'Add a note...',
                    style: TextStyle(
                        color: SKColors.dark_gray,
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (successful != null && successful) {
      String notes = controller.text.trim();
      assignment.saveNotes(notes == '' ? null : notes).then((success) {
        if (success) {
          setState(() {
            assignment.notes =
                Assignment.currentAssignments[assignment.id].notes;
          });
        } else {
          DropdownBanner.showBanner(
            text: 'Failed to save notes',
            color: SKColors.warning_red,
            textStyle: TextStyle(color: Colors.white),
          );
        }
      });
    }
  }

  void tappedGradeSelector(TapUpDetails details) async {
    final results = await showDialog(
      context: context,
      builder: (context) => _GradeSelection(assignment),
    );

    if (results is _GradePickerResults) {
      num gradeToSave;

      if (results.selectedSegment == 0) {
        String grade = results.numerator.trim();
        String basis = results.denominator.trim();

        if (grade.length != 0) {
          int grade_num = int.tryParse(grade);
          int basis_num = int.tryParse(basis == '' ? '100' : basis);

          gradeToSave = (grade_num / basis_num) * 100;
        }
      } else {
        gradeToSave = results.picker_digit + (results.picker_decimal / 10);
      }

      if (gradeToSave != null) {
        assignment.saveGrade(gradeToSave).then((response) {
          if (response.wasSuccessful()) {
            setState(() {
              assignment.grade = response.obj.grade;
            });
          }
        });
        setState(() {
          assignment.grade = gradeToSave;
        });
      }
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
        } else {
          DropdownBanner.showBanner(
            text: 'Failed to create post',
            color: SKColors.warning_red,
            textStyle: TextStyle(color: Colors.white),
          );
        }
      });
    }
  }

  void tappedToggleNotifications(bool enabled) {
    assignment.togglePostNotifications().then((success) {
      if (!success) {
        setState(() {
          assignment.isPostNotifications = !assignment.isPostNotifications;
        });
      }
    });
    setState(() {
      assignment.isPostNotifications = !assignment.isPostNotifications;
    });
  }

  void tappedEdit(TapUpDetails details) async {
    final results = await showDialog(
        context: context,
        builder: (context) => _AssignmentEditModal(assignment.id));

    if (results != null && results is List<Map>) {
      for (final modAction in results) {
        //If we are deleting the assignment, no need to refetch it, so we just pop it if the request is successful
        if (modAction['mod_type'] == 'delete') {
          final result = await modAction['request'];
          if (result != null && result) {
            DartNotificationCenter.post(
                channel: NotificationChannels.assignmentChanged);
            Navigator.pop(context);
            return;
          }
        }
        DartNotificationCenter.post(
            channel: NotificationChannels.assignmentChanged);
      }
    }

    bool response = await assignment.fetchSelf();

    if (response != null && response) {
      setState(() {
        assignment = Assignment.currentAssignments[widget.assignment_id];
      });
    }
  }

  void tappedWithMods(List<Mod> mods, BuildContext context) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => UpdateInfoView(mods),
      ),
    );
  }

  void tappedCheckUpdates(TapUpDetails _) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'Assignment updates',
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              ...assignmentMods.keys
                  .map((k) {
                    if (k == ModType.delete.index)
                      return {
                        'name': 'Delete',
                        'image': ImageNames.activityImages.delete_white,
                        'mods': assignmentMods[k],
                      };
                    else if (k == ModType.weight.index)
                      return {
                        'name': 'Grading category',
                        'image': ImageNames.activityImages.weight_white,
                        'mods': assignmentMods[k],
                      };
                    else if (k == ModType.due.index)
                      return {
                        'name': 'Due date',
                        'image': ImageNames.activityImages.due_white,
                        'mods': assignmentMods[k],
                      };
                    return null;
                  })
                  .map(
                    (c) => GestureDetector(
                      onTapUp: (details) => tappedWithMods(c['mods'], context),
                      child: Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: SKColors.border_gray),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 24,
                              height: 24,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: assignment.parentClass.getColor(),
                              ),
                              child: Image.asset(c['image']),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(c['name']),
                              ),
                            ),
                            Image.asset(ImageNames.navArrowImages.right),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
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
                      if (assignmentMods.length > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTapUp: tappedCheckUpdates,
                              child: Container(
                                margin: EdgeInsets.only(top: 2, bottom: 12),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [UIAssets.boxShadow],
                                ),
                                height: 44,
                                child: Text(
                                  'Pending updates',
                                  style: TextStyle(color: SKColors.warning_red),
                                ),
                              ),
                            ),
                          ],
                        ),
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
          'Worth ${NumberUtilities.formatWeightAsPercent(assignment.weight)} of grade';
    }
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.only(bottom: 12),
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
                  'Details',
                  style: TextStyle(fontSize: 17),
                ),
                GestureDetector(
                  onTapUp: tappedEdit,
                  child: Container(
                    padding: EdgeInsets.only(right: 4, top: 4),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: SKColors.skoller_blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 12, right: 12, top: 6),
            child: Text(
              'Assignment name',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: SKColors.light_gray),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 12, right: 12),
                child: Text(assignment.name),
              ),
              Container(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  weightDescr,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: SKColors.dark_gray),
                ),
              ),
            ],
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: SKColors.selected_gray, width: 1))),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 6),
              margin: EdgeInsets.only(left: 12, right: 12, top: 1),
              child: null),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Grading category',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: SKColors.light_gray),
                ),
                Text(
                  'Due date',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: SKColors.light_gray),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    assignment.getWeightName(),
                  ),
                ),
                Text(
                  assignment.due == null
                      ? 'No due date'
                      : DateFormat('E, MMM. d').format(assignment.due),
                ),
              ],
            ),
          ),
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
        onTapUp: tappedGradeSelector,
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
                  'Private info',
                  style: TextStyle(fontSize: 17),
                ),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: tappedEditNotes,
              child: Row(
                children: <Widget>[
                  Image.asset(ImageNames.assignmentInfoImages.notes),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Assignment notes',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            (assignment.notes ?? '').length == 0
                                ? 'Tap to add a personal note'
                                : assignment.notes,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                  ),
                  Image.asset(ImageNames.navArrowImages.right)
                ],
              ),
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
                      value: assignment.isPostNotifications,
                      onChanged: tappedToggleNotifications,
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => showDialog(
              context: context,
              builder: (context) => StudentProfileModal(currentChat.student),
            ),
            child: Container(
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
                            padding: EdgeInsets.only(bottom: 8, right: 4),
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
          ),
        );
      }

      final lastChat = assignment.posts.last;

      cells.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => showDialog(
            context: context,
            builder: (context) => StudentProfileModal(lastChat.student),
          ),
          child: Container(
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

  _GradeSelection(this.assignment);

  @override
  State createState() => _GradeSelectionState();
}

class _GradePickerResults {
  //Active segment
  int selectedSegment = 0;

  //Fields
  String numerator = '';
  String denominator = '';

  //Picker
  num picker_digit = 100;
  num picker_decimal = 0;
}

class _GradeSelectionState extends State<_GradeSelection> {
  final _GradePickerResults results = _GradePickerResults();

  @override
  Widget build(BuildContext context) {
    List<Widget> segmentElements = [
      Container(
        child: Row(
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: CupertinoTextField(
                  placeholder: '100',
                  keyboardType: TextInputType.number,
                  onChanged: (newStr) => results.numerator = newStr,
                  textAlign: TextAlign.center,
                  cursorColor: SKColors.skoller_blue,
                  autofocus: true,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Container(
              height: 148,
              alignment: Alignment.center,
              child: Text(
                'out of',
                style: TextStyle(color: SKColors.dark_gray, fontSize: 15),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: CupertinoTextField(
                  placeholder: '100',
                  onChanged: (newStr) => results.denominator = newStr,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  cursorColor: SKColors.skoller_blue,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Spacer(),
            Container(
              height: 140,
              width: 44,
              // color: Colors.white,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                childCount: 101,
                itemBuilder: (context, index) => Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${100 - index}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SKColors.dark_gray,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemExtent: 24,
                onSelectedItemChanged: (index) {
                  results.picker_digit = 100 - index;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('.'),
            ),
            Container(
              height: 140,
              width: 20,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                childCount: 10,
                itemBuilder: (context, index) => Text(
                  '${(index) % 10}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SKColors.dark_gray,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                itemExtent: 24,
                onSelectedItemChanged: (index) {
                  results.picker_decimal = (index) % 10;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 6),
              child: Text('%'),
            ),
            Spacer(),
          ],
        ),
      ),
    ];

    return SKAlertDialog(
      title: 'Add a grade',
      subTitle: 'What grade did you make on this assignment?',
      confirmText: 'Save',
      getResults: () => results,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoSegmentedControl(
                children: LinkedHashMap.fromIterables(
                  [0, 1],
                  [
                    Text('Points', style: TextStyle(fontSize: 14)),
                    Text('Percentage', style: TextStyle(fontSize: 14))
                  ],
                ),
                onValueChanged: (newKey) {
                  setState(() {
                    results.selectedSegment = newKey;
                  });
                },
                groupValue: results.selectedSegment,
                selectedColor: SKColors.skoller_blue,
                borderColor: SKColors.skoller_blue,
              ),
              segmentElements[results.selectedSegment]
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentEditModal extends StatefulWidget {
  final int assignment_id;

  _AssignmentEditModal(this.assignment_id);

  @override
  State createState() => _AssignmentEditModalState();
}

class _AssignmentEditModalState extends State<_AssignmentEditModal> {
  DateTime selectedDate;
  Weight selectedWeight;

  bool isPrivate = false;

  bool shouldDelete = false;

  Assignment assignment;

  @override
  void initState() {
    super.initState();
    assignment = Assignment.currentAssignments[widget.assignment_id];
    selectedDate = assignment.due;

    for (final Weight weight in assignment.parentClass.weights) {
      if (assignment.weight_id == weight.id) {
        selectedWeight = weight;
        break;
      }
    }
  }

  void tappedDueDate(TapUpDetails details) async {
    final result = await SKCalendarPicker.presentDateSelector(
        title: 'Due date',
        subtitle: 'When is this assignment due?',
        context: context,
        startDate: selectedDate);

    if (result != null && result is DateTime) {
      setState(() {
        selectedDate = result;
        shouldDelete = false;
      });
    }
  }

  void tappedWeight(TapUpDetails details) async {
    List<Weight> classWeights = assignment.parentClass.weights;

    Weight tempWeight = classWeights.first;

    final bool result = await showDialog(
      context: context,
      builder: (context) => SKAlertDialog(
        title: 'Grading category',
        subTitle: 'Select how this assignment is graded',
        child: Container(
          height: 160,
          child: CupertinoPicker.builder(
            backgroundColor: Colors.white,
            childCount: classWeights.length,
            itemExtent: 24,
            itemBuilder: (context, index) => Container(
              alignment: Alignment.center,
              child: Text(
                classWeights[index].name,
                style: TextStyle(
                  color: SKColors.dark_gray,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelectedItemChanged: (index) => tempWeight = classWeights[index],
          ),
        ),
      ),
    );

    if (result != null && result) {
      setState(() {
        this.selectedWeight = tempWeight;
        shouldDelete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment,
          children: [
            Text(
              'Edit assignment details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
            Container(
              child: null,
              margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
              height: 1.25,
              color: SKColors.border_gray,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Due date',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: SKColors.light_gray),
                      ),
                      GestureDetector(
                        onTapUp: tappedDueDate,
                        child: Text(
                          selectedDate == null
                              ? 'No due date'
                              : DateFormat('E, MMM. d').format(selectedDate),
                          style: TextStyle(color: SKColors.skoller_blue),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Graded as',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: SKColors.light_gray),
                        ),
                        GestureDetector(
                          onTapUp: tappedWeight,
                          child: Text(
                            selectedWeight.name,
                            style: TextStyle(color: SKColors.skoller_blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Share changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                      value: !isPrivate,
                      onChanged: (value) {
                        setState(() {
                          isPrivate = !value;
                        });
                      },
                      activeColor: SKColors.skoller_blue),
                ],
              ),
            ),
            GestureDetector(
              onTapUp: (details) {
                setState(() {
                  shouldDelete = !shouldDelete;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: SKColors.warning_red),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                margin: EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(ImageNames.assignmentInfoImages.trash),
                    Container(
                      width: 4,
                      child: null,
                    ),
                    Text(
                      shouldDelete ? 'Cancel' : 'Delete',
                      style: TextStyle(color: SKColors.warning_red),
                    ),
                  ],
                ),
              ),
            ),
            createActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget createActionButton(BuildContext context) {
    Widget child;
    Color backgroundColor;

    if (shouldDelete) {
      backgroundColor = SKColors.warning_red;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              isPrivate
                  ? ImageNames.peopleImages.person_white
                  : ImageNames.peopleImages.people_white,
            ),
          ),
          Text(
            'Delete this assignment',
            style: TextStyle(color: Colors.white),
          )
        ],
      );
    } else if (selectedDate.isAtSameMomentAs(assignment.due) &&
        selectedWeight.id == assignment.weight_id)
    //Basically, show a gray button if the user has not changed any of the assignment details
    {
      backgroundColor = SKColors.text_light_gray;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              isPrivate
                  ? ImageNames.peopleImages.person_white
                  : ImageNames.peopleImages.people_white,
            ),
          ),
          Text(
            isPrivate ? 'Save updates' : 'Share updates',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    } else {
      backgroundColor = isPrivate ? SKColors.skoller_blue : SKColors.success;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              isPrivate
                  ? ImageNames.peopleImages.person_white
                  : ImageNames.peopleImages
                      .people_white, /*scale: isPrivate ? 1.35 : 1,*/
            ),
          ),
          Text(
            isPrivate ? 'Save updates' : 'Share updates',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        List<Map> requests = [];
        if (shouldDelete) {
          requests.add({
            'request': assignment.delete(isPrivate),
            'mod_type': 'delete',
          });
        } else {
          if (!selectedDate.isAtSameMomentAs(assignment.due)) {
            requests.add({
              'request': assignment.updateDueDate(
                isPrivate,
                selectedDate,
              ),
              'mod_type': 'due_date',
            });
          }
          if (selectedWeight.id != assignment.weight_id) {
            requests.add({
              'request': assignment.updateWeightCategory(
                isPrivate,
                selectedWeight,
              ),
              'mod_type': 'weight',
            });
          }
        }

        Navigator.pop(context, requests);
      },
      child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
          ),
          height: 32,
          margin: EdgeInsets.only(top: 12),
          child: child),
    );
  }
}
