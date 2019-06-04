import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:skoller/screens/main_app/classes/class_link_sharing_modal.dart';
import 'package:skoller/screens/main_app/classes/classmates_view.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import 'assignment_info_view.dart';
import 'assignment_weight_view.dart';
import 'class_info_view.dart';

class ClassDetailView extends StatefulWidget {
  final int classId;

  ClassDetailView({Key key, this.classId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassDetailViewState();
}

class _ClassDetailViewState extends State<ClassDetailView> {
  StudentClass studentClass;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    studentClass = StudentClass.currentClasses[widget.classId];
    studentClass.refetchSelf().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          studentClass = response.obj;
        });
      }
    });
  }

  void tappedLink(TapUpDetails details) async {
    final results = await showDialog(
        context: context,
        builder: (context) => ClassLinkSharingModal(widget.classId));
  }

  void tappedSpeculate(TapUpDetails details) async {
    bool shouldProceed = true;

    if (studentClass.gradeScale == null) {
      final result = await showGradeScalePicker();
      if (result == null) {
        shouldProceed = false;
      }
    }

    if (shouldProceed) {
      showSpeculate();
    }
  }

  void showSpeculate() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: SKColors.border_gray,
                  )),
            ),
          ),
    );
  }

  Future<bool> showGradeScalePicker() {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: _GradeScaleModalView(studentClass),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grade = (studentClass.grade == null || studentClass.grade == 0)
        ? '-- %'
        : '${studentClass.grade}%';
    final classmates = studentClass.enrollment - 1;

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
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 6, bottom: 64),
                  itemCount: studentClass.assignments.length,
                  itemBuilder: assignmentCellBuilder,
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
                                              ClassInfoView(studentClass.id)));
                                },
                                child: Container(
                                  child: Image.asset(
                                      ImageNames.rightNavImages.info),
                                  width: 36,
                                  height: 44,
                                ),
                              ),
                              GestureDetector(
                                onTapUp: (details) {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              AssignmentWeightView(
                                                  studentClass.id)));
                                },
                                child: Container(
                                  child: Image.asset(
                                      ImageNames.rightNavImages.plus),
                                  width: 36,
                                  height: 44,
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
                          Container(
                            width: 80,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [UIAssets.boxShadow],
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
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              child: GestureDetector(
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
                      builder: (context) => ClassmatesView(widget.classId)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color:
                        classmates < 4 ? studentClass.getColor() : Colors.white,
                    boxShadow: [UIAssets.boxShadow],
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
                          ? '${4 - classmates} classmate${classmates == 1 ? '' : 's'} away'
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
    final assignment = studentClass.assignments[index];
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
                  AssignmentInfoView(assignment_id: assignment.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                _selectedIndex == index ? SKColors.selected_gray : Colors.white,
            boxShadow: [UIAssets.boxShadow],
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
                          child: Text(assignment.name),
                        ),
                        Text(
                          DateUtilities.getFutureRelativeString(assignment.due),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
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
}

class _GradeScaleModalView extends StatefulWidget {
  StudentClass studentClass;

  _GradeScaleModalView(this.studentClass);

  @override
  State createState() => _GradeScaleModalViewState();
}

class _GradeScaleModalViewState extends State<_GradeScaleModalView> {
  int selectedIndex = 0;

  final scaleMapper = (List<String> scale, bool isSelected) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: scale
            .map((elem) => Text(
                  elem,
                  style: TextStyle(
                      color: isSelected ? Colors.white : SKColors.dark_gray),
                ))
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    final scales = [
      [
        ['A', 'B', 'C', 'D'],
        ['90', '80', '70', '60']
      ],
      [
        ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D'],
        ['93', '90', '87', '83', '80', '77', '73', '70', '60'],
      ],
      [
        ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-'],
        ['93', '90', '87', '83', '80', '77', '73', '70', '67', '63', '60'],
      ],
    ];

    int curIndex = 0;
    List<Widget> containers = [];

    for (final scale in scales) {
      int curTemp = curIndex.toInt();

      containers.add(
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              if (selectedIndex != curTemp) {
                setState(() {
                  selectedIndex = curTemp;
                });
              }
            },
            child: Container(
              height: 220,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [UIAssets.boxShadow],
                color: selectedIndex == curTemp
                    ? SKColors.skoller_blue
                    : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: scale
                    .map((elem) => scaleMapper(elem, selectedIndex == curTemp))
                    .toList(),
              ),
            ),
          ),
        ),
      );

      curIndex += 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SKColors.skoller_blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Select grade scale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'for entire class',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Select the grade scale for this class',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: containers,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: [UIAssets.boxShadow],
            ),
            child: Text(
              'Select',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
