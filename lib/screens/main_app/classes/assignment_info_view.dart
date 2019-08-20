import 'dart:math';
import 'dart:async';
import 'dart:collection';
import 'class_detail_view.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'assignment_edit_modal.dart';
import 'package:skoller/tools.dart';
import 'assignment_notes_modal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:skoller/screens/main_app/classes/student_profile_modal.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';

class AssignmentInfoView extends StatefulWidget {
  final int assignment_id;

  AssignmentInfoView({Key key, this.assignment_id}) : super(key: key);

  @override
  State createState() => _AssignmentInfoState();
}

class _AssignmentInfoState extends State<AssignmentInfoView> {
  Assignment assignment;
  Map<int, List<Mod>> assignmentMods = {};

  final postFieldController = TextEditingController();
  final postFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    assignment = Assignment.currentAssignments[widget.assignment_id];

    for (final mod in Mod.currentMods.values) {
      if (mod.modType != ModType.newAssignment &&
          mod.parentAssignment?.id == assignment.id) {
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

  @override
  void dispose() {
    postFieldController.dispose();
    postFocusNode.dispose();
    super.dispose();
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

  void tappedEditNotes(TapUpDetails details) => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AssignmentNotesModal(
          assignment.id,
          (notes) {
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
          },
        ),
      );

  void tappedGradeSelector() async {
    final results = await showDialog(
      context: context,
      barrierDismissible: false,
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
    postFocusNode.unfocus();

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
        barrierDismissible: false,
        context: context,
        builder: (context) => AssignmentEditModal(assignment.id));

    if (results != null && results is List<Map>) {
      final loader = SKLoadingScreen.fadeIn(context);

      for (final modAction in results) {
        //If we are deleting the assignment, no need to refetch it, so we just pop it if the request is successful
        if (modAction['mod_type'] == 'delete') {
          final result = await modAction['request'];
          if (result != null && result) {
            DartNotificationCenter.post(
                channel: NotificationChannels.classChanged);

            loader.dismiss();
            Navigator.pop(context);
            return;
          }
        } else {
          await modAction['request'];
        }
      }

      DartNotificationCenter.post(
          channel: NotificationChannels.assignmentChanged);

      bool response = await assignment.refetchSelf();

      if (response != null && response) {
        setState(() {
          assignment = Assignment.currentAssignments[widget.assignment_id];
        });
      }
      loader.dismiss();
    }
  }

  void tappedWithMods(List<Mod> mods, BuildContext context) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => UpdateInfoView(mods),
        settings: RouteSettings(name: 'UpdateInfoView'),
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
      callbackTitle: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                ClassDetailView(classId: assignment.parentClass.id),
            settings: RouteSettings(name: 'ClassDetailView'),
          ),
        );
      },
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
                      buildProgressDetails(context),
                      ...chatViews(),
                    ],
                  ),
                ),
              ),
              if (assignment.parentClass.enrollment >= 4)
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
    String dueDescr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = assignment.due?.difference(today)?.inDays;

    if (assignment.weight_id == null)
      weightDescr = 'Not graded';
    else if (assignment.weight == null)
      weightDescr = '';
    else
      weightDescr =
          '${NumberUtilities.formatWeightAsPercent(assignment.weight)} of your final grade';

    if (days == null)
      dueDescr = 'Not due';
    else if (days < 0)
      dueDescr = 'in the past';
    else if (days == 0)
      dueDescr = 'Today';
    else if (days == 1)
      dueDescr = 'Tomorrow';
    else
      dueDescr = 'in $days days';

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
                Expanded(
                  child: Text(
                    assignment.name,
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17, color: assignment.parentClass.getColor()),
                  ),
                ),
                GestureDetector(
                  onTapUp: tappedEdit,
                  child: Container(
                    padding: EdgeInsets.only(right: 4, top: 4, left: 4),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 12, right: 12, top: 6),
                    child: Text(
                      'Due date',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: SKColors.light_gray),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 12, right: 12),
                    child: Text(assignment.due == null
                        ? 'No due date'
                        : DateFormat('E, MMM. d').format(assignment.due)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 12, right: 12),
                child: Text(
                  dueDescr,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: SKColors.light_gray),
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
              margin: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 4),
              child: null),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Impact',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: SKColors.light_gray),
                      ),
                      Text(weightDescr),
                    ],
                  ),
                ),
                SKAssignmentImpactGraph(
                  assignment.weight,
                  assignment.parentClass.getColor(),
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

  Widget buildProgressDetails(BuildContext context) {
    List<Widget> gradeElems = [
      _GradeShakeAnimation(
        onTap: tappedGradeSelector,
        text: assignment.grade == null ? '--%' : '${assignment.grade}%',
        isAlert: assignment.grade == null && assignment.completed,
      )
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
            padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'My progress',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    assignment.completed ? 'Completed' : 'Not completed',
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontWeight: FontWeight.normal,
                        fontSize: 14),
                  ),
                ),
                Switch(
                  value: assignment.completed ?? true,
                  activeColor: SKColors.skoller_blue,
                  onChanged: (val) {
                    toggleComplete();
                  },
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
                  'Grade earned',
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
            margin: EdgeInsets.only(left: 12, right: 12, bottom: 6),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: tappedEditNotes,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Assignment notes',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  Image.asset(ImageNames.navArrowImages.right)
                ],
              ),
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
    final enrollment = assignment.parentClass.enrollment;

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
                    'Chat with classmates',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            if (enrollment >= 4)
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
                    Switch(
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

    if (enrollment < 4) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: 'Chat unlocks when ',
                  children: [
                    TextSpan(
                      text:
                          '4 classmates',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' join!')
                  ],
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 4, top: 4),
                      child: Image.asset(
                          ImageNames.assignmentInfoImages.yellow_lock),
                    ),
                    ...List.generate(
                      enrollment,
                      (index) => Padding(
                        padding: EdgeInsets.all(4),
                        child: Image.asset(
                            ImageNames.peopleImages.large_person_blue),
                      ),
                    ),
                    ...List.generate(
                      4 - enrollment,
                      (index) => Padding(
                        padding: EdgeInsets.all(4),
                        child: Image.asset(
                            ImageNames.peopleImages.large_person_gray_plus),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Share your class link 👇',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
              GestureDetector(
                onTapUp: (details) => Share.share(
                    'School is hard. But this new app called Skoller makes it easy! Our class ${assignment.parentClass.name ?? ''} is already in the app. Download so we can keep up together!\n\n${assignment.parentClass.enrollmentLink}'),
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: SKColors.skoller_blue,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [UIAssets.boxShadow]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4),
                        child:
                            Image.asset(ImageNames.peopleImages.people_white),
                      ),
                      Text(
                        'Share this class',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else if (numPosts == 0) {
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
                focusNode: postFocusNode,
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
  int selectedSegment = 1;

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

class _GradeShakeAnimation extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final bool isAlert;

  _GradeShakeAnimation({this.onTap, this.text, this.isAlert = false})
      : super(key: UniqueKey());

  @override
  State<StatefulWidget> createState() => _GradeShakeAnimationState();
}

class _GradeShakeAnimationState extends State<_GradeShakeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() => setState(() {}));

    _animation = CurvedAnimation(
      curve: Curves.easeInToLinear,
      parent: _controller,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted)
            Timer(
              Duration(seconds: 3),
              () {
                if (mounted) _controller.forward(from: 0);
              },
            );
        }
      })
      ..addListener(() => setState(() {}));

    if (widget.isAlert) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ///Then you can get a shake type motion like so;
  double get translation {
    double progress = _animation.value;
    return sin(progress * pi * 3) * 0.2;
    // return Matrix4.rotationZ(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: translation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTapUp: (details) => widget.onTap(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Text(
            widget.text,
            style: TextStyle(
              color:
                  widget.isAlert ? SKColors.warning_red : SKColors.skoller_blue,
            ),
          ),
        ),
      ),
    );
  }
}
