import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class ChatInboxView extends StatefulWidget {
  @override
  State createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInboxView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> inboxElements = InboxNotification.currentInbox
        .map((inbox) => Container(
              child: Text(inbox.chatPost.post),
            ))
        .toList();
    return SKNavView(
      title: 'Inbox',
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Expanded(
          child: ListView(
            children: inboxElements,
          ),
        )
      ],
    );
  }
}
