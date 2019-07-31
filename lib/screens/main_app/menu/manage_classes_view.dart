import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/classes/class_info_view.dart';

class ManageClassesView extends StatefulWidget {
  @override
  State createState() => _ManageClassesState();
}

class _ManageClassesState extends State<ManageClassesView> {
  List<StudentClass> classes = [];
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    loadClasses();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.classChanged,
        onNotification: loadClasses);
  }

  @override
  void dispose() {
    super.dispose();
    DartNotificationCenter.unsubscribe(observer: this);
  }

  Future fetchClasses() async {
    await StudentClass.getStudentClasses();
    loadClasses();
  }

  void loadClasses([dynamic options]) {
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
      title: 'My Classes',
      rightBtn: Image.asset(ImageNames.rightNavImages.add_class),
      callbackRight: () => Navigator.push(
        context,
        CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) => AddClassesView(),
        ),
      ).then((val) {
        //Should we propogate pop?
        if (val is bool) {
          Navigator.pop(context, val);
        }
      }),
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchClasses,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 12),
              itemCount: classes.length,
              itemBuilder: (context, index) => GestureDetector(
                onTapUp: (details) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ClassInfoView(
                        classes[index].id,
                        isClassesTab: false,
                      ),
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
                  '${studentClass.professor?.firstName ?? ''} ${studentClass.professor?.lastName ?? ''}',
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
