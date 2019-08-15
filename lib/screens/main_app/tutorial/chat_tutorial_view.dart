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

class ChatTutorialView extends StatelessWidget {
  final VoidCallback onTapDismiss;
  final String promptMsg;

  ChatTutorialView(this.onTapDismiss, this.promptMsg);

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
                padding: EdgeInsets.only(top: 72),
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
                                ' enables classmates to tackle problems, together.',
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
