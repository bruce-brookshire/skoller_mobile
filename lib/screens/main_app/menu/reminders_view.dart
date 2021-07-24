import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class RemindersView extends StatefulWidget {
  @override
  State createState() => _RemindersState();
}

class _RemindersState extends State<RemindersView> {
  late DateTime defaultTime;

  @override
  void initState() {
    final now = DateTime.now();
    defaultTime = DateTime(now.year, now.month, now.day, 9);

    super.initState();
  }

  void tappedTimeOnDue(TapUpDetails details) async {
    final result = await presentTimePicker(
        SKUser.current!.student.notificationTime ?? defaultTime, false);

    if (result != null) {
      SKUser.current!
          .update(notificationTime: result)
          .then((response) => setState(() {}));
    }
  }

  void tappedTimeBeforeDue(TapUpDetails details) async {
    final result = await presentTimePicker(
        SKUser.current!.student.futureNotificationTime ?? defaultTime, true);

    if (result != null) {
      SKUser.current!
          .update(futureNotificationTime: result)
          .then((response) => setState(() {}));
    }
  }

  Future<DateTime> presentTimePicker(
      DateTime previousVal, bool upcoming) async {
    DateTime selectedDate = previousVal;

    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 2),
              child: Text(
                'Notification time',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Select the time you would like to be notified ${upcoming ? 'about upcoming assignments.' : 'of assignments on their due date.'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              ),
            ),
            Container(
              height: 180,
              child: CupertinoDatePicker(
                initialDateTime:
                    selectedDate.minute % 5 != 0 ? defaultTime : selectedDate,
                minuteInterval: 5,
                onDateTimeChanged: (date) => selectedDate = date,
                mode: CupertinoDatePickerMode.time,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                            color: SKColors.skoller_blue,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context, selectedDate),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Select',
                        style: TextStyle(color: SKColors.skoller_blue),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void tappedSelectDaysOut(TapUpDetails details) async {
    int selectedIndex = SKUser.current!.student.notificationDays ?? 0;

    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 2),
              child: Text(
                'Notification time',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'How many days before a due date would you like to start getting reminders?',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              ),
            ),
            Container(
              height: 180,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                onSelectedItemChanged: (index) => selectedIndex = index,
                itemExtent: 32,
                childCount: 8,
                itemBuilder: (context, index) => Container(
                  alignment: Alignment.center,
                  child: Text(
                    index == 0
                        ? 'Day of only'
                        : '${index} day${index == 1 ? '' : 's'} before',
                    style: TextStyle(color: SKColors.dark_gray, fontSize: 18),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context, false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                            color: SKColors.skoller_blue,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context, true),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Select',
                        style: TextStyle(color: SKColors.skoller_blue),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (result is bool && result) {
      SKUser.current!
          .update(notificationDays: selectedIndex)
          .then((response) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabledReminderCount = StudentClass.currentClasses.values
        .toList()
        .fold<int>(0, (acc, elem) => elem.isNotifications ? acc : (acc + 1));

    return SKNavView(
      title: 'Reminders',
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: UIAssets.boxShadow,
                ),
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Upcoming assignments',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            'Schedule reminders for your To-Do\'s',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'On due date',
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 4, 4, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'What time?',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: tappedTimeOnDue,
                                  child: Text(
                                    TimeOfDay.fromDateTime(SKUser.current!
                                                .student.notificationTime ??
                                            defaultTime)
                                        .format(context),
                                    style:
                                        TextStyle(color: SKColors.skoller_blue),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            'Before due date',
                            style: TextStyle(fontSize: 17),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Start reminders',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: tappedSelectDaysOut,
                                  child: Text(
                                    '${SKUser.current!.student.notificationDays ?? 1} day${(SKUser.current!.student.notificationDays ?? 1) == 1 ? '' : 's'} out',
                                    style:
                                        TextStyle(color: SKColors.skoller_blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'What time?',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                GestureDetector(
                                  onTapUp: tappedTimeBeforeDue,
                                  child: Text(
                                    TimeOfDay.fromDateTime(SKUser
                                                .current!
                                                .student
                                                .futureNotificationTime ??
                                            defaultTime)
                                        .format(context),
                                    style:
                                        TextStyle(color: SKColors.skoller_blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(vertical: 16),
                            height: 1,
                            color: SKColors.border_gray,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Customize by class',
                                style: TextStyle(fontSize: 16),
                              ),
                              GestureDetector(
                                onTapUp: (_) async {
                                  await Navigator.push(
                                      context,
                                      SKNavOverlayRoute(
                                        builder: (context) =>
                                            _ClassIndividualReminderSettingsModal(),
                                      ));

                                  setState(() {});
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  'Edit',
                                  style:
                                      TextStyle(color: SKColors.skoller_blue),
                                ),
                              ),
                            ],
                          ),
                          if (disabledReminderCount > 0)
                            Text(
                              'Reminders for $disabledReminderCount class${disabledReminderCount == 1 ? '' : 'es'} are turned off',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassIndividualReminderSettingsModal extends StatefulWidget {
  @override
  State createState() => _ClassIndividualReminderSettingsState();
}

class _ClassIndividualReminderSettingsState
    extends State<_ClassIndividualReminderSettingsModal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(10),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                    decoration: BoxDecoration(
                      color: SKColors.selected_gray,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Custom by class',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          'Skoller lets you turn assignment reminders on or off by class.',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ListView(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    children: StudentClass.currentClasses.values
                        .map(generateClassSettingsRow)
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget generateClassSettingsRow(StudentClass studentClass) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              studentClass.name!,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
            Switch(
              value: studentClass.isNotifications,
              activeColor: SKColors.skoller_blue,
              onChanged: (newVal) {
                studentClass.toggleIsNotifications().then((success) {
                  if (!success)
                    setState(
                      () => StudentClass.currentClasses[studentClass.id]!
                          .isNotifications = !studentClass.isNotifications,
                    );
                });
                setState(() {});
              },
            )
          ],
        ),
      );
}
