import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/chat/chat_info_view.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';

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

  void tappedCreatePost() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SKColors.border_gray)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 16, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTapUp: (details) {
                              Navigator.pop(context, false);
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: SKColors.warning_red,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Create a post',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTapUp: (details) {
                              Navigator.pop(context, true);
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8),
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: SKColors.skoller_blue,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.all(8),
                      child: CupertinoTextField(
                        decoration: BoxDecoration(border: null),
                        maxLength: 2000,
                        maxLengthEnforced: true,
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        // controller: controller,
                        placeholder: 'What\'s on your mind?',
                        style: TextStyle(
                            color: SKColors.dark_gray,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      isBack: false,
      title: 'Chat',
      rightBtnImage: ImageNames.rightNavImages.plus,
      callbackRight: tappedCreatePost,
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

    return GestureDetector(
      onTapUp: (details) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ChatInfoView(chat.id),
          ),
        );
      },
      child: Container(
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
                  onTapUp: (details) {
                    chat.toggleLike().then((success) {
                      if (success) {
                        setState(() {});
                      }
                    });
                  },
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
                    chat.toggleStar().then((success) {
                      if (success) {
                        setState(() {});
                      }
                    });
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
      ),
    );
  }
}
