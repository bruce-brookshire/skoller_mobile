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

  _TaskCellItem(
      this.name, this.className, this.color, this.due, this.completion);
}

class ForecastTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  ForecastTutorialView(this.onTapDismiss, this.promptMsg);

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
          title: 'Forecast',
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
                      TextSpan(text: 'Forecast', children: [
                        TextSpan(
                            text:
                                ' snapshots YOUR upcoming assignments!',
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
