import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class ChatInfoView extends StatefulWidget {
  final int chatId;

  ChatInfoView(this.chatId);

  @override
  State createState() => _ChatInfoViewState();
}

class _ChatInfoViewState extends State<ChatInfoView> {
  TextEditingController commentFieldController = TextEditingController();
  FocusNode commentFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Chat.currentChats[widget.chatId].refetch().then((response) {
      if (response.wasSuccessful()) {
        setState(() {});
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to get updated chat',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  @override
  void dispose() {
    commentFieldFocusNode.dispose();
    commentFieldController.dispose();

    super.dispose();
  }

  void tappedPost(TapUpDetails details) {
    final String post = commentFieldController.text.trim();

    if (post == '') {
      return;
    }

    Chat chat = Chat.currentChats[widget.chatId];

    chat.createChatComment(post).then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          commentFieldController.clear();
          FocusScope.of(context).unfocus();
        });
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to create comment',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  void tappedCommentReply(Comment comment) async {
    TextEditingController controller = TextEditingController();

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
                padding: EdgeInsets.only(top: 12, bottom: 4),
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
                        'Reply',
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
              Container(
                margin: EdgeInsets.fromLTRB(8, 10, 8, 2),
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
                            width: 26,
                            height: 28,
                            margin: EdgeInsets.only(right: 6),
                            padding: EdgeInsets.only(left: 1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SKColors.light_gray,
                            ),
                            child: Text(
                              '${comment.student.name_first[0]}${comment.student.name_last[0]}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal),
                            )),
                        Expanded(
                          child: Text(
                            '${comment.student.name_first} ${comment.student.name_last}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          DateUtilities.getPastRelativeString(
                              comment.insertedAt,
                              ago: false),
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
                        comment.comment ?? 'Loading...',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
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
                    controller: controller,
                    placeholder: 'Reply to a comment',
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

    final reply = controller.text.trim();

    if (result != null && result && reply != '') {
      Chat chat = Chat.currentChats[widget.chatId];
      comment
          .createReply(
        chat.parentClass?.id,
        reply,
      )
          .then((response) {
        if (response.wasSuccessful()) {
          return chat.refetch();
        } else {
          throw 'Failed to create reply';
        }
      }).then((response) {
        if (response.wasSuccessful()) {
          setState(() {});
        } else throw 'Failed to get updated chat';
      }).catchError((error) => DropdownBanner.showBanner(
                    text: error is String ? error : 'Failed to update',
                    color: SKColors.warning_red,
                    textStyle: TextStyle(color: Colors.white),
                  ));
    }
  }

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
                child: composeCommentView(),
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  commentFieldFocusNode.requestFocus();
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 7, 4, 2),
                  child: Image.asset(ImageNames.chatImages.reply_back_gray),
                ),
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
    );
  }

  List<Widget> buildCommentList(Chat chat) {
    if ((chat.comments ?? []).length == 0) {
      return [
        GestureDetector(
          onTapUp: (details) {
            commentFieldFocusNode.requestFocus();
          },
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
            comment.likes,
            () {
              comment.toggleLike(chat.classId).then((success) {
                if (success) {
                  setState(() {});
                }
              });
            },
            isStarred: comment.isStarred,
            onTappedReply: () => tappedCommentReply(comment),
            onStar: () {
              comment.toggleStar(chat.classId).then((success) {
                if (success) {
                  setState(() {});
                }
              });
            }),
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
            reply.likes,
            () {
              reply.toggleLike(chat.classId).then((success) {
                if (success) {
                  setState(() {});
                }
              });
            },
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
    int numLikes,
    VoidCallback onLiked, {
    bool isStarred,
    VoidCallback onStar,
    VoidCallback onTappedReply,
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
                onTapUp: (details) {
                  onLiked();
                },
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
                        onTapUp: (details) {
                          onTappedReply();
                        },
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
                          onStar();
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

  Widget composeCommentView() {
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
                focusNode: commentFieldFocusNode,
                placeholder: 'Respond with a comment...',
                decoration: BoxDecoration(border: null),
                controller: commentFieldController,
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
