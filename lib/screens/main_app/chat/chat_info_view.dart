import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/constants/constants.dart';

class ChatInfoView extends StatefulWidget {
  final int chatId;

  ChatInfoView(this.chatId);

  @override
  State createState() => _ChatInfoViewState();
}

class _ChatInfoViewState extends State<ChatInfoView> {
  TextEditingController postFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Chat.currentChats[widget.chatId].refetch().then((response) {
      if (response.wasSuccessful()) {
        setState(() {});
      }
    });
  }

  void tappedPost(TapUpDetails details) async {}

  @override
  Widget build(BuildContext context) {
    Chat chat = Chat.currentChats[widget.chatId];
    StudentClass parentClass = chat.parentClass;

    return SKNavView(
      title: parentClass.name,
      titleColor: parentClass.getColor(),
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 64, top: 6),
                    children: <Widget>[
                      buildMainPostCell(chat),
                      Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 12),
                        child: Text(
                          'Comments',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ...buildCommentList(chat),
                    ],
                  ),
                ),
              ),
              Align(
                child: composePostView(),
                alignment: Alignment.bottomCenter,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMainPostCell(Chat chat) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 3, 8, 4),
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
                  width: 28,
                  height: 28,
                  margin: EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SKColors.light_gray,
                  ),
                  child: Text(
                    '${chat.student.name_first[0]}${chat.student.name_last[0]}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
              Expanded(
                child: Text(
                  '${chat.student.name_first} ${chat.student.name_last}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                DateUtilities.getPastRelativeString(chat.postDate, ago: false),
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: SKColors.dark_gray),
              ),
            ],
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 7, 4, 2),
                  child: Image.asset(ImageNames.chatImages.reply_back_gray),
                ),
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

  List<Widget> buildCommentList(Chat chat) {
    if ((chat.comments ?? []).length == 0) {
      return [
        GestureDetector(
          onTapUp: (details) {/*TODO do something*/},
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 80),
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SKColors.skoller_blue,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [UIAssets.boxShadow],
            ),
            child: Text(
              'Add a comment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ];
    }

    List<Widget> content = [];

    chat.comments.sort(
      (comment1, comment2) =>
          comment1.insertedAt.compareTo(comment2.insertedAt),
    );

    for (final comment in chat.comments) {
      content.add(
        buildCard(
          true,
          comment.student,
          comment.comment,
          comment.insertedAt,
          comment.isLiked,
          (comment.likes ?? []).length,
          isStarred: comment.isStarred,
        ),
      );

      comment.replies.sort(
        (reply1, reply2) => reply1.insertedAt.compareTo(reply2.insertedAt),
      );

      for (final Reply reply in comment.replies ?? []) {
        content.add(
          buildCard(
            false,
            reply.student,
            reply.reply,
            reply.insertedAt,
            reply.isLiked,
            (reply.likes ?? []).length,
            isFirstReply: comment.replies.first.id == reply.id,
          ),
        );
      }
    }

    return content;
  }

  Widget buildCard(
    bool isComment,
    PublicStudent student,
    String content,
    DateTime insertedAt,
    bool isLiked,
    int numLikes, {
    bool isStarred,
    bool isFirstReply,
  }) {
    Widget cell = Container(
      margin: EdgeInsets.fromLTRB(isComment ? 8 : 4, isComment ? 10 : 4, 8, 2),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                  width: isComment ? 26 : 24,
                  height: 28,
                  margin: EdgeInsets.only(right: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SKColors.light_gray,
                  ),
                  child: Text(
                    '${student.name_first[0]}${student.name_last[0]}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isComment ? 13 : 12,
                        fontWeight: FontWeight.normal),
                  )),
              Expanded(
                child: Text(
                  '${student.name_first} ${student.name_last}',
                  style: TextStyle(fontSize: isComment ? 15 : 14),
                ),
              ),
              Text(
                DateUtilities.getPastRelativeString(insertedAt, ago: false),
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: SKColors.dark_gray),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Text(
              content ?? 'Loading...',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: isComment ? 14 : 13),
            ),
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {},
                child: Container(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        (isLiked ?? false)
                            ? ImageNames.chatImages.like_blue
                            : ImageNames.chatImages.like_gray,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 3),
                        child: Text(
                          '$numLikes',
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
              ...(isComment
                  ? [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4, 7, 4, 2),
                          child: Image.asset(
                              ImageNames.chatImages.reply_back_gray),
                        ),
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
                            (isStarred ?? false)
                                ? ImageNames.chatImages.star_yellow
                                : ImageNames.chatImages.star_gray,
                          ),
                        ),
                      )
                    ]
                  : [])
            ],
          )
        ],
      ),
    );

    if (isComment) {
      return cell;
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 12),
            alignment: Alignment.topRight,
            width: 34,
            child: isFirstReply
                ? Image.asset(ImageNames.chatImages.reply_forward_gray)
                : null,
          ),
          Expanded(child: cell),
        ],
      );
    }
  }

  Widget composePostView() {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              offset: Offset(0, 1),
              blurRadius: 3.5,
            )
          ],
          borderRadius: BorderRadius.circular(22)),
      height: 44,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 12, right: 4),
            child: Image.asset(ImageNames.peopleImages.person_blue),
          ),
          Expanded(
            child: Container(
              child: CupertinoTextField(
                placeholder: 'Write a post...',
                decoration: BoxDecoration(border: null),
                controller: postFieldController,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          GestureDetector(
            onTapUp: tappedPost,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Post',
                style: TextStyle(color: SKColors.skoller_blue, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
