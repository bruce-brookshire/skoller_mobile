import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/tutorial/activity_tutorial_view.dart';
import 'package:skoller/screens/main_app/tutorial/calendar_tutorial_view.dart';
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
  List<StatelessWidget> views;

  final List<String> _indexIconPartialPaths = [
    'todos_',
    'calendar_',
    'classes_',
    'activity_',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    views = [
      TodoTutorialView(() => widget.onTapDismiss(context), widget.promptMsg),
      CalendarTutorialView(() => widget.onTapDismiss(context), widget.promptMsg),
      _ViewFour(() => widget.onTapDismiss(context), widget.promptMsg),
      ActivityTutorialView(() => widget.onTapDismiss(context), widget.promptMsg),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) {
          return CupertinoPageScaffold(child: views[index]);
        });
      },
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        items: List.generate(5, createTabIndex),
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  BottomNavigationBarItem createTabIndex(int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
          'image_assets/tab_bar_assets/${_indexIconPartialPaths[index]}${_selectedIndex == index ? 'blue' : 'gray'}.png'),
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
    _GradesCellItem('Calculus I', 89, 9, 0.13, 0),
    _GradesCellItem('Cultural Rhetorics of Film', 97, 7, 0.27, 6),
    _GradesCellItem('Financial Accounting', 92, 16, 0.23, 1),
    _GradesCellItem('Microeconomics', 88, 14, 0.4, 3),
    _GradesCellItem('Philosophy 101', 94, 13, 0.68, 2),
    _GradesCellItem('Research', 99, 5, 0.35, 4),
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
        Material(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Padding(
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
                Spacer(),
                GestureDetector(
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
                    child: Text(
                      promptMsg,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
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
            child: Text(
              grade == null
                  ? '--%'
                  : '${NumberUtilities.formatGradeAsPercent(grade)}',
              textScaleFactor: 1,
              style: TextStyle(
                  color: Colors.white, fontSize: 17, letterSpacing: -0.75),
            ),
          ),
          Container(
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
                        fontSize: 17, color: _colors[studentClass.color]),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 5, bottom: 2),
                      child:
                          Image.asset(ImageNames.peopleImages.person_dark_gray),
                    ),
                    Text(
                      '${studentClass.classmates - 1} classmate${(studentClass.classmates - 1) == 1 ? '' : 's'}',
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
        ],
      ),
    );
  }
}
