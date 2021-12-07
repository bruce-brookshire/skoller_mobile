import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/tutorial/calendar_tutorial_view.dart';
import 'package:skoller/screens/main_app/tutorial/jobs_tutorial_view.dart';
import 'package:skoller/screens/main_app/tutorial/todo_tutorial_view.dart';
import 'package:skoller/tools.dart';

class TutorialTab extends StatefulWidget {
  final ContextCallback onTapDismiss;
  final String promptMsg;

  TutorialTab(this.onTapDismiss, this.promptMsg);

  @override
  State createState() => _TutorialTabState();
}

class _TutorialTabState extends State<TutorialTab> {
  List<StatelessWidget>? views;

  final List<String> _indexIconPartialPaths = [
    'todos_',
    'calendar_',
    'classes_',
    'jobs_',
  ];

  final tabController = CupertinoTabController(initialIndex: 0);

  @override
  void initState() {
    final tapDismiss = () => widget.onTapDismiss(context);

    views = [
      TodoTutorialView(tapDismiss, widget.promptMsg),
      CalendarTutorialView(tapDismiss, widget.promptMsg),
      _ViewFour(tapDismiss, widget.promptMsg),
      JobsTutorialView(tapDismiss, widget.promptMsg)
    ];

    DartNotificationCenter.subscribe(
      observer: this,
      channel: NotificationChannels.selectTab,
      onNotification: (index) => setState(() => tabController.index = index),
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    DartNotificationCenter.unsubscribe(
      channel: NotificationChannels.selectTab,
      observer: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabController,
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) {
          return CupertinoPageScaffold(child: views![index]);
        });
      },
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        items: List.generate(4, createTabIndex),
        currentIndex: tabController.index,
        onTap: (index) => setState(() => tabController.index = index),
      ),
    );
  }

  BottomNavigationBarItem createTabIndex(int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
          'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${tabController.index == index ? 'blue' : 'gray'}.png'),
    );
  }
}

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

class _GradesCellItem {
  final String name;
  final double grade;
  final int classmates;
  final double completion;
  final int color;

  _GradesCellItem(
    this.name,
    this.grade,
    this.classmates,
    this.completion,
    this.color,
  );
}

class _ViewFour extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  _ViewFour(this.onTapDismiss, this.promptMsg);

  final classes = [
    _GradesCellItem('Microeconomics', 88, 18, 0.4, 3),
    _GradesCellItem('Philosophy 101', 94, 11, 0.68, 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Classes',
          leftBtn: SKHeaderProfilePhoto(),
          rightBtn: Image.asset(ImageNames.rightNavImages.add_class),
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 72),
                children: classes.map(createCompleteCard).toList(),
              ),
            ),
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
                      options: 1,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                          color: SKColors.skoller_blue),
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
                      options: 3,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                          color: SKColors.skoller_blue),
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
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTapUp: (details) => onTapDismiss(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              margin: EdgeInsets.only(bottom: 48),
              decoration: BoxDecoration(
                color: SKColors.skoller_blue,
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
                      sammiPersonality: SammiPersonality.wow,
                      speechBubbleContents: Text.rich(
                        TextSpan(text: 'Classes', children: [
                          TextSpan(
                              text:
                                  ' includes a grade calculator so you stay on track.',
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
      ],
    );
  }

  Widget createCompleteCard(_GradesCellItem studentClass) {
    final grade = studentClass.grade == 0 ? null : studentClass.grade;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
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
                color: _colors[studentClass.color],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5))),
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                grade == null
                    ? '--%'
                    : '${NumberUtilities.formatGradeAsPercent(grade)}',
                textScaleFactor: 1,
                style: TextStyle(
                    color: Colors.white, fontSize: 17, letterSpacing: -0.75),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        studentClass.name,
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _colors[studentClass.color],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 5, bottom: 2),
                        child: Image.asset(ImageNames.peopleImages.people_gray),
                      ),
                      Text(
                        '${studentClass.classmates} classmate${studentClass.classmates == 1 ? '' : 's'}',
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
    );
  }
}
