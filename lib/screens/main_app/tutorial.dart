import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';

class TutorialTab extends StatefulWidget {
  final VoidCallback onTapDismiss;

  TutorialTab(this.onTapDismiss);

  @override
  State createState() => _TutorialTabState();
}

class _TutorialTabState extends State<TutorialTab> {
  List<StatelessWidget> views;

  final List<String> _indexIconPartialPaths = [
    'tasks_',
    'calendar_',
    'chat_',
    'classes_',
    'activity_',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    views = [
      _ViewOne(widget.onTapDismiss),
      _ViewTwo(widget.onTapDismiss),
      _ViewThree(widget.onTapDismiss),
      _ViewFour(widget.onTapDismiss),
      _ViewFive(widget.onTapDismiss),
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

class _TaskCellItem {
  final String name;
  final String className;
  final int color;
  final String due;
  final double completion;

  _TaskCellItem(
      this.name, this.className, this.color, this.due, this.completion);
}

class _ViewOne extends StatelessWidget {
  final VoidCallback onTapDismiss;

  _ViewOne(this.onTapDismiss);

  final items = [
    _TaskCellItem('Reading Quiz', 'World Religions', 6, 'Today', 0.3),
    _TaskCellItem('Assignment 1', 'Calculus I', 2, 'Today', 0.1),
    _TaskCellItem('Speech 1 Outline', 'Public Speaking', 0, 'Tomorrow', 0.01),
    _TaskCellItem('Group Persuasion', 'Entrepreneurship', 3, 'Thursday', 0.1),
    _TaskCellItem('Quiz 1', 'Environmental Science', 1, 'Friday', 0.1),
    _TaskCellItem('Speech 1 Presentation', 'Public Speaking', 0, 'Monday', 0.3),
    _TaskCellItem('Assignment 2', 'Calculus I', 2, 'Monday', 0.1),
    _TaskCellItem(
        'Creative Writing Assignment', 'Entrepreneurship', 3, 'Monday', 0.3),
    _TaskCellItem('Speech 2 Outline', 'Public Speaking', 0, '6 days', 0.3),
    _TaskCellItem('Terms and Names', 'World Religions', 6, '8 days', 0.3),
    _TaskCellItem('Assignment 3', 'Calculus I', 2, '9 days', 0.1),
    _TaskCellItem('Quiz 2', 'Environmental Science', 1, '10 days', 0.1),
    _TaskCellItem('Final exam', 'Calculus I', 2, '10 days', 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Tasks',
          leftBtn: Image.asset(ImageNames.peopleImages.static_profile),
          rightBtn: Image.asset(ImageNames.rightNavImages.plus),
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 68),
                children: items.map(createTaskCell).toList(),
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
                    sammiPersonality: SammiPersonality.smile,
                    speechBubbleContents: Text.rich(
                      TextSpan(text: 'Tasks', children: [
                        TextSpan(
                            text:
                                ' lays out YOUR personal 10-day forecast, which updates every day!',
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
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Join your first class 👌',
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

  Widget createTaskCell(_TaskCellItem item) {
    return Container(
      margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: SKColors.border_gray, width: 1),
        boxShadow: [UIAssets.boxShadow],
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _colors[item.color],
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
                Text(
                  item.due,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                item.className,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
              SKAssignmentImpactGraph(
                item.completion,
                _colors[item.color],
                size: ImpactGraphSize.small,
              )
            ],
          )
        ],
      ),
    );
  }
}

class _CalendarItem {
  final String name;
  final int color;

  _CalendarItem(this.name, this.color);
}

class _ViewTwo extends StatelessWidget {
  final VoidCallback onTapDismiss;

  _ViewTwo(this.onTapDismiss);

  final firstOfMonth = DateTime(2019, 10, 1);
  final startDate = DateTime(2019, 9, 29);
  final today = DateTime(2019, 10, 15);

  final Map<String, List<_CalendarItem>> assignments = {
    '10-2': [_CalendarItem('Reading Quiz 1', 3)],
    '10-4': [
      _CalendarItem('Assignment 1', 2),
      _CalendarItem('Lab Quiz 1', 1),
      _CalendarItem('Research Meeting', 4),
    ],
    '10-7': [_CalendarItem('Midterm', 1)],
    '10-8': [_CalendarItem('Speech Outline', 0)],
    '10-10': [_CalendarItem('Reading Quiz 2', 3)],
    '10-14': [
      _CalendarItem('Speech Presentation', 0),
      _CalendarItem('Assignment 2', 2),
    ],
    '10-16': [_CalendarItem('Lab Quiz 3', 1)],
    '10-18': [
      _CalendarItem('Lab Quiz 2', 1),
      _CalendarItem('Reading Quiz 3', 3),
    ],
    '10-22': [
      _CalendarItem('Reading Quiz 4', 3),
      _CalendarItem('Group Presentation', 6),
    ],
    '10-24': [_CalendarItem('Assignment 3', 2)],
    '10-25': [_CalendarItem('Lab Quiz 4', 1)],
    '10-28': [_CalendarItem('Final', 2)],
    '10-30': [
      _CalendarItem('Research Checkpoint', 4),
      _CalendarItem('Assignment 4', 2),
    ],
    '10-31': [_CalendarItem('Reading Quiz 5', 3)],
  };

  List<_CalendarItem> assignmentsForDate(DateTime day) {
    return assignments['${day.month}-${day.day}'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
              height: 80,
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: calendarBody(),
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
                    sammiPersonality: SammiPersonality.ooo,
                    speechBubbleContents: Text.rich(
                      TextSpan(text: 'Calendar', children: [
                        TextSpan(
                            text:
                                ' gives you a bird\'s eye view of your assignments for the entire semester.',
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
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Join your first class 👌',
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

class _ChatCellItem {
  final String post;
  final String name;
  final String className;
  final int color;
  final int likes;
  final String date;
  final int numComments;
  final bool isLiked;
  final bool isStarred;

  _ChatCellItem(
    this.post,
    this.name,
    this.className,
    this.color,
    this.likes,
    this.date,
    this.numComments,
    this.isLiked,
    this.isStarred,
  );
}

class _ViewThree extends StatelessWidget {
  final VoidCallback onTapDismiss;

  _ViewThree(this.onTapDismiss);

  final chats = [
    _ChatCellItem(
        'I was wondering where the explanation of the equation for number 4 was in the book?',
        'Jake Smith',
        'Calculus I',
        0,
        0,
        '28 min.',
        3,
        false,
        true),
    _ChatCellItem(
        'Don\'t forget to bring your books tomorrow! There is an open notes quiz over chapter 7, and I\'ve heard its hard.',
        'Lexie Brown',
        'Financial Accounting',
        1,
        1,
        '2 days',
        1,
        true,
        true),
    _ChatCellItem(
        'Is the TA offering office hours this week? I am having trouble understanding that explanation from class yesterday.',
        'Jessie Rothschild',
        'Philosophy 101',
        2,
        1,
        '41 min.',
        5,
        false,
        false),
    _ChatCellItem(
        'Like this if you want cupcakes! I\'m bringing some to class tomorrow.',
        'Mason Ainsley',
        'Microeconomics',
        3,
        6,
        '6 hrs.',
        2,
        true,
        true),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Chat',
          leftBtn: SKHeaderProfilePhoto(),
          rightBtn: Image.asset(ImageNames.rightNavImages.plus),
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 88),
                itemCount: chats.length,
                itemBuilder: buildCard,
              ),
            )
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
                    sammiPersonality: SammiPersonality.cool,
                    speechBubbleContents: Text.rich(
                      TextSpan(text: 'Chat', children: [
                        TextSpan(
                            text:
                                ' is our community feature that offers a direct line of communication with your classmates on Skoller!',
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
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Join your first class 👌',
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

  Widget buildCard(BuildContext context, int index) {
    final chat = chats[index];

    return Container(
      margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        boxShadow: [UIAssets.boxShadow],
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: SKColors.border_gray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  width: 32,
                  height: 32,
                  margin: EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[chat.color],
                  ),
                  child: Text(
                    chat.name.split(' ').map((str) => str[0]).join(),
                    style: TextStyle(color: Colors.white),
                  )),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      chat.name,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      chat.className,
                      style:
                          TextStyle(color: _colors[chat.color], fontSize: 14),
                    )
                  ],
                ),
              ),
              Text(
                chat.date,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              ),
            ],
          ),
          Container(
            height: 1,
            color: SKColors.border_gray,
            margin: EdgeInsets.symmetric(vertical: 6),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              chat.post,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      chat.isLiked
                          ? ImageNames.chatImages.like_blue
                          : ImageNames.chatImages.like_gray,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4, left: 3),
                      child: Text(
                        '${chat.likes}',
                        style: TextStyle(
                            color: SKColors.light_gray,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, top: 5),
                    child: Image.asset(ImageNames.chatImages.commented_gray),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 3, top: 6.5),
                    child: Text(
                      '${chat.numComments}',
                      style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Image.asset(
                  chat.isStarred
                      ? ImageNames.chatImages.star_yellow
                      : ImageNames.chatImages.star_gray,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

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

  _ViewFour(this.onTapDismiss);

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
                padding: EdgeInsets.only(top: 88),
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
                                ' is a custom grade calculator for EACH class so you always know where you stand.',
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
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Join your first class 👌',
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
          boxShadow: [UIAssets.boxShadow]),
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

class _ActivityCellItem {
  final int color;
  final String date;
  final bool isMod;
  final String className;
  final String msg;

  final String modImg;

  final String postPost;
  final String postName;

  _ActivityCellItem(
    this.color,
    this.date,
    this.isMod,
    this.className,
    this.msg, {
    this.modImg,
    this.postPost,
    this.postName,
  });
}

class _ViewFive extends StatelessWidget {
  final VoidCallback onTapDismiss;

  _ViewFive(this.onTapDismiss);

  final items = [
    _ActivityCellItem(0, '48 min.', true, 'Calculus I', 'Exam 2 added',
        modImg: ImageNames.activityImages.add_white),
    _ActivityCellItem(3, '2 hrs.', false, 'Microeconomics',
        'replied to your comment on Homework 2 in',
        postName: 'Lexie Brown',
        postPost:
            'I agree, but remember that you have to take inflation into account.'),
    _ActivityCellItem(2, '7 hrs.', true, 'Philosophy 101',
        'Reading Quiz 2 due date changed to Oct. 16th',
        modImg: ImageNames.activityImages.due_white),
    _ActivityCellItem(
        3, '2 days', true, 'Microeconomics', 'Reading Response added',
        modImg: ImageNames.activityImages.add_white),
    _ActivityCellItem(1, '4 days', false, 'Financial Accounting',
        'replied to your comment on Midterm 2 in',
        postName: 'Jack Rogers',
        postPost:
            'No, section 4 will not be on the exam, but section 5 will be. Good luck studying!'),
    _ActivityCellItem(2, '5 days', false, 'Philosophy 101',
        'replied to your comment on Reading Quiz 1 in',
        postName: 'Janie Wilcox',
        postPost: 'We actually only have to read pgs. 110-132 for the quiz!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Activity',
          leftBtn: SKHeaderProfilePhoto(),
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 88),
                children: items.map(buildListItem).toList(),
              ),
            )
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
                    sammiPersonality: SammiPersonality.smile,
                    speechBubbleContents: Text.rich(
                      TextSpan(text: 'Activity', children: [
                        TextSpan(
                            text:
                                ' has changes to due dates and other suggestions from classmates.',
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
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Text(
                      'Join your first class 👌',
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

  Widget buildListItem(_ActivityCellItem item) =>
      item.isMod ? createModCard(item) : createPostCard(item);

  Widget createPostCard(_ActivityCellItem post) => Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  margin: EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[post.color],
                  ),
                  child: Text(
                    post.postName.split(' ').map((str) => str[0]).join(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                        text: post.postName,
                        children: [
                          TextSpan(
                            text: ' ${post.msg} ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: post.className,
                            style: TextStyle(color: _colors[post.color]),
                          ),
                        ],
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
                Text(
                  post.date,
                  style: TextStyle(
                    color: SKColors.text_light_gray,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                post.postPost,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              ),
            ),
          ],
        ),
      );

  Widget createModCard(_ActivityCellItem mod) => Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colors[mod.color],
              ),
              child: Image.asset(mod.modImg),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        mod.className,
                        style: TextStyle(color: _colors[mod.color]),
                      ),
                      Text(
                        mod.date,
                        style: TextStyle(
                            color: SKColors.text_light_gray,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Text(
                    mod.msg,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: SKColors.dark_gray),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
