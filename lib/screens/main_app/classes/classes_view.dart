import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import 'classes_info_view.dart';

class ClassesView extends StatefulWidget {
  @override
  State createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  List<StudentClass> classes = [];
  int selectedIndex;

  @override
  void initState() {
    super.initState();

    classes.addAll(StudentClass.currentClasses.values);
  }

  fetchClasses() {
    StudentClass.getStudentClasses().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          classes = [];
          classes.addAll(StudentClass.currentClasses.values);
        });
      }
    });
  }

  @override
  Widget build(BuildContext build) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: SKColors.background_gray,
          child: Center(
            child: Column(
              children: <Widget>[
                SKNavBar(
                  'Classes',
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 4),
                    itemCount: classes.length,
                    itemBuilder: createClassCard,
                  ),
                )
              ],
            ),
          ),
        ),
      ));

  Widget createClassCard(BuildContext context, int index) {
    final studentClass = classes[index];
    final grade = studentClass.grade == 0 ? null : studentClass.grade;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          selectedIndex = index;
        });
      },
      onTapCancel: () {
        setState(() {
          selectedIndex = null;
        });
      },
      onTapUp: (_) {
        setState(() {
          selectedIndex = null;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ClassesInfoView(classId: studentClass.id)));
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                selectedIndex == index ? SKColors.selected_gray : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: SKColors.border_gray,
            ),
            boxShadow: [UIAssets.boxShadow]),
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 23),
              width: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: studentClass.getColor(),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5))),
              child: Text(
                grade == null
                    ? '--%'
                    : '${NumberUtilities.formatGradeAsPercent(grade)}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                    letterSpacing: -0.75),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text(
                      studentClass.name,
                      style: TextStyle(
                          fontSize: 17, color: studentClass.getColor()),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 5, bottom: 2),
                        child: Image.asset(
                            ImageNames.peopleImages.person_dark_gray),
                      ),
                      Text(
                        '${studentClass.enrollment - 1} classmate${(studentClass.enrollment - 1) == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    '${(studentClass.completion * 100).round()}% complete',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
