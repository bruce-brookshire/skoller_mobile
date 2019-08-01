import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/chat/chat_inbox_view.dart';
import 'package:skoller/screens/main_app/chat/chat_info_view.dart';
import 'package:skoller/tools.dart';

class ChatListView extends StatefulWidget {
  @override
  State createState() => _ChatListState();
}

class _ChatListState extends State<ChatListView> {
  List<Chat> chats = [];
  bool unreadInbox = false;

  @override
  void initState() {
    super.initState();

    Chat.getStudentChats().then(
      (response) {
        if (response.wasSuccessful()) {
          setState(() => chats = response.obj);
        } else {
          DropdownBanner.showBanner(
            text: 'Failed to get chats',
            color: SKColors.warning_red,
            textStyle: TextStyle(color: Colors.white),
          );
        }
      },
    );

    // InboxNotification.getChatInbox().then((response) {
    //   if (response.wasSuccessful()) {
    //     final needsRead = InboxNotification.currentInbox
    //         .any((inbox) => !(inbox.isRead ?? false));
    //     print(needsRead);

    //     if (needsRead) {
    //       setState(() {
    //         unreadInbox = true;
    //       });
    //     }
    //   } else {
    //     DropdownBanner.showBanner(
    //       text: 'Failed to upda',
    //       color: SKColors.warning_red,
    //       textStyle: TextStyle(color: Colors.white),
    //     );
    //   }
    // });
  }

  void tappedCheckInbox(TapUpDetails details) async {
    final chatId = await Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => ChatInboxView(),
        settings: RouteSettings(name: 'ChatInboxView'),
      ),
    );

    if (chatId != null) {
      await Chat.getStudentChats();

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ChatInfoView(chatId),
          settings: RouteSettings(name: 'ChatInfoView'),
        ),
      );
    }
  }

  void tappedCreatePost() async {
    final classes = StudentClass.currentClasses.values.toList();

    if (classes.length == 0) {
      return;
    }

    classes.sort((class1, class2) {
      return class1.name.compareTo(class2.name);
    });

    int selectedIndex = 0;

    final result1 = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: <Widget>[
                Text(
                  'Create a post',
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8, top: 2),
                  child: Text(
                    'Select a class',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            content: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: SKColors.border_gray),
                  top: BorderSide(color: SKColors.border_gray),
                ),
              ),
              height: 180,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                childCount: classes.length,
                itemBuilder: (context, index) => Container(
                  alignment: Alignment.center,
                  child: Text(
                    classes[index].name,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: SKColors.skoller_blue, fontSize: 16),
                ),
                isDefaultAction: false,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'Select',
                  style: TextStyle(
                      color: SKColors.skoller_blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });

    if (result1 == null || !result1) {
      return;
    }

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
                    controller: controller,
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

    String post = controller.text.trim();
    controller.dispose();

    if (result != null && result && post != '') {
      final loadingScreen = SKLoadingScreen.fadeIn(context);

      classes[selectedIndex]
          .createStudentChat(post)
          .then((response) {
            if (response.wasSuccessful()) {
              return (response.obj as Chat).refetch();
            } else {
              throw 'Unable to create post';
            }
          })
          .then((response) {
            if (response.wasSuccessful()) {
              setState(() {
                chats.insert(0, response.obj);
              });
            } else {
              throw 'Failed to update';
            }
          })
          .catchError((error) => DropdownBanner.showBanner(
                text: error is String ? error : 'Failed to add grade scale',
                color: SKColors.warning_red,
                textStyle: TextStyle(color: Colors.white),
              ))
          .then((response) => loadingScreen.dismiss());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 44),
                color: SKColors.background_gray,
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 4),
                          itemCount: chats.length,
                          itemBuilder: buildCard,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
              child: Container(
                height: 44,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color(0x1C000000),
                    offset: Offset(0, 3.5),
                    blurRadius: 2,
                  )
                ], color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 52, left: 8),
                      child: GestureDetector(
                        onTapUp: (details) => DartNotificationCenter.post(
                            channel: NotificationChannels.toggleMenu),
                        child: SKHeaderProfilePhoto(),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          'Chat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: tappedCheckInbox,
                          child: Container(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Image(
                                image: AssetImage(
                                  this.unreadInbox
                                      ? ImageNames.chatImages.inbox_unread
                                      : ImageNames.chatImages.inbox,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            tappedCreatePost();
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 4),
                            child: Center(
                              child: Image(
                                image:
                                    AssetImage(ImageNames.chatImages.compose),
                              ),
                            ),
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              alignment: Alignment.topCenter,
            ),
          ],
        ),
      ),
    );

    // SKNavView(
    //   isBack: false,
    //   title: 'Chat',
    //   rightBtnImage: ImageNames.chatImages.compose,
    //   callbackRight: tappedCreatePost,
    //   children: <Widget>[

    //   ],
    // );
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
            settings: RouteSettings(name: 'ChatInfoView'),
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
                  DateUtilities.getPastRelativeString(chat.postDate,
                      ago: false),
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
