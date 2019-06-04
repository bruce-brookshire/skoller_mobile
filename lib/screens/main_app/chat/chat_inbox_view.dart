import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class ChatInboxView extends StatefulWidget {
  @override
  State createState() => _ChatInboxViewState();
}

class _ChatInboxViewState extends State<ChatInboxView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> inboxElements = InboxNotification.currentInbox
        .map((inbox) => Container(
              child: Text(inbox.chatPost.post),
            ))
        .toList();
    return SKNavView(
      title: 'Inbox',
      isDown: true,
      isBack: false,
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
