import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import 'package:skoller/screens/main_app/classes/weights_info_view.dart';
import 'package:skoller/screens/main_app/menu/major_search_modal.dart';
import 'package:skoller/tools.dart';

import './modals/assignment_edit_modal.dart';
import './modals/assignment_notes_modal.dart';
import 'class_detail_view.dart';

class AssignmentInfoView extends StatefulWidget {
  final int? assignmentId;

  AssignmentInfoView({Key? key, this.assignmentId}) : super(key: key);

  @override
  State createState() => _AssignmentInfoState();
}

class _AssignmentInfoState extends State<AssignmentInfoView> {
  Assignment? assignment;
  Map<int, List<Mod>> assignmentMods = {};

  final postFieldController = TextEditingController();
  final postFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    assignment = Assignment.currentAssignments[widget.assignmentId];

    for (final mod in Mod.currentMods.values) {
      if (mod.modType != ModType.newAssignment &&
          mod.parentAssignment!.id == assignment!.id) {
        if (assignmentMods[mod.modType.index] == null) {
          assignmentMods[mod.modType.index] = [];
        }
        assignmentMods[mod.modType.index]!.add(mod);
      }
    }

    List<int> removalKeys = [];

    for (final key in assignmentMods.keys) {
      bool shouldRemove = true;

      for (final mod in assignmentMods[key]!)
        if (mod.isAccepted == null) shouldRemove = false;

      if (shouldRemove) removalKeys.add(key);
    }

    removalKeys.forEach((key) => assignmentMods.remove(key));

    DartNotificationCenter.subscribe(
      channel: NotificationChannels.assignmentChanged,
      observer: this,
      onNotification: (_) => setState(
        () => assignment = Assignment.currentAssignments[assignment!.id],
      ),
    );
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);

    postFieldController.dispose();
    postFocusNode.dispose();

    super.dispose();
  }

  void toggleComplete() {
    assignment!.toggleComplete().then((success) {
      if (!success) {
        setState(() {
          assignment!.isCompleted = !assignment!.isCompleted!;
        });
      } else
        DartNotificationCenter.post(
            channel: NotificationChannels.assignmentChanged);
    });
    setState(() {
      assignment!.isCompleted = !assignment!.isCompleted!;
    });
  }

  void tappedEditNotes(TapUpDetails details) => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AssignmentNotesModal(
          assignment!.id,
          (notes) {
            assignment?.saveNotes(notes == '' ? null : notes).then((success) {
              if (success) {
                setState(() {
                  assignment!.notes =
                      Assignment.currentAssignments[assignment!.id]!.notes;
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
      builder: (context) => _GradeSelection(assignment!),
    );

    if (results is _GradePickerResults) {
      late num gradeToSave;

      if (results.selectedSegment == 0) {
        String grade = results.numerator.trim();
        String basis = results.denominator.trim();

        if (grade.length != 0) {
          int grade_num = int.tryParse(grade)!;
          int basis_num = int.tryParse(basis == '' ? '100' : basis)!;

          gradeToSave = (grade_num / basis_num) * 100;
        }
      } else {
        gradeToSave = results.picker_digit + (results.picker_decimal / 10);
      }

      if (gradeToSave != null) {
        assignment!.saveGrade(gradeToSave).then((response) {
          if (response.wasSuccessful()) {
            setState(() => assignment!.grade = response.obj.grade);
            DartNotificationCenter.post(
              channel: NotificationChannels.classChanged,
            );
          }
        });
        setState(() => assignment!.grade = gradeToSave.toDouble());
      }
    }
  }

  void tappedRemoveGrade(TapUpDetails details) {
    assignment!.removeGrade().then((response) {
      if (response.wasSuccessful()) {
        setState(() => assignment!.grade = null);
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);
      }
    });
  }

  void tappedPost(TapUpDetails details) {
    String currentStr = postFieldController.text.trim();
    postFocusNode.unfocus();

    if (currentStr.length > 0) {
      postFieldController.clear();

      assignment!.savePost(currentStr).then((response) {
        if (response.wasSuccessful()) {
          setState(() {
            assignment!.posts!.insert(0, response.obj);
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
    assignment!.togglePostNotifications().then((success) {
      if (!success) {
        setState(() {
          assignment!.isPostNotifications = !assignment!.isPostNotifications;
        });
      }
    });
    setState(() {
      assignment!.isPostNotifications = !assignment!.isPostNotifications;
    });
  }

  void tappedEdit(TapUpDetails details) async {
    final results = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AssignmentEditModal(assignment!.id));

    if (results != null && results is List<Map>) {
      final loader = SKLoadingScreen.fadeIn(context);

      for (final modAction in results) {
        //If we are deleting the assignment, no need to refetch it, so we just pop it if the request is successful
        if (modAction['mod_type'] == 'delete') {
          final result = await modAction['request'];
          if (result != null && result) {
            DartNotificationCenter.post(
                channel: NotificationChannels.classChanged);

            loader.fadeOut();
            Navigator.pop(context);
            return;
          }
        } else
          await modAction['request'];
      }

      DartNotificationCenter.post(
          channel: NotificationChannels.assignmentChanged);

      bool response = await assignment!.refetchSelf();

      if (response != null && response) {
        setState(() =>
            assignment = Assignment.currentAssignments[widget.assignmentId]);
      }
      loader.fadeOut();
    }
  }

  void tappedAddDueDate(_) async {
    SKCalendarPicker.presentDateSelector(
      title: 'Due date',
      subtitle: 'When is this assignment due?',
      context: context,
      startDate: DateTime.now(),
      onSave: (selectedDate, context) async {
        final loader = SKLoadingScreen.fadeIn(context);
        final result = await assignment!.addDueDate(selectedDate);

        if (result.wasSuccessful()) {
          if (await assignment!.refetchSelf())
            setState(() => assignment =
                Assignment.currentAssignments[widget.assignmentId]);

          loader.fadeOut();
          DartNotificationCenter.post(
              channel: NotificationChannels.assignmentChanged);
        }
      },
    );
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
                      onTapUp: (details) =>
                          tappedWithMods(c!['mods'] as List<Mod>, context),
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
                                color: assignment!.parentClass.getColor(),
                              ),
                              child: Image.asset(c!['image'].toString()),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(c['name'].toString()),
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

  void tappedImpactExplanation(_) {
    showDialog(
      context: context,
      builder: (context) => _SKImpactGraphDescriptionModal(assignment!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: assignment!.parentClass.name!,
      titleColor: assignment!.parentClass.getColor(),
      callbackTitle: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                ClassDetailView(classId: assignment!.parentClass.id),
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
                                  boxShadow: UIAssets.boxShadow,
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
                      buildJobView(),
                    ],
                  ),
                ),
              ),
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

    final days = assignment?.due?.difference(today).inDays;

    if (assignment!.weight_id == null)
      weightDescr = 'Not graded';
    else if (assignment!.weight == null)
      weightDescr = '';
    else
      weightDescr =
          '${NumberUtilities.formatWeightAsPercent(assignment!.weight!)} of your final grade';

    if (days == null)
      dueDescr = '';
    else if (days < 0)
      dueDescr = 'In the past';
    else if (days == 0)
      dueDescr = 'Due today';
    else if (days == 1)
      dueDescr = 'Due tomorrow';
    else
      dueDescr = 'Due in $days days';

    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: UIAssets.boxShadow,
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
                  child: Hero(
                    tag: 'TaskName${assignment!.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        assignment!.name ?? '',
                        // maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: assignment!.parentClass.getColor(),
                        ),
                      ),
                    ),
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
                  assignment!.due == null
                      ? GestureDetector(
                          onTapUp: tappedAddDueDate,
                          child: Container(
                            margin: EdgeInsets.only(left: 12, right: 12),
                            child: Text(
                              'Add due date',
                              style: TextStyle(color: SKColors.alert_orange),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(left: 12, right: 12),
                          child: Text(
                            DateFormat('EEEE, MMMM d').format(assignment!.due!),
                          ),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: tappedImpactExplanation,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Impact',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: SKColors.light_gray),
                            ),
                            Icon(
                              Icons.help_outline,
                              size: 14,
                              color: SKColors.skoller_blue,
                            )
                          ],
                        ),
                        Text(weightDescr),
                      ],
                    ),
                  ),
                  SKAssignmentImpactGraph(
                    assignment!.weight,
                    assignment!.parentClass.getColor(),
                  ),
                ],
              ),
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
        text: assignment!.grade == null ? '--%' : '${assignment!.grade}%',
        isAlert: assignment!.grade == null && assignment!.isCompleted!,
      )
    ];

    if (assignment!.grade != null)
      gradeElems.add(
        GestureDetector(
          onTapUp: tappedRemoveGrade,
          child: Container(
            padding: EdgeInsets.only(top: 0),
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: UIAssets.boxShadow,
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
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 6),
                    child: Text(
                      'My progress',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                if (assignment!.due != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      assignment!.isCompleted! ? 'Completed' : 'Not completed',
                      style: TextStyle(
                          color: SKColors.light_gray,
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: assignment!.isCompleted ?? true,
                    activeColor: SKColors.skoller_blue,
                    onChanged: (val) {
                      toggleComplete();
                    },
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: SKColors.selected_gray, width: 1),
              ),
            ),
            margin: EdgeInsets.fromLTRB(12, 2, 8, 2),
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Add grade',
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

  Widget buildJobView() {
    final student = SKUser.current?.student;

    void Function(TapUpDetails)? action;
    late String prompt;
    int level = 3;

    if ((student!.fieldsOfStudy ?? []).length == 0) {
      level = 0;
      prompt = 'What\'s your field of study?';
      action = (_) async {
        final loader = SKLoadingScreen.fadeIn(context);
        final response = await FieldsOfStudy.getFieldsOfStudy();
        loader.fadeOut();

        if (response.wasSuccessful())
          await Navigator.push(context,
              SKNavOverlayRoute(builder: (_) => MajorSelector(response.obj)));

        setState(() {});
      };
    } else if (student.gradYear == null) {
      level = 1;
      prompt = 'When do you graduate?';
      action = (_) {
        final currentYear = DateTime.now().year;
        final years = List.generate(6, (index) => '${currentYear + index}');
        showDialog(
          context: context,
          builder: (context) => SKPickerModal(
            title: "Graduation year",
            subtitle: "When do you expect to graduate?",
            items: years,
            onSelect: (index) async {
              final loader = SKLoadingScreen.fadeIn(context);
              await SKUser.current?.update(gradYear: years[index]);
              loader.fadeOut();
              setState(() {});
            },
          ),
        );
      };
    } else if (student.degreeType == null) {
      level = 2;
      prompt = 'What degree are you pursuing?';
      action = (_) async {
        final loader = SKLoadingScreen.fadeIn(context);
        final response = await TypeObject.getDegreeTypes();
        loader.fadeOut();

        if (response.wasSuccessful()) {
          final List<TypeObject> degrees = response.obj;
          await showDialog(
            context: context,
            builder: (context) => SKPickerModal(
              title: "Degree type",
              subtitle: "What type of degree are you pursuing?",
              items: degrees.map((d) => d.name).toList(),
              onSelect: (index) async {
                final loader = SKLoadingScreen.fadeIn(context);
                await SKUser.current?.update(degreeType: degrees[index]);
                loader.fadeOut();
                setState(() {});
              },
            ),
          );
        }
      };
    }

    if (level == 3)
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SKColors.border_gray),
          boxShadow: UIAssets.boxShadow,
          color: Colors.white,
        ),
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: SKColors.selected_gray,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Image.asset(ImageNames.peopleImages.people_gray),
                  ),
                  Text(
                    'Share with classmates',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Send this sign-up link to your classmates in Business Finance!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) =>
                    Share.share(assignment!.parentClass.shareMessage),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: UIAssets.boxShadow,
                      color: SKColors.skoller_blue1),
                  child: Text(
                    assignment!.parentClass.enrollmentLink.split("//")[1],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    else
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SKColors.border_gray),
          boxShadow: UIAssets.boxShadow,
          color: Colors.white,
        ),
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: SKColors.selected_gray,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Tell us more!',
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    '5 pts.',
                    style: TextStyle(
                      color: SKColors.light_gray,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Get the MOST out of Skoller 🔮',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: action,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 6),
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.skoller_blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  prompt,
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(64, 12, 64, 4),
              child: Row(
                children: <Widget>[
                  ...List.generate(
                    level,
                    (_) => Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: SKColors.skoller_blue),
                      ),
                    ),
                  ),
                  ...List.generate(
                    3 - level,
                    (index) => Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          // border: index == level - 1 ? Border.all(color: SKColors.skoller_blue) : null,
                          color: index == 0
                              ? SKColors.skoller_blue.withOpacity(0.3)
                              : SKColors.border_gray,
                        ),
                      ),
                    ),
                  )
                ],
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
                  placeholderStyle: TextStyle(
                      color: SKColors.light_gray,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                  keyboardType: TextInputType.number,
                  onChanged: (newStr) => results.numerator = newStr,
                  textAlign: TextAlign.center,
                  cursorColor: SKColors.skoller_blue,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.border_gray),
                  ),
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
                  placeholderStyle: TextStyle(
                      color: SKColors.light_gray,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.border_gray),
                  ),
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
                onValueChanged: (int newKey) {
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
  final VoidCallback? onTap;
  final String? text;
  final bool isAlert;

  _GradeShakeAnimation({this.onTap, this.text, this.isAlert = false})
      : super(key: UniqueKey());

  @override
  State<StatefulWidget> createState() => _GradeShakeAnimationState();
}

class _GradeShakeAnimationState extends State<_GradeShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      curve: Curves.easeInToLinear,
      parent: _controller,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted)
          Timer(
            Duration(seconds: 3),
            () {
              if (mounted) _controller.forward(from: 0);
            },
          );
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
    return sin(progress * pi * 2) * 0.3;
    // return Matrix4.rotationZ(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: translation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTapUp: (details) => widget.onTap!(),
        child: Container(
          // color: Colors.red,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: Text(
            widget.text!,
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

class _SKImpactGraphDescriptionModal extends StatelessWidget {
  final Assignment assignment;

  _SKImpactGraphDescriptionModal(this.assignment);

  @override
  Widget build(BuildContext context) {
    final parentClass = assignment.parentClass;

    final completion = assignment.weight;
    ImpactLevel level;

    if ((completion ?? 0.0) == 0.0)
      level = ImpactLevel.none;
    else if (completion! < 0.05)
      level = ImpactLevel.low;
    else if (completion < 0.15)
      level = ImpactLevel.medium;
    else
      level = ImpactLevel.high;

    final descriptions = [
      ['Low', '0-5% of final grade', ImpactLevel.low],
      ['Medium', '5-15% of final grade', ImpactLevel.medium],
      ['High', '15% and above', ImpactLevel.high]
    ].map((e) {
      final textColor = (e[2] as ImpactLevel) == level
          ? SKColors.dark_gray
          : SKColors.light_gray;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(e[0].toString(), style: TextStyle(color: textColor)),
                Text(
                  e[1].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: textColor,
                  ),
                )
              ],
            ),
            SKAssignmentImpactGraph.byLevel(
              e[2] as ImpactLevel,
              parentClass.getColor(),
              ImpactGraphSize.small,
            ),
          ],
        ),
      );
    });

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Impact',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              'How will this assignment impact\n your final grade?',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            ...descriptions,
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Text.rich(
                TextSpan(
                  text: 'This assignment is worth ',
                  children: [
                    TextSpan(
                      text: '${(assignment.weight ?? 0) * 100}%\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' of your final grade'),
                  ],
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Need more information?',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: SKColors.light_gray),
            ),
            GestureDetector(
              onTapUp: (_) => Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (_) => WeightsInfoView(parentClass.id),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.skoller_blue),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'View weights',
                  style: TextStyle(color: SKColors.skoller_blue, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
