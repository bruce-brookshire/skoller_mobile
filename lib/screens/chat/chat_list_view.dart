import 'package:flutter/material.dart';
import '../../requests/requests_core.dart';
import '../../constants/constants.dart';

class ChatListView extends StatefulWidget {
  @override
  State createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();

    Chat.getStudentChats().then((response) {
      if (response.wasSuccessful()) {
        setState(() => chats = response.obj);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      isBack: false,
      title: 'Chat',
      rightBtnImage: ImageNames.rightNavImages.plus,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemCount: chats.length,
            itemBuilder: buildCard,
          ),
        )
      ],
    );
  }

  Widget buildCard(BuildContext context, int index) {
    Chat chat = chats[index];
    Color classColor = chat.parentClass.getColor();

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
                    color: classColor,
                  ),
                  child: Text(
                    '${chat.student.name_first[0]}${chat.student.name_last[0]}',
                    style: TextStyle(color: Colors.white),
                  )),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${chat.student.name_first} ${chat.student.name_last}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      chat.parentClass.name,
                      style: TextStyle(color: classColor, fontSize: 14),
                    )
                  ],
                ),
              ),
              Text(
                'Now',
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
              chat.post ?? 'Loading...',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {},
                child: Container(
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
                          '${chat.likes?.length ?? 0}',
                          style: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
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
                      '${chat.comments?.length ?? 0}',
                      style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  print('hit it');
                },
                child: Container(
                  padding: EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Image.asset(
                    chat.isStarred
                        ? ImageNames.chatImages.star_yellow
                        : ImageNames.chatImages.star_gray,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
