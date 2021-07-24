import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/menu/reminders_view.dart';
import 'package:skoller/tools.dart';

class TodoPreferencesModal extends StatefulWidget {
  @override
  State createState() => _TodoPreferencesState();
}

class _TodoPreferencesState extends State<TodoPreferencesModal> {
  late int daysPast;
  late int daysFuture;

  @override
  void initState() {
    super.initState();

    daysFuture = SKUser.current!.student.todoDaysFuture!;
    daysPast = SKUser.current!.student.todoDaysPast!;
  }

  void tappedNotifications(_) => DartNotificationCenter.post(
        channel: NotificationChannels.presentViewOverTabBar,
        options: RemindersView(),
      );

  void tappedFutureDays(_) {
    final futureOptions = [5, 10, 20, 30, 180];
    final startIndex = futureOptions.indexOf(daysFuture);

    showDialog(
      context: context,
      builder: (_) => SKPickerModal(
        title: 'Future Assignments',
        subtitle: 'How far ahead should assignments show?',
        items: futureOptions.map((e) {
          if (e == 180)
            return 'Full semester';
          else
            return '$e days';
        }).toList(),
        startIndex: startIndex == -1 ? 0 : startIndex,
        onSelect: (index) => setState(() => daysFuture = futureOptions[index]),
      ),
    );
  }

  void tappedPastDays(_) {
    showDialog(
      context: context,
      builder: (_) => SKPickerModal(
        title: 'Overdue Assignments',
        subtitle: 'When should overdue assignments disappear?',
        items: List.generate(
          7,
          (index) => '${index + 1} day${index == 0 ? '' : 's'}',
        ),
        onSelect: (index) => setState(() => daysPast = index + 1),
        startIndex: daysPast - 1,
      ),
    );
  }

  void tappedSave(_) async {
    final student = SKUser.current!.student;

    if (daysFuture == student.todoDaysFuture &&
        daysPast == student.todoDaysPast)
      Navigator.pop(context);
    else {
      final loader = SKLoadingScreen.fadeIn(context);

      final result = await SKUser.current!
          .update(todoDaysFuture: daysFuture, todoDaysPast: daysPast);

      loader.fadeOut();

      if (result) {
        Navigator.pop(context, true);
      } else
        DropdownBanner.showBanner(
          text: 'Failed to save preferences',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = SKUser.current!.student;
    final shouldSave = daysPast != student.todoDaysPast ||
        daysFuture != student.todoDaysFuture;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Customize To-Do\'s',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                GestureDetector(
                  onTapUp: tappedNotifications,
                  child: Image.asset(ImageNames.menuImages.reminders),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Upcoming',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'How far ahead should assignments show?',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTapUp: tappedFutureDays,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.skoller_blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  daysFuture == 180
                      ? 'Rest of the semester'
                      : '$daysFuture day${daysFuture == 1 ? '' : 's'} out',
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Past due',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'When should overdue assignments disappear?',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTapUp: tappedPastDays,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.skoller_blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$daysPast day${daysPast == 1 ? '' : 's'} after',
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ),
            GestureDetector(
              onTapUp: tappedSave,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 24),
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: shouldSave ? SKColors.success : SKColors.skoller_blue,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: shouldSave ? UIAssets.boxShadow : null,
                ),
                child: Text(
                  shouldSave ? 'Save' : 'Dismiss',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
