import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/classes/assignment_weight_view.dart';
import 'package:skoller/screens/main_app/classes/weight_extraction_view.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/menu/class_search_settings_modal.dart';
import 'package:skoller/tools.dart';
import 'class_detail_view.dart';

enum _CardType {
  sammiSyllabusInstruction,
  sammiSecondClass,
  sammiNewClasses,
  sammiFirstClass,
  periodName,
  studentClass
}

class _CardObject {
  final bool isCurrent;
  final dynamic object;
  final _CardType type;

  _CardObject(this.isCurrent, this.object, this.type);
}

class ClassesView extends StatefulWidget {
  @override
  State createState() => _ClassesState();
}

typedef Widget _CardConstruct(StudentClass studentClass, int index);

class _ClassesState extends State<ClassesView> {
  List<_CardObject> cardObjects = [];
  int selectedIndex;
  Map<int, _CardConstruct> cardConstructors;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final semesterPrompt = 'sk_semester_prompt_enrollment';

  @override
  void initState() {
    super.initState();

    if (StudentClass.currentClasses == {} &&
        SKCacheManager.classesLoader != null) {
      SKCacheManager.classesLoader.then((_) => sortClasses());
    } else {
      sortClasses();
    }
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

    Map<Period, List> periodClasses = {};

    for (final studentClass in classes) {
      final period = studentClass.classPeriod;
      if (periodClasses.containsKey(period))
        periodClasses[period].add(studentClass);
      else
        periodClasses[period] = [studentClass];
    }

    // Provides the heirarchy ranking for a class based on its attributes
    final categorizer = (int status) {
      if ([ClassStatuses.needs_setup, ClassStatuses.needs_student_input]
          .contains(status))
        return 0;
      else if (ClassStatuses.syllabus_submitted == status)
        return 1;
      else
        return 2;
    };

    // Sort each of the period's classes
    for (final key in periodClasses.keys) {
      final sub_classes = periodClasses[key];

      Map<int, int> mapped_classes = {};

      // Create a map of a class's id to its ranking so we don't have
      // to call the categorizer more than once per class
      for (StudentClass studentClass in sub_classes) {
        mapped_classes[studentClass.id] = categorizer(studentClass.status.id);
      }

      sub_classes.sort((class1, class2) {
        final cat1 = mapped_classes[class1.id];
        final cat2 = mapped_classes[class2.id];

        if (cat1 < cat2)
          return -1;
        else if (cat1 > cat2)
          return 1;
        else
          return (class1.name ?? "").compareTo((class2.name ?? ""));
      });

      periodClasses[key] = sub_classes;
    }

    // Get next prompt period
    final promptPeriod = (SKUser.current.student.primarySchool.periods
          ..removeWhere((p) => !p.isMainPeriod)
          ..sort((p1, p2) => p1.startDate.compareTo(p2.startDate)))
        .firstWhere((p) =>
            p.startDate.millisecondsSinceEpoch >
            DateTime.now().millisecondsSinceEpoch);

    final now = DateTime.now();
    final comparisonDiff =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    // If we can prompt the student for next period classes, use that as
    // the start of the list, otherwise just an empty list
    final List<_CardObject> reductionList = (promptPeriod != null &&
            !periodClasses.containsKey(promptPeriod) &&
            StudentClass.currentClasses.length > 0)
        ? [_CardObject(true, promptPeriod, _CardType.sammiNewClasses)]
        : [];

    // Create card objects for ListView
    final List<_CardObject> list_elems = (periodClasses.entries.toList()
          ..sort((e1, e2) => e2.key.endDate.compareTo(e1.key.endDate)))
        .fold(
      reductionList,
      (l, e) {
        final isCurrent =
            e.key.endDate.millisecondsSinceEpoch >= comparisonDiff;
        return [
          ...l,
          _CardObject(isCurrent, e.key.name, _CardType.periodName),
          ...e.value
              .map((s) => _CardObject(isCurrent, s, _CardType.studentClass))
              .toList(),
        ];
      },
    );

    // if (cardObjects.length == 1) {
    //   if (index == 0 && ClassStatuses.needs_setup == cardObjects[1].object.status.id)
    //     return createSammiInstructionCard();
    //   else if (index == 1 && ClassStatuses.class_setup == cardObjects[0].status.id)
    //     return createSammiSecondClassCard();
    //   else
    //     object = cardObjects.first;
    // } else
    //   object = cardObjects[index];

    final classCount = classes.length;

    // If we have no classes, we have inserted no cards above, and need to prompt to add a class
    if (classCount == 0)
      list_elems.add(_CardObject(true, null, _CardType.sammiFirstClass));
    // If we have one class, and that class is part of a current term, we need to prompt for the second class
    else if (classCount == 1 &&
        classes.first.classPeriod.endDate.millisecondsSinceEpoch >=
            comparisonDiff) {
      final studentClass = classes.first;

      if (studentClass.status.id == ClassStatuses.needs_setup)
        list_elems.insert(
            0, _CardObject(true, classes.first, _CardType.sammiSyllabusInstruction));
      else if (studentClass.status.id == ClassStatuses.class_setup)
        list_elems.add(_CardObject(true, null, _CardType.sammiSecondClass));
    }

    // if (classes.length < 2)
    //   cardCount = 1;
    // else if (classes.length == 2)
    //   cardCount = [ClassStatuses.needs_setup, ClassStatuses.class_setup]
    //           .contains(cardObjects[1].object.status.id)
    //       ? 2
    //       : 1;
    // else {
    //   cardCount = cardObjects.length;
    // }

    setState(() {
      this.cardObjects = list_elems;
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
      callbackRight: tappedAddClasses,
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchClasses,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4),
              itemCount: cardObjects.length,
              itemBuilder: createObjectCard,
            ),
          ),
        ),
      ],
    );
  }

  Widget createObjectCard(BuildContext context, int index) {
    final object = cardObjects[index];

    switch (object.type) {
      case _CardType.sammiFirstClass:
        return createSammiPrompt();

      case _CardType.sammiSyllabusInstruction:
        return createSammiSyllabusInstructionCard(object);

      case _CardType.sammiSecondClass:
        return createSammiSecondClassCard();

      case _CardType.sammiNewClasses:
        return promptNewPeriod(object);

      case _CardType.periodName:
        return createPeriodNameCard(object);

      case _CardType.studentClass:
        final StudentClass studentClass = object.object;

        if (studentClass.status.id == ClassStatuses.needs_student_input &&
            (studentClass.weights ?? []).length > 0)
          return cardConstructors[ClassStatuses.needs_setup](
              studentClass, index);
        else
          return cardConstructors[studentClass.status.id](studentClass, index);
    }
  }

  Widget createPeriodNameCard(_CardObject object) => Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              object.object,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            if (!object.isCurrent)
              Text('See more', style: TextStyle(color: SKColors.skoller_blue))
          ],
        ),
      );

  Widget promptNewPeriod(object) => Padding(
        padding: EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(ImageNames.sammiImages.cool),
            GestureDetector(
              onTapUp: (_) => showDialog(
                      context: context,
                      builder: (_) =>
                          ClassSearchSettingsModal(object.object.id))
                  .then((result) async {
                if (result is Map) {
                  DartNotificationCenter.post(
                    channel: NotificationChannels.presentViewOverTabBar,
                    options: AddClassesView(),
                  );
                }
              }),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                margin: EdgeInsets.only(left: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: UIAssets.boxShadow),
                child: Text(
                  'Join your new classes',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget createSammiSyllabusInstructionCard(_CardObject object) {
    return GestureDetector(
      onTapUp: (details) => tappedSammiExplanation(
          SammiExplanationType.needsSetup, object.object.id),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 0, 4),
        child: SammiSpeechBubble(
          sammiPersonality: SammiPersonality.cool,
          speechBubbleContents: Text.rich(
            TextSpan(text: 'Please feed me your', children: [
              TextSpan(
                  text: ' syllabus 🍔',
                  style: TextStyle(
                      color: SKColors.skoller_blue,
                      fontWeight: FontWeight.bold)),
              TextSpan(text: ' I\'m hungry'),
            ]),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget createSammiSecondClassCard() {
    return GestureDetector(
      onTapUp: tappedAddClasses,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
        child: SammiSpeechBubble(
          sammiPersonality: SammiPersonality.cool,
          speechBubbleContents: Text.rich(
            TextSpan(
                text: 'Hey ${SKUser.current.student.nameFirst},\n',
                children: [
                  TextSpan(
                      text: 'You got your first class set up! Now,\n',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  TextSpan(
                      text: 'Join your 2nd class ',
                      style: TextStyle(color: SKColors.skoller_blue)),
                ]),
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget createSammiPrompt() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: tappedAddClasses,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        color: Colors.transparent,
        child: SammiSpeechBubble(
          speechBubbleContents: Text.rich(
            TextSpan(
              text: 'School has never been this easy.',
              children: [
                TextSpan(
                    text: ' Add your first class!',
                    style: TextStyle(color: SKColors.skoller_blue))
              ],
            ),
          ),
          sammiPersonality: SammiPersonality.ooo,
        ),
      ),
    );
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
              builder: (context) => ClassDetailView(classId: studentClass.id),
              settings: RouteSettings(name: 'ClassDetailView'),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                selectedIndex == index ? SKColors.selected_gray : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: SKColors.border_gray,
            ),
            boxShadow: UIAssets.boxShadow),
        margin: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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
                textScaleFactor: 1,
                style: TextStyle(
                    color: Colors.white, fontSize: 17, letterSpacing: -0.75),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        studentClass.name,
                        textScaleFactor: 1,
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
                          '${studentClass.enrollment - 1} classmate${studentClass.enrollment == 1 ? '' : 's'}',
                          textScaleFactor: 1,
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
                          textScaleFactor: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14),
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
        needsAssignments
            ? tappedAddAssignment(studentClass.id)
            : tappedSammiExplanation(
                SammiExplanationType.needsSetup, studentClass.id);
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                selectedIndex == index ? SKColors.selected_gray : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: SKColors.border_gray,
            ),
            boxShadow: UIAssets.boxShadow),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ),
            ),
            Expanded(
              child: Container(
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
                        textScaleFactor: 1,
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
                      textScaleFactor: 1,
                      style: TextStyle(
                          color: needsAssignments
                              ? SKColors.dark_gray
                              : SKColors.warning_red,
                          fontSize: 14),
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
        tappedSammiExplanation(SammiExplanationType.diy, studentClass.id);
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                selectedIndex == index ? SKColors.selected_gray : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: SKColors.border_gray,
            ),
            boxShadow: UIAssets.boxShadow),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            Container(
              height: 66,
              width: 58,
              alignment: Alignment.center,
              child: Image.asset(
                ImageNames.statusImages.diy,
                fit: BoxFit.fitWidth,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 1),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: SKColors.alert_orange, width: 2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        studentClass.name,
                        textScaleFactor: 1,
                        style:
                            TextStyle(fontSize: 17, color: SKColors.dark_gray),
                      ),
                    ),
                    Text(
                      'DIY required',
                      textScaleFactor: 1,
                      style:
                          TextStyle(color: SKColors.alert_orange, fontSize: 14),
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

        tappedSammiExplanation(SammiExplanationType.inReview, studentClass.id);
      },
      child: Container(
        decoration: BoxDecoration(
            color:
                selectedIndex == index ? SKColors.selected_gray : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: SKColors.border_gray,
            ),
            boxShadow: UIAssets.boxShadow),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            Expanded(
              child: Container(
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
                        textScaleFactor: 1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 17, color: SKColors.dark_gray),
                      ),
                    ),
                    Text(
                      'Syllabus in review',
                      textScaleFactor: 1,
                      style: TextStyle(color: SKColors.dark_gray, fontSize: 14),
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

  void tappedAddAssignment(int classId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AssignmentWeightView(classId),
        settings: RouteSettings(name: 'AssignmentWeightView'),
      ),
    );
  }

  void tappedSammiExplanation(SammiExplanationType type, int classId) async {
    showDialog(
      context: context,
      builder: (context) => SyllabusInstructionsModal(
        type,
        () => Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => WeightExtractionView(classId),
            settings: RouteSettings(name: 'WeightExtractionView'),
          ),
        ),
      ),
    );
  }

  void tappedAddClasses([_]) {
    DartNotificationCenter.post(
      channel: NotificationChannels.presentViewOverTabBar,
      options: AddClassesView(),
    );
  }
}
