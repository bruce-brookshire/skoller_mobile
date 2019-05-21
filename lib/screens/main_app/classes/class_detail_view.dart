import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
                  padding: EdgeInsets.only(top: 6),
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
                                onTapUp: (details) {
                                  Navigator.pop(context);
                                },
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
            child: SafeArea(
              top: false,
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
                margin: EdgeInsets.only(bottom: 8),
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
              builder: (context) => AssignmentInfoView(assignment_id: assignment.id)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(assignment.name),
                        Text(
                          DateUtilities.getFutureRelativeString(assignment.due),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      assignment.weight == null
                          ? ''
                          : (assignment.weight == 0 ? 'Not graded' : weight),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                    )
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
