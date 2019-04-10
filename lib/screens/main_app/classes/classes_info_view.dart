import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import 'assignment_info_view.dart';

class ClassesInfoView extends StatefulWidget {
  final int classId;

  ClassesInfoView({Key key, this.classId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassesInfoViewState();
}

class _ClassesInfoViewState extends State<ClassesInfoView> {
  StudentClass studentClass;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    studentClass = StudentClass.currentClasses[widget.classId];
    studentClass.refetchSelf().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          // studentClass = response.obj;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: 44,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Color(0x1C000000),
                      offset: Offset(0, 3.5),
                      blurRadius: 3.5,
                    )
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTapUp: (details) {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 4),
                          child: Image.asset(ImageNames.navArrowImages.left),
                          width: 44,
                          height: 44,
                        ),
                      ),
                      Text(
                        studentClass.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: studentClass.getColor()),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 4),
                        child: null,
                        width: 44,
                        height: 44,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 6),
                    itemCount: studentClass.assignments.length,
                    itemBuilder: assignmentCellBuilder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget assignmentCellBuilder(BuildContext context, int index) {
    final assignment = studentClass.assignments[index];
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
          MaterialPageRoute(
              builder: (context) => AssignmentInfoView(task: assignment)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                _selectedIndex == index ? SKColors.selected_gray : Colors.white,
            boxShadow: [UIAssets.boxShadow],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray)),
        margin: EdgeInsets.fromLTRB(8, 3, 8, 4),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              width: 44,
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
                    : '${studentClass.grade.round()}%',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
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
                          : (assignment.weight == 0
                              ? 'Not graded'
                              : '${assignment.weight}%'),
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
