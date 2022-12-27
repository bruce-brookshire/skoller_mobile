import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';

final _colors = [
  Color(0xFF9b55e5), // 0purple
  Color(0xFFff71a8), // 1pink
  Color(0xFF1088b3), // 2blue
  Color(0xFF4cd8bd), // 3mint
  Color(0xFF4add58), // 4green
  Color(0xFFf7d300), // 5yellow
  Color(0xFFffae42), // 6orange
  Color(0xFFdd4a63), // 7red
];

class _CalendarItem {
  final String name;
  final int color;

  _CalendarItem(this.name, this.color);
}

class CalendarTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;
  final bool showSammi;

  CalendarTutorialView(this.onTapDismiss, this.promptMsg,
      {this.showSammi = true});

  final firstOfMonth = DateTime(2019, 10, 1);
  final startDate = DateTime(2019, 9, 29);
  final today = DateTime(2019, 10, 15);

  final Map<String, List<_CalendarItem>> assignments = {
    '10-2': [_CalendarItem('Reading Quiz 1', 3)],
    '10-4': [_CalendarItem('Assignment 1', 2)],
    '10-8': [_CalendarItem('Speech Outline', 0)],
    '10-14': [_CalendarItem('Assignment 2', 2)],
    '10-11': [
      _CalendarItem('Speech Outline', 0),
      _CalendarItem('Reading Quiz 3', 3),
    ],
    '10-22': [_CalendarItem('Reading Quiz 4', 3)],
    '10-25': [_CalendarItem('Lab Quiz 4', 1)],
    '10-28': [_CalendarItem('Final', 2)],
    '10-30': [
      _CalendarItem('Research Checkpoint', 4),
      _CalendarItem('Assignment 4', 2),
    ],
  };

  List<_CalendarItem> assignmentsForDate(DateTime day) {
    return assignments['${day.month}-${day.day}'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: calendarBody(),
    );
    if (!showSammi)
      return body;
    else
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SKNavView(
            title: 'Calendar',
            leftBtn: Image.asset(ImageNames.peopleImages.static_profile),
            rightBtn: Image.asset(ImageNames.rightNavImages.plus),
            children: [
              Container(
                color: Colors.white,
                height: 64,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                margin: EdgeInsets.only(bottom: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('MMMM, yyyy').format(firstOfMonth),
                ),
              ),
              Expanded(child: body)
            ],
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Align(
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: (_) => DartNotificationCenter.post(
                        channel: NotificationChannels.selectTab,
                        options: 0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                            color: SKColors.skoller_blue1),
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTapUp: (_) => DartNotificationCenter.post(
                        channel: NotificationChannels.selectTab,
                        options: 2,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                            color: SKColors.skoller_blue1),
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 48),
                      child: SammiSpeechBubble(
                        sammiPersonality: SammiPersonality.ooo,
                        speechBubbleContents: Text.rich(
                          TextSpan(text: 'Calendar', children: [
                            TextSpan(
                                text:
                                    ' gives a bird\'s eye view of your entire semester.',
                                style: TextStyle(fontWeight: FontWeight.normal))
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTapUp: (details) => onTapDismiss(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                margin: EdgeInsets.only(bottom: 48),
                decoration: BoxDecoration(
                  color: SKColors.skoller_blue1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white),
                  boxShadow: UIAssets.boxShadow,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    promptMsg,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
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

    final dayListAssignments = assignmentsForDate(date);

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
            child: Container(
              margin: EdgeInsets.fromLTRB(2, 1.5, 2, 4),
              padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.white : SKColors.inactive_gray,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 1.75),
                    blurRadius: 3,
                  )
                ],
              ),
              child: ListView(
                children: dayListAssignments
                    .map(
                      (assignment) => Container(
                        margin: EdgeInsets.only(bottom: 2),
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _colors[assignment.color]
                              : Color(0xFFD0D0D0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.centerLeft,
                        height: 14,
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
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
