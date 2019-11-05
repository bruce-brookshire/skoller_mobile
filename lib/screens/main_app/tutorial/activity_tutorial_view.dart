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

class ActivityTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  ActivityTutorialView(this.onTapDismiss, this.promptMsg);

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
                padding: EdgeInsets.only(top: 72),
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
                                ' shows schedule updates from your classmates.',
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

  Widget buildListItem(_ActivityCellItem item) =>
      item.isMod ? createModCard(item) : createPostCard(item);

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
