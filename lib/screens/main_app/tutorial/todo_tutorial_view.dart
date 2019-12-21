import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
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

class _TaskCellItem {
  final String name;
  final String className;
  final int color;
  final String due;
  final double completion;
  final bool isCompleted;

  _TaskCellItem(this.name, this.className, this.color, this.due,
      this.completion, this.isCompleted);
}

class TodoTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  TodoTutorialView(this.onTapDismiss, this.promptMsg);

  final items = [
    _TaskCellItem('Exam 1', 'World Religions', 6, 'Today', 0.3, false),
    _TaskCellItem('Assignment 7', 'Calculus I', 2, 'Tomorrow', 0.01, false),
    _TaskCellItem(
        'Speech 1 Outline', 'Public Speaking', 0, 'Thursday', 0.01, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SKNavView(
          title: 'Todo',
          leftBtn: Image.asset(ImageNames.peopleImages.static_profile),
          rightBtn: Image.asset(ImageNames.rightNavImages.plus),
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 68),
                children: items.map((a) => _TodoRow(a)).toList(),
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
                  Spacer(),
                  GestureDetector(
                    onTapUp: (_) => DartNotificationCenter.post(
                      channel: NotificationChannels.selectTab,
                      options: 2,
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
                      sammiPersonality: SammiPersonality.smile,
                      speechBubbleContents: Text.rich(
                        TextSpan(text: 'Todo', children: [
                          TextSpan(
                              text: ' snapshots YOUR upcoming assignments!',
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
}

class _TodoRow extends StatelessWidget {
  final _TaskCellItem item;

  _TodoRow(this.item);

  @override
  Widget build(BuildContext context) =>
      item.isCompleted ? buildTaskCheckedCell() : buildTasksNormalCell();

  Widget buildTaskCheckedCell() => Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray, width: 1),
          boxShadow: UIAssets.boxShadow,
          color: SKColors.menu_blue,
        ),
        child: Row(children: [
          Container(
            child: Container(
              margin: EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 2),
              decoration: BoxDecoration(
                border: Border.all(color: SKColors.text_light_gray),
                borderRadius: BorderRadius.circular(10),
                color: SKColors.skoller_blue,
              ),
              width: 20,
              height: 20,
              child: Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _colors[item.color],
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          fontSize: 17),
                    ),
                  ),
                ),
                Text(
                  item.due,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SKColors.skoller_blue,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Text(
              'Mark as complete',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10),
            ),
          ),
        ]),
      );

  Widget buildTasksNormalCell() => Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray, width: 1),
          boxShadow: UIAssets.boxShadow,
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Container(
              child: Container(
                margin: EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.text_light_gray),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: 20,
                height: 20,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            item.name ?? 'N/A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _colors[item.color],
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                fontSize: 17),
                          ),
                        ),
                      ),
                      SKAssignmentImpactGraph(
                        item.completion,
                        _colors[item.color],
                        size: ImpactGraphSize.small,
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.due,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Expanded(
                        child: Text(
                          item.className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: SKColors.text_light_gray,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
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
