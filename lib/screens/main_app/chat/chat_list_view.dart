import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/chat/chat_inbox_view.dart';
import 'package:skoller/screens/main_app/chat/chat_info_view.dart';
import 'package:skoller/screens/main_app/classes/modals/class_link_sharing_modal.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/tutorial/chat_tutorial_view.dart';
import 'package:skoller/tools.dart';

class ChatListView extends StatefulWidget {
  @override
  State createState() => _ChatListState();
}

class _ChatListState extends State<ChatListView> {
  List<Chat> chats;
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

    classes
      ..sort((class1, class2) {
        return class1.name.compareTo(class2.name);
      })
      ..removeWhere((c) => ![
            ClassStatuses.class_issue,
            ClassStatuses.class_setup
          ].contains(c.status.id));

    int selectedIndex = 0;

    final result1 = await showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Create a post',
        subtitle: 'Select a class',
        items: classes.map((c) => c.name).toList(),
        onSelect: (index) => selectedIndex = index,
      ),
    );

    if (result1 == null || !result1) {
      return;
    }

    final studentClass = classes[selectedIndex];

    if (studentClass.enrollment < PARTY_SIZE) {
      showDialog(
        context: context,
        builder: (context) => ClassLinkSharingModal(
          studentClass.id,
          showClassName: true,
        ),
      );
    } else {
      final result = await showDialog(
          context: context, builder: (context) => _CreatePostModal());

      if (result is String && result != '') {
        final loadingScreen = SKLoadingScreen.fadeIn(context);

        classes[selectedIndex]
            .createStudentChat(result)
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
  }

  @override
  Widget build(BuildContext context) {
    if (!StudentClass.liveClassesAvailable)
      return ChatTutorialView(
        () => DartNotificationCenter.post(
            channel: NotificationChannels.selectTab, options: CLASSES_TAB),
        'Setup first class',
      );

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: SafeArea(
    //     bottom: false,
    //     child: Stack(
    //       children: <Widget>[
    //         Align(
    //           alignment: Alignment.center,
    //           child: Container(
    //             margin: EdgeInsets.only(top: 44),
    //             color: SKColors.background_gray,
    //             child: Center(
    //               child: Column(
    //                 children: [
    //                   Expanded(
    //                     child: ListView.builder(
    //                       padding: EdgeInsets.only(top: 4),
    //                       itemCount: chats.length,
    //                       itemBuilder: buildCard,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //         Align(
    //           child: Container(
    //             height: 44,
    //             decoration: BoxDecoration(boxShadow: [
    //               BoxShadow(
    //                 color: Color(0x1C000000),
    //                 offset: Offset(0, 3.5),
    //                 blurRadius: 2,
    //               )
    //             ], color: Colors.white),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: <Widget>[
    //                 Container(
    //                   margin: EdgeInsets.only(right: 52, left: 8),
    //                   child: GestureDetector(
    //                     onTapUp: (details) => DartNotificationCenter.post(
    //                         channel: NotificationChannels.toggleMenu),
    //                     child: SKHeaderProfilePhoto(),
    //                   ),
    //                 ),
    //                 Expanded(
    //                   child: Container(
    //                     child: Text(
    //                       'Chat',
    //                       textAlign: TextAlign.center,
    //                       style: TextStyle(
    //                           fontSize: 18, fontWeight: FontWeight.bold),
    //                     ),
    //                   ),
    //                 ),
    //                 Row(
    //                   children: <Widget>[
    //                     GestureDetector(
    //                       behavior: HitTestBehavior.opaque,
    //                       onTapUp: tappedCheckInbox,
    //                       child: Container(
    //                         width: 44,
    //                         height: 44,
    //                         child: Center(
    //                           child: Image(
    //                             image: AssetImage(
    //                               this.unreadInbox
    //                                   ? ImageNames.chatImages.inbox_unread
    //                                   : ImageNames.chatImages.inbox,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                     GestureDetector(
    //                       behavior: HitTestBehavior.opaque,
    //                       onTapUp: (details) {
    //                         tappedCreatePost();
    //                       },
    //                       child: Container(
    //                         padding: EdgeInsets.only(right: 4),
    //                         child: Center(
    //                           child: Image(
    //                             image:
    //                                 AssetImage(ImageNames.chatImages.compose),
    //                           ),
    //                         ),
    //                         width: 44,
    //                         height: 44,
    //                       ),
    //                     ),
    //                   ],
    //                 )
    //               ],
    //             ),
    //           ),
    //           alignment: Alignment.topCenter,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
//
    final body = SKNavView(
      title: 'Chat',
      rightBtn: Image.asset(ImageNames.chatImages.compose),
      callbackRight: tappedCreatePost,
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      children: chats == null
          ? []
          : chats.length == 0
              ? [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: SammiSpeechBubble(
                      sammiPersonality: SammiPersonality.ooo,
                      speechBubbleContents: Text.rich(
                        TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: 'No chats yet!\n',
                              style: TextStyle(fontSize: 17),
                            ),
                            TextSpan(
                              text: 'Strike one up with your classmates by ',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: 'tapping the plus sign ',
                            ),
                            TextSpan(
                              text: 'below!',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => tappedCreatePost(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 44, 16, 16),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: CustomPaint(
                          painter: _PlusPainter(),
                          child: Container(
                            width: 14,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 4),
                      itemCount: chats.length,
                      itemBuilder: buildCard,
                    ),
                  )
                ],
    );

    if (StudentClass.currentClasses.length > 1)
      return body;
    else
      return Stack(
        children: <Widget>[
          body,
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(),
              child: GestureDetector(
                onTapUp: (details) => DartNotificationCenter.post(
                  channel: NotificationChannels.presentViewOverTabBar,
                  options: AddClassesView(),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    boxShadow: [UIAssets.boxShadow],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Text(
                    'Join your 2nd class 👌',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SKColors.skoller_blue
      ..style = PaintingStyle.fill
      // ..strokeWidth = 1
      ..isAntiAlias = true;

    const double radius = 2.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    var path = Path();

    path.moveTo(centerX + radius, centerY - radius);

    //Right
    path.lineTo(size.width - radius, centerY - radius);
    path.arcToPoint(Offset(size.width - radius, centerY + radius),
        radius: Radius.circular(radius));
    path.lineTo(centerX + radius, centerY + radius);

    //Bottom
    path.lineTo(centerX + radius, size.height - radius);
    path.arcToPoint(Offset(centerX - radius, size.height - radius),
        radius: Radius.circular(radius));
    path.lineTo(centerX - radius, centerY + radius);

    //Left
    path.lineTo(radius, centerY + radius);
    path.arcToPoint(Offset(radius, centerY - radius),
        radius: Radius.circular(radius));
    path.lineTo(centerX - radius, centerY - radius);

    //Top
    path.lineTo(centerX - radius, radius);
    path.arcToPoint(Offset(centerX + radius, radius),
        radius: Radius.circular(radius));
    path.lineTo(centerX + radius, centerY - radius);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CreatePostModal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<_CreatePostModal> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
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
                          focusNode.unfocus();
                          Navigator.pop(context);
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
                          focusNode.unfocus();

                          Navigator.pop(context, controller.text.trim());
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
                    focusNode: focusNode,
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
      );
}
