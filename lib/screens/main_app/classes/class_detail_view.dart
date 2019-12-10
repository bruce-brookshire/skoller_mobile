import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:skoller/screens/main_app/classes/class_menu_modal.dart';
import 'package:skoller/screens/main_app/classes/modals/add_grade_scale_modal.dart';
import './modals/class_link_sharing_modal.dart';
import 'package:skoller/screens/main_app/classes/classmates_view.dart';
import 'package:skoller/screens/main_app/classes/weights_info_view.dart';
import 'package:skoller/tools.dart';
import 'assignment_info_view.dart';
import 'assignment_weight_view.dart';
import 'class_info_view.dart';

class ClassDetailView extends StatefulWidget {
  final int classId;

  ClassDetailView({Key key, this.classId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetailView> {
  int weightsWithoutAssignments = 0;

  StudentClass get studentClass => StudentClass.currentClasses[widget.classId];
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    loadClass();
    fetchClass();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.assignmentChanged,
        onNotification: loadClass);

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.modsChanged,
        onNotification: loadClass);

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.classChanged,
        onNotification: loadClass);
  }

  @override
  void dispose() {
    super.dispose();
    DartNotificationCenter.unsubscribe(observer: this);
  }

  Future fetchClass() async {
    await studentClass.refetchSelf();
    if (mounted) setState(() {});
  }

  Future loadClass([dynamic options]) async {
    Map<int, int> weightDensity = {};

    for (final Assignment assignment in studentClass?.assignments ?? []) {
      if (assignment.weight_id != null) {
        final currCount = weightDensity[assignment.weight_id] ?? 0;
        weightDensity[assignment.weight_id] = currCount + 1;
      }
    }

    weightsWithoutAssignments = 0;

    for (final Weight weight in studentClass?.weights ?? [])
      if (weightDensity[weight.id] == null) weightsWithoutAssignments += 1;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = this.studentClass;

    if (studentClass == null) return Scaffold(backgroundColor: Colors.white);

    final grade = (studentClass.grade == null || studentClass.grade == 0)
        ? '-- %'
        : '${studentClass.grade}%';

    final classColor = studentClass.getColor();

    final assignments = studentClass.assignments;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: EdgeInsets.only(top: 67),
                color: SKColors.background_gray,
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: fetchClass,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 16, bottom: 64),
                    itemCount: studentClass.assignments.length,
                    itemBuilder: (_, index) =>
                        _AssignmentCell(assignments[index].id, classColor),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 78,
                padding: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x21000000),
                        offset: Offset(0, 3),
                        blurRadius: 1.5)
                  ],
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTapUp: (details) {
                              Navigator.pop(context);
                            },
                            child: Container(
                              child:
                                  Image.asset(ImageNames.navArrowImages.left),
                              width: 36,
                              height: 36,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Hero(
                                  tag: 'ClassName${studentClass.id}',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Text(
                                      studentClass.name,
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      // minFontSize: 10,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: classColor),
                                    ),
                                  ),
                                ),
                                Hero(
                                  tag: 'ClassGrade${studentClass.id}',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Text(
                                      '${grade}',
                                      style: TextStyle(
                                          color: SKColors.dark_gray,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTapUp: (details) => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    AssignmentWeightView(studentClass.id),
                                settings:
                                    RouteSettings(name: 'AssignmentWeightView'),
                              ),
                            ),
                            child: createPlusButton(),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTapUp: (_) => DartNotificationCenter.post(
                          channel:
                              NotificationChannels.presentModalViewOverTabBar,
                          options: ClassMenuModal(this.studentClass),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: SKColors.light_gray,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createPlusButton() {
    final child = Container(
      padding: EdgeInsets.all(3.5),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SKColors.skoller_blue,
        boxShadow: [
          BoxShadow(
            color: Color(0x2F000000),
            offset: Offset(0, 1.75),
            blurRadius: 3.5,
          )
        ],
      ),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
    if (weightsWithoutAssignments == 0)
      return child;
    else
      return Stack(
        alignment: Alignment.topRight,
        children: [
          child,
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 6, right: 5.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SKColors.warning_red,
            ),
            width: 14,
            height: 14,
            child: Text(
              '$weightsWithoutAssignments',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ],
      );
  }
}

class _AssignmentCell extends StatefulWidget {
  final int assignmentId;
  final Color classColor;

  _AssignmentCell(this.assignmentId, this.classColor);

  @override
  State createState() => _AssignmentCellState();
}

class _AssignmentCellState extends State<_AssignmentCell> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    final assignment = Assignment.currentAssignments[widget.assignmentId];
    final isPromptGrade = assignment.isCompleted && assignment.grade == null;

    final gradeSquare = isPromptGrade
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 18),
            width: 46,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(border: Border(right: BorderSide(color: SKColors.border_gray))),
            child: Text(
              '--%',
              textScaleFactor: 1,
              style: TextStyle(
                  color: SKColors.warning_red,
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  letterSpacing: -0.75),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 18),
            width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: assignment.grade == null
                  ? (assignment.isCompleted
                      ? Colors.white
                      : SKColors.light_gray)
                  : widget.classColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              border: isPromptGrade
                  ? Border.all(color: SKColors.border_gray)
                  : null,
            ),
            child: Text(
              assignment.grade == null
                  ? '--'
                  : '${(assignment.grade).round()}%',
              textScaleFactor: 1,
              style: TextStyle(
                  color: isPromptGrade ? SKColors.warning_red : Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  letterSpacing: -0.75),
            ),
          );

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          isTapped = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isTapped = false;
        });
      },
      onTapUp: (details) {
        setState(() {
          isTapped = false;
        });
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) =>
                AssignmentInfoView(assignmentId: assignment.id),
            settings: RouteSettings(name: 'AssignmentInfoView'),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: isTapped ? SKColors.selected_gray : Colors.white,
            boxShadow: UIAssets.boxShadow,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray)),
        margin: EdgeInsets.fromLTRB(6, 3, 6, 3),
        child: Row(
          children: <Widget>[
            gradeSquare,
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: 'TaskName${assignment.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                assignment.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                              ),
                            ),
                          ),
                          Text(
                            assignment.due == null
                                ? 'Add due date'
                                : DateUtilities.getFutureRelativeString(
                                    assignment.due),
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: assignment.due == null
                                    ? SKColors.alert_orange
                                    : SKColors.light_gray),
                          ),
                        ],
                      ),
                    ),
                    SKAssignmentImpactGraph(
                      assignment.weight,
                      assignment.parentClass.getColor(),
                      size: ImpactGraphSize.small,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
