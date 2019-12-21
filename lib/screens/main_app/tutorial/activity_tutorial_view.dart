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

class _ActivityCellItem {
  final int color;
  final String date;
  final String className;
  final String msg;

  final String modImg;

  final String postPost;
  final String postName;

  _ActivityCellItem(
    this.color,
    this.date,
    this.className,
    this.msg, {
    this.modImg,
    this.postPost,
    this.postName,
  });
}

class ActivityTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  ActivityTutorialView(this.onTapDismiss, this.promptMsg);

  final items = [
    _ActivityCellItem(0, '48 min.', 'Calculus I', 'Exam 2 added',
        modImg: ImageNames.activityImages.add_white),
    _ActivityCellItem(2, '7 hrs.', 'Philosophy 101', 'Due date change',
        modImg: ImageNames.activityImages.due_white),
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
                padding: EdgeInsets.only(top: 72),
                children: items.map(createModCard).toList(),
              ),
            )
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
                      options: 2,
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
                      options: 4,
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
                        TextSpan(
                          text: 'Activity',
                          children: [
                            TextSpan(
                                text:
                                    ' shows schedule updates from your classmates.',
                                style: TextStyle(fontWeight: FontWeight.normal))
                          ],
                        ),
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

  Widget createPostCard(_ActivityCellItem post) => Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: UIAssets.boxShadow,
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
          boxShadow: UIAssets.boxShadow,
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
