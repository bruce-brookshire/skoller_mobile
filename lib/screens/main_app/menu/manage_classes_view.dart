import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/classes/class_info_view.dart';

class ManageClassesView extends StatefulWidget {
  @override
  State createState() => _ManageClassesViewState();
}

class _ManageClassesViewState extends State<ManageClassesView> {
  List<StudentClass> classes = [];

  @override
  void initState() {
    super.initState();

    updateClasses();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.classChanged,
        onNotification: updateClasses);
  }

  void updateClasses([dynamic options]) async {
    final newClasses = StudentClass.currentClasses.values.toList()
      ..sort((class1, class2) => class1.name.compareTo(class2.name));

    setState(() {
      classes = newClasses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      title: 'Classes',
      rightBtn: Image.asset(ImageNames.rightNavImages.add_class),
      callbackRight: () => Navigator.push(
            context,
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => AddClassesView(),
            ),
          ),
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(8, 6, 8, 12),
            itemCount: classes.length,
            itemBuilder: (context, index) => GestureDetector(
                  onTapUp: (details) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ClassInfoView(classes[index].id),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: SKColors.border_gray),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: createClassCard(classes[index]),
                  ),
                ),
          ),
        )
      ],
    );
  }

  Widget createClassCard(StudentClass studentClass) => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  studentClass.name,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '${studentClass.enrollment ?? 0}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              Image.asset(ImageNames.peopleImages.person_dark_gray),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${studentClass.professor?.first_name ?? ''} ${studentClass.professor?.last_name ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${studentClass.subject} ${studentClass.code}.${studentClass.section}',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              ),
              Text(
                '${studentClass.meetDays ?? ''} ${studentClass.meetTime?.format(context) ?? ''}',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              )
            ],
          ),
        ],
      );
}
