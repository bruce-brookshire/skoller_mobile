import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'class_detail_view.dart';

class ClassesView extends StatefulWidget {
  @override
  State createState() => _ClassesViewState();
}

typedef Widget _CardConstruct(StudentClass studentClass, int index);
enum _SammiExplanationType { needsSetup, diy, inReview }

class _ClassesViewState extends State<ClassesView> {
  List<StudentClass> classes = [];
  int selectedIndex;
  Map<int, _CardConstruct> cardConstructors;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    sortClasses();
    fetchClasses();

    cardConstructors = {
      ClassStatuses.needs_setup: this.needsSetup,
      ClassStatuses.syllabus_submitted: this.processingSyllabus,
      ClassStatuses.needs_student_input: this.diyOnly,
      ClassStatuses.class_setup: this.createCompleteCard,
      ClassStatuses.class_issue: this.createCompleteCard,
    };

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.classChanged,
        onNotification: sortClasses);
  }

  @override
  void dispose() {
    super.dispose();
    DartNotificationCenter.unsubscribe(observer: this);
  }

  Future fetchClasses() async {
    final response = await StudentClass.getStudentClasses();

    if (response.wasSuccessful()) {
      sortClasses();
    }
  }

  void sortClasses([dynamic options]) {
    List<StudentClass> classes = StudentClass.currentClasses.values.toList();

    final categorizer = (int status) {
      if ([ClassStatuses.needs_setup, ClassStatuses.needs_student_input]
          .contains(status)) {
        return 0;
      } else if (ClassStatuses.syllabus_submitted == status) {
        return 1;
      } else {
        return 2;
      }
    };

    Map<int, int> mapped_classes = {};

    for (StudentClass studentClass in classes) {
      mapped_classes[studentClass.id] = categorizer(studentClass.status.id);
    }

    classes.sort((class1, class2) {
      final cat1 = mapped_classes[class1.id];
      final cat2 = mapped_classes[class2.id];

      if (cat1 < cat2) {
        return -1;
      } else if (cat1 > cat2) {
        return 1;
      } else {
        return (class1.name ?? "").compareTo((class2.name ?? ""));
      }
    });

    setState(() {
      this.classes = classes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Classes',
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      rightBtn: Image.asset(ImageNames.rightNavImages.add_class),
      callbackRight: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AddClassesView(),
            fullscreenDialog: true,
          ),
        );
      },
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchClasses,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4),
              itemCount: classes.length,
              itemBuilder: createClassCard,
            ),
          ),
        ),
      ],
    );
  }

  Widget createClassCard(BuildContext context, int index) {
    final studentClass = classes[index];
    return cardConstructors[studentClass.status.id](studentClass, index);
  }

  Widget createCompleteCard(StudentClass studentClass, int index) {
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
            CupertinoPageRoute(
                title: 'class_detail',
                builder: (context) =>
                    ClassDetailView(classId: studentClass.id)));
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
              height: 66,
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
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 1, right: 4),
                        child: ClassCompletionChart(
                          studentClass.completion,
                          SKColors.dark_gray,
                        ),
                      ),
                      Text(
                        '${(studentClass.completion * 100).round()}% complete',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget needsSetup(StudentClass studentClass, int index) {
    final needsAssignments = (studentClass.weights ?? []).length > 0 &&
        (studentClass.assignments ?? []).length == 0;
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
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //         builder: (context) =>
        //             ClassDetailView(classId: studentClass.id)));
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
                height: 66,
                width: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: needsAssignments ? studentClass.getColor() : null,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5))),
                child: Image.asset(
                  needsAssignments
                      ? ImageNames.peopleImages.people_white
                      : ImageNames.peopleImages.person_edit,
                  fit: BoxFit.fitWidth,
                )),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
              decoration: BoxDecoration(
                  border: needsAssignments
                      ? null
                      : Border(
                          left: BorderSide(
                              color: SKColors.skoller_blue, width: 2))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text(
                      studentClass.name,
                      style: TextStyle(
                          fontSize: 17,
                          color: needsAssignments
                              ? studentClass.getColor()
                              : SKColors.dark_gray),
                    ),
                  ),
                  Text(
                    needsAssignments
                        ? 'Add your first assignment'
                        : 'Set up this class',
                    style: TextStyle(
                        color: needsAssignments
                            ? SKColors.dark_gray
                            : SKColors.skoller_blue,
                        fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget diyOnly(StudentClass studentClass, int index) {
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
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //         builder: (context) =>
        //             ClassDetailView(classId: studentClass.id)));
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
                height: 66,
                width: 58,
                alignment: Alignment.center,
                child: Image.asset(
                  ImageNames.statusImages.diy,
                  fit: BoxFit.fitWidth,
                )),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
              decoration: BoxDecoration(
                  border: Border(
                      left:
                          BorderSide(color: SKColors.alert_orange, width: 2))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text(
                      studentClass.name,
                      style: TextStyle(fontSize: 17, color: SKColors.dark_gray),
                    ),
                  ),
                  Text(
                    'DIY required',
                    style:
                        TextStyle(color: SKColors.alert_orange, fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget processingSyllabus(StudentClass studentClass, int index) {
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

        tappedSammiExplanation(_SammiExplanationType.inReview);
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //         builder: (context) =>
        //             ClassDetailView(classId: studentClass.id)));
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
                height: 66,
                width: 58,
                alignment: Alignment.center,
                child: Image.asset(
                  ImageNames.statusImages.clock,
                  fit: BoxFit.fitWidth,
                )),
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: SKColors.text_light_gray, width: 2))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text(
                      studentClass.name,
                      style: TextStyle(fontSize: 17, color: SKColors.dark_gray),
                    ),
                  ),
                  Text(
                    'Syllabus in review',
                    style: TextStyle(color: SKColors.dark_gray, fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void tappedSammiExplanation(_SammiExplanationType type) async {
    showDialog(
      context: context,
      builder: (context) => Column(
        children: [
          Spacer(flex: 1),
          Material(
            color: Colors.white.withAlpha(0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SammiSpeechBubble(
                sammiPersonality: SammiPersonality.smile,
                speechBubbleContents: Text.rich(
                  TextSpan(
                    text: 'I received the syllabus but ',
                    children: [
                      TextSpan(
                          text: 'there wasn\'t enough info ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              'on it to set up the class. Knock it out in a few minutes!'),
                    ],
                  ),
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
            ),
          ),
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            backgroundColor: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: SKColors.selected_gray,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Image.asset(ImageNames.peopleImages.people_gray),
                    ),
                    Text(
                      'Set up this class',
                      style: TextStyle(fontSize: 17),
                    ),
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Instant setup',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Do it yourself!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [UIAssets.boxShadow],
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Spacer(flex: 2)
        ],
      ),
    );
  }
}
