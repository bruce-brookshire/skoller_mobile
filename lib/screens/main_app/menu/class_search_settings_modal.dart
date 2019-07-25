import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/menu/school_search_view.dart';
import 'package:skoller/tools.dart';

class ClassSearchSettingsModal extends StatefulWidget {
  final int initialPeriodId;

  ClassSearchSettingsModal(this.initialPeriodId) : super();

  @override
  State<StatefulWidget> createState() => _ClassSearchSettingsModalState();
}

class _ClassSearchSettingsModalState extends State<ClassSearchSettingsModal> {
  School school;
  Period period;

  List<Period> possiblePeriods = [];

  @override
  void initState() {
    school = SKUser.current.student.primarySchool;

    if (widget.initialPeriodId != null) {
      period = Period.currentPeriods[widget.initialPeriodId];
    }

    final now = DateTime.now();
    possiblePeriods = school.periods.toList()
      ..removeWhere((p) => now.isAfter(p.endDate));

    DartNotificationCenter.subscribe(
        channel: NotificationChannels.userChanged,
        observer: this,
        onNotification: updateSettings);

    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    super.dispose();
  }

  void updateSettings([dynamic options]) {
    if (options is School) {
      school = options;
      period = null;

      final now = DateTime.now();
      possiblePeriods = school.periods.toList()
        ..removeWhere((p) => now.isAfter(p.endDate));

      if (mounted) setState(() {});
      tappedPeriod(null);
    }
  }

  void tappedPeriod(TapUpDetails details) async {
    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Select semester',
        items: possiblePeriods.map((period) => period.name).toList(),
        onSelect: (index) => setState(() {
          period = possiblePeriods[index];
        }),
      ),
    );
  }

  void tappedSchool(TapUpDetails details) {
    Navigator.push(
      context,
      SKNavFadeUpRoute(
        builder: (context) => SchoolSearchView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'School and Term',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, left: 8),
                child: Text(
                  'School',
                  style: TextStyle(
                      color: SKColors.light_gray,
                      fontWeight: FontWeight.normal,
                      fontSize: 13),
                ),
              ),
              GestureDetector(
                onTapUp: tappedSchool,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: SKColors.background_gray,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          school?.name ?? 'N/A',
                          style: TextStyle(color: SKColors.skoller_blue),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(ImageNames.navArrowImages.down),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, left: 8),
                child: Text(
                  'Semester',
                  style: TextStyle(
                      color: SKColors.light_gray,
                      fontWeight: FontWeight.normal,
                      fontSize: 13),
                ),
              ),
              GestureDetector(
                onTapUp: tappedPeriod,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: SKColors.background_gray,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          period?.name ?? 'N/A',
                          style: TextStyle(color: SKColors.skoller_blue),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(ImageNames.navArrowImages.down),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: (details) {
                  Navigator.pop(context, {'school': school, 'period': period});
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 4),
                  child: Text(
                    'Save',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SKColors.skoller_blue),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
