import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  int _selectedIndex;
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

  void tappedLink(TapUpDetails details) {
    showDialog(
        context: context,
        builder: (context) => ClassLinkSharingModal(widget.classId));
  }

  void tappedSpeculate(TapUpDetails details) async {
    bool shouldProceed = true;

    if (studentClass.gradeScale == null) {
      final result = await showGradeScalePicker();
      if (result == null || !result) {
        shouldProceed = false;
      }
    }

    if (shouldProceed) {
      showSpeculate();
    }
  }

  Future showGradeScalePicker() {
    return Navigator.push(
      context,
      SKNavOverlayRoute(
        isBarrierDismissible: false,
        builder: (context) => AddGradeScaleModal(
          classId: widget.classId,
          onCompletionShowGradeScale: false,
        ),
      ),
    );
  }

  void showSpeculate() async {
    final speculate = await studentClass.speculateClass().then(
      (response) {
        if (response.wasSuccessful())
          return response.obj;
        else
          throw 'Unable to get speculation';
      },
    ).catchError((onError) {
      DropdownBanner.showBanner(
        text: onError is String ? onError : 'Failed to get speculation',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    });

    if (!(speculate is List)) {
      return;
    }

    (speculate as List).sort(
      (elem1, elem2) =>
          (elem2['speculation'] as num).compareTo(elem1['speculation'] as num),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: _SpeculateModalView(
          speculate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = this.studentClass;

    if (studentClass == null) return Scaffold(backgroundColor: Colors.white);

    final grade = (studentClass.grade == null || studentClass.grade == 0)
        ? '-- %'
        : '${studentClass.grade}%';
    final classmates = studentClass.enrollment;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: EdgeInsets.only(top: 96),
                color: SKColors.background_gray,
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: fetchClass,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 6, bottom: 64),
                    itemCount: studentClass.assignments.length,
                    itemBuilder: assignmentCellBuilder,
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
                height: 96,
                padding: EdgeInsets.only(
                  bottom: 8,
                  left: 4,
                  right: 4,
                ),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color(0x1C000000),
                    offset: Offset(0, 3.5),
                    blurRadius: 3.5,
                  )
                ], color: Colors.white),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTapUp: (details) {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  child: Image.asset(
                                      ImageNames.navArrowImages.left),
                                  width: 36,
                                  height: 44,
                                ),
                              ),
                              GestureDetector(
                                onTapUp: tappedLink,
                                child: Container(
                                  child: Image.asset(
                                      ImageNames.rightNavImages.link),
                                  width: 36,
                                  height: 44,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: AutoSizeText(
                              studentClass.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 10,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: studentClass.getColor()),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTapUp: (details) {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            ClassInfoView(studentClass.id),
                                        settings: RouteSettings(
                                            name: 'ClassInfoView'),
                                      ));
                                },
                                child: SizedBox(
                                  child: Image.asset(
                                      ImageNames.rightNavImages.info),
                                  width: 36,
                                  height: 40,
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (details) => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        AssignmentWeightView(studentClass.id),
                                    settings: RouteSettings(
                                        name: 'AssignmentWeightView'),
                                  ),
                                ),
                                child: SizedBox(
                                  child: createPlusButton(),
                                  width: 36,
                                  height: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTapUp: tappedSpeculate,
                              child: Container(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  child: Text(
                                    'Speculate Grade',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SKColorPicker(
                            callback: (newColor) {
                              studentClass.setColor(newColor).then((response) =>
                                  DartNotificationCenter.post(
                                      channel:
                                          NotificationChannels.classChanged));
                              setState(() {});
                            },
                            child: Container(
                              width: 80,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: UIAssets.boxShadow,
                                color: studentClass.getColor(),
                              ),
                              child: Text(
                                '${grade}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTapUp: (details) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          WeightsInfoView(studentClass.id),
                                      settings: RouteSettings(
                                          name: 'WeightsInfoView'),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.only(right: 4, bottom: 1),
                                      child: ClassCompletionChart(
                                        studentClass.completion,
                                        SKColors.skoller_blue,
                                      ),
                                    ),
                                    Text(
                                      '${(studentClass.completion * 100).round()}% complete',
                                      style: TextStyle(
                                          color: SKColors.skoller_blue,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              // behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ClassmatesView(widget.classId),
                    settings: RouteSettings(name: 'ClassmatesView'),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color:
                        classmates < 4 ? studentClass.getColor() : Colors.white,
                    boxShadow: UIAssets.boxShadow,
                    border: Border.all(
                      color:
                          classmates < 4 ? Colors.white : SKColors.skoller_blue,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 8),
                      child: Image.asset(classmates < 4
                          ? ImageNames.peopleImages.people_white
                          : ImageNames.peopleImages.people_blue),
                    ),
                    Text(
                      classmates < 4
                          ? '${4 - classmates} classmate${(4 - classmates) == 1 ? '' : 's'} away'
                          : '${classmates} classmate${classmates == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: classmates < 4
                              ? Colors.white
                              : SKColors.skoller_blue,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget assignmentCellBuilder(BuildContext context, int index) {
    final assignment_id = studentClass.assignments[index].id;
    final assignment = Assignment.currentAssignments[assignment_id];
    double pre_weight =
        assignment.weight != null ? assignment.weight * 100 : null;
    String weight;

    if (pre_weight == null) {
      weight = '';
    } else if (pre_weight == 0 && assignment.weight_id == null) {
      weight = 'Not graded';
    } else if (pre_weight % 1 == 0) {
      weight = '${pre_weight.round()}%';
    } else {
      weight = '${(assignment.weight * 1000).roundToDouble() / 10}%';
    }
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _selectedIndex = index;
        });
      },
      onTapCancel: () {
        setState(() {
          _selectedIndex = null;
        });
      },
      onTapUp: (details) {
        setState(() {
          _selectedIndex = null;
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
            color:
                _selectedIndex == index ? SKColors.selected_gray : Colors.white,
            boxShadow: UIAssets.boxShadow,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray)),
        margin: EdgeInsets.fromLTRB(6, 3, 6, 3),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: assignment.grade == null
                      ? SKColors.light_gray
                      : studentClass.getColor(),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5))),
              child: Text(
                assignment.grade == null
                    ? '--'
                    : '${(assignment.grade).round()}%',
                textScaleFactor: 1,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    letterSpacing: -0.75),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            assignment.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaleFactor: 1,
                          ),
                        ),
                        Text(
                          assignment.due == null
                              ? 'Add due date'
                              : DateUtilities.getFutureRelativeString(
                                  assignment.due),
                          textScaleFactor: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: assignment.due == null
                                  ? SKColors.alert_orange
                                  : SKColors.dark_gray),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              assignment.weight == null
                                  ? ''
                                  : (assignment.weight == 0
                                      ? 'Not graded'
                                      : weight),
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: assignment.posts.length == 0
                              ? null
                              : Image.asset(
                                  ImageNames.chatImages.commented_gray),
                        ),
                        Text(
                          '${assignment.posts.length == 0 ? '' : assignment.posts.length}',
                          textScaleFactor: 1,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: SKColors.light_gray),
                        ),
                      ],
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

  Widget createPlusButton() {
    if (weightsWithoutAssignments == 0)
      return Image.asset(ImageNames.rightNavImages.plus);
    else
      return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Image.asset(ImageNames.rightNavImages.plus),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 4, right: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SKColors.warning_red,
              ),
              width: 12.75,
              height: 12.75,
              child: Text(
                '${weightsWithoutAssignments}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.normal),
              ),
            ),
          )
        ],
      );
  }
}

class _SpeculateModalView extends StatefulWidget {
  final List speculate;

  _SpeculateModalView(this.speculate);

  @override
  State createState() => _SpeculateModalState();
}

class _SpeculateModalState extends State<_SpeculateModalView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SKColors.border_gray,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Speculate',
            style: TextStyle(fontSize: 17),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'What grade do you want to make in this class?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 140,
            child: CupertinoPicker.builder(
              backgroundColor: Colors.white,
              childCount: widget.speculate.length,
              itemBuilder: (context, index) => Container(
                alignment: Alignment.center,
                child: Text(
                  '${widget.speculate[index]['grade']}',
                  style: TextStyle(
                    color: SKColors.dark_gray,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemExtent: 32,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'You need to average at least a ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                      text:
                          '${widget.speculate[selectedIndex]['speculation']}%'),
                  TextSpan(
                    text:
                        ' on your remaining assignments to achieve the grade ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                      text: '${widget.speculate[selectedIndex]['grade']}.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTapUp: (details) => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.only(top: 24, left: 16, right: 16),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: SKColors.border_gray))),
              alignment: Alignment.center,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: SKColors.skoller_blue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
