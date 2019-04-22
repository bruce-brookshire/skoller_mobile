import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';

class CalendarView extends StatefulWidget {
  @override
  State createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final weekDayStyle = TextStyle(fontSize: 14, color: SKColors.text_light_gray);

  DateTime firstOfMonth;
  DateTime startDate;
  DateTime today;

  @override
  void initState() {
    super.initState();

    today = DateTime.now();
    firstOfMonth = DateTime(today.year, today.month, 1);
    startDate = firstOfMonth.weekday == 7
        ? firstOfMonth
        : DateTime(today.year, today.month, 1 - firstOfMonth.weekday);
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Calendar',
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: TextStyle(fontSize: 17),
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
    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(2, 1, 2, 0),
                margin: EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color: date.day == today.day && date.month == today.month
                      ? SKColors.skoller_blue
                      : null,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: date.month == firstOfMonth.month
                          ? (date.day == today.day
                              ? Colors.white
                              : SKColors.dark_gray)
                          : SKColors.text_light_gray),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(2.5, 1.5, 2.5, 4),
              decoration: BoxDecoration(
                color: date.month == firstOfMonth.month
                    ? Colors.white
                    : SKColors.inactive_gray,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: SKColors.border_gray),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 1.75),
                    blurRadius: 3,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
