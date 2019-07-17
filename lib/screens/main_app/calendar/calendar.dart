import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:skoller/screens/main_app/classes/assignment_info_view.dart';
import 'package:skoller/screens/main_app/classes/assignment_weight_view.dart';
import 'package:skoller/tools.dart';

class CalendarView extends StatefulWidget {
  @override
  State createState() => _CalendarState();
}

class _CalendarState extends State<CalendarView> {
  final weekDayStyle = TextStyle(fontSize: 14, color: SKColors.text_light_gray);

  DateTime firstOfMonth;
  DateTime startDate;
  DateTime today;

  Map<String, List<Assignment>> assignments = {};

  @override
  void initState() {
    super.initState();

    today = DateTime.now();
    firstOfMonth = DateTime(today.year, today.month, 1);
    startDate = firstOfMonth.weekday == 7
        ? firstOfMonth
        : DateTime(today.year, today.month, 1 - firstOfMonth.weekday);

    Assignment.getAssignments().then((response) {
      if (response.wasSuccessful()) {
        updateAssignments(response.obj);
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to get assignments',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
    updateAssignments(Assignment.currentAssignments.values);
  }

  void updateAssignments(Iterable<Assignment> new_assignments) {
    print(Assignment.currentAssignments[2072] == null);
    assignments = {};
    //Add assignments to the day hash map
    for (var assignment in new_assignments) {
      if (assignment.due != null && assignment.parentClass != null) {
        final dateStr = createDateStr(assignment.due);

        if (assignments[dateStr] == null) {
          assignments[dateStr] = [assignment];
        } else {
          assignments[dateStr].add(assignment);
        }
      }
    }
    setState(() {});
  }

  String createDateStr(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  void tappedNextMonth(dynamic details) {
    setState(() {
      firstOfMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 1);
      startDate = firstOfMonth.weekday == 7
          ? firstOfMonth
          : DateTime(
              firstOfMonth.year, firstOfMonth.month, 1 - firstOfMonth.weekday);
    });
  }

  void tappedPreviousMonth(dynamic details) {
    setState(() {
      firstOfMonth = DateTime(firstOfMonth.year, firstOfMonth.month - 1, 1);
      startDate = firstOfMonth.weekday == 7
          ? firstOfMonth
          : DateTime(
              firstOfMonth.year, firstOfMonth.month, 1 - firstOfMonth.weekday);
    });
  }

  void tappedAdd(BuildContext context) async {
    final classes = StudentClass.currentClasses.values.toList();

    if (classes.length == 0) {
      return;
    }

    classes.sort((class1, class2) {
      return class1.name.compareTo(class2.name);
    });

    int selectedIndex = 0;

    final result = await showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Select a class',
        subtitle: 'Choose a class to add an assignment to',
        items: classes.map((cl) => cl.name).toList(),
        onSelect: (newIndex) => selectedIndex = newIndex,
      ),
    );

    // final result = await showCupertinoDialog(
    //     context: context,
    //     builder: (context) {
    //       return CupertinoAlertDialog(
    //         title: Column(
    //           children: <Widget>[
    //             Text(
    //               'Add an assignment',
    //               style: TextStyle(fontSize: 16),
    //             ),
    //             Container(
    //               padding: EdgeInsets.only(bottom: 8, top: 2),
    //               child: Text(
    //                 'Select a class',
    //                 style:
    //                     TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    //               ),
    //             ),
    //           ],
    //         ),
    //         content: Container(
    //           decoration: BoxDecoration(
    //             border: Border(
    //               bottom: BorderSide(color: SKColors.border_gray),
    //               top: BorderSide(color: SKColors.border_gray),
    //             ),
    //           ),
    //           height: 180,
    //           child: CupertinoPicker.builder(
    //             backgroundColor: Colors.white,
    //             childCount: classes.length,
    //             itemBuilder: (context, index) => Container(
    //               alignment: Alignment.center,
    //               child: Text(
    //                 classes[index].name,
    //                 style: TextStyle(fontSize: 15),
    //               ),
    //             ),
    //             itemExtent: 32,
    //             onSelectedItemChanged: (index) => selectedIndex = index,
    //           ),
    //         ),
    //         actions: <Widget>[
    //           CupertinoDialogAction(
    //             child: Text(
    //               'Cancel',
    //               style: TextStyle(color: SKColors.skoller_blue, fontSize: 16),
    //             ),
    //             isDefaultAction: false,
    //             onPressed: () {
    //               Navigator.pop(context, false);
    //             },
    //           ),
    //           CupertinoDialogAction(
    //             child: Text(
    //               'Select',
    //               style: TextStyle(
    //                   color: SKColors.skoller_blue,
    //                   fontWeight: FontWeight.bold,
    //                   fontSize: 16),
    //             ),
    //             isDefaultAction: true,
    //             onPressed: () {
    //               Navigator.pop(context, true);
    //             },
    //           )
    //         ],
    //       );
    //     });

    if (result is bool && result) {
      final class_id = classes[selectedIndex].id;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AssignmentWeightView(class_id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      title: 'Calendar',
      rightBtn: Image.asset(ImageNames.rightNavImages.plus),
      callbackRight: () {
        tappedAdd(context);
      },
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTapUp: tappedPreviousMonth,
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset(ImageNames.navArrowImages.left),
                ),
              ),
              Container(
                child: Text(
                  DateFormat('MMMM yyyy').format(firstOfMonth),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTapUp: tappedNextMonth,
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset(ImageNames.navArrowImages.right),
                ),
              ),
            ],
          ),
        ),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(color: SKColors.text_light_gray))),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            margin: EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('U', style: weekDayStyle),
                Text('M', style: weekDayStyle),
                Text('T', style: weekDayStyle),
                Text('W', style: weekDayStyle),
                Text('R', style: weekDayStyle),
                Text('F', style: weekDayStyle),
                Text('S', style: weekDayStyle),
              ],
            )),
        ...calendarBody(),
        Container(
          height: 4,
          child: null,
        )
      ],
    );
  }

  List<Widget> calendarBody() {
    return <Widget>[
      week(startDate),
      week(DateTime(startDate.year, startDate.month, startDate.day + 7)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 14)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 21)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 28)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 35)),
    ];
  }

  Widget week(DateTime date) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: <Widget>[
            day(date),
            day(DateTime(date.year, date.month, date.day + 1)),
            day(DateTime(date.year, date.month, date.day + 2)),
            day(DateTime(date.year, date.month, date.day + 3)),
            day(DateTime(date.year, date.month, date.day + 4)),
            day(DateTime(date.year, date.month, date.day + 5)),
            day(DateTime(date.year, date.month, date.day + 6)),
          ],
        ),
      ),
    );
  }

  Widget day(DateTime date) {
    final isCurrent = date.month == firstOfMonth.month;
    final dateStr = createDateStr(date);

    final dayListAssignments = assignments[dateStr] ?? [];
    final endIndex =
        dayListAssignments.length <= 4 ? dayListAssignments.length : 4;
    final dayAssignments =
        (assignments[createDateStr(date)] ?? []).getRange(0, endIndex);

    final List<Widget> widgetAssignments = dayAssignments
        .map(
          (assignment) => Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 2),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: !isCurrent
                    ? Color(0xFFD0D0D0)
                    : assignment.parentClass.getColor(),
                borderRadius: BorderRadius.circular(3),
              ),
              // alignment: Alignment.center,
              child: Text(
                assignment.name,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    letterSpacing: -0.8,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
          ),
        )
        .toList();

    while (widgetAssignments.length < 4) {
      widgetAssignments.add(
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 2),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(2, 1, 2, 0),
                margin: EdgeInsets.only(left: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: date.day == today.day &&
                          date.month == today.month &&
                          isCurrent
                      ? SKColors.skoller_blue
                      : null,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: isCurrent
                          ? (date.day == today.day && date.month == today.month
                              ? Colors.white
                              : SKColors.dark_gray)
                          : SKColors.text_light_gray),
                ),
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                if (!isCurrent) {
                  if (date.month < firstOfMonth.month) {
                    this.tappedPreviousMonth(details);
                  } else {
                    this.tappedNextMonth(details);
                  }
                } else if (endIndex > 0) {
                  this.detailModal(dayListAssignments);
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(2, 1.5, 2, 4),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: date.month == firstOfMonth.month
                      ? Colors.white
                      : SKColors.inactive_gray,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      offset: Offset(0, 1.75),
                      blurRadius: 3,
                    )
                  ],
                ),
                child: widgetAssignments.length == 0
                    ? null
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widgetAssignments,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void detailModal(List<Assignment> dateAssignments) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(dateAssignments.first.due),
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  ...generateAssignmentCells(context, dateAssignments),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(color: SKColors.skoller_blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    if (result != null && result is Assignment) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AssignmentInfoView(
            assignment_id: result.id,
          ),
        ),
      );
    }
  }

  List<Widget> generateAssignmentCells(
    BuildContext context,
    List<Assignment> dateAssignments,
  ) =>
      dateAssignments
          .map(
            (assignment) => GestureDetector(
              onTapUp: (details) {
                Navigator.pop(context, assignment);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: assignment.parentClass.getColor()),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      assignment.name,
                      style: TextStyle(
                        color: assignment.parentClass.getColor(),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      assignment.parentClass.name,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
          )
          .toList();
}
