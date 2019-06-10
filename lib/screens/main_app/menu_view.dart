import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/menu/profile_link_sharing_view.dart';
import 'package:skoller/screens/main_app/menu/profile_view.dart';

class MenuView extends StatelessWidget {
  final List<Widget> menuOptions = [
    {'name': 'Profile', 'view': ProfileView()},
    {'name': 'Share Skoller', 'view': ProfileLinkSharingView()},
    {'name': 'My Points', 'view': ProfileView()},
    {'name': 'Reminders', 'view': ProfileView()},
    {'name': 'Drop/add classes', 'view': ProfileView()},
    {'name': 'SkollerJobs', 'view': ProfileView()},
    {'name': 'Send us feedback', 'view': ProfileView()},
    {'name': 'Tutorial', 'view': ProfileView()},
  ]
      .map(
        (row) => GestureDetector(
              onTapUp: (details) {
                DartNotificationCenter.post(
                  channel: NotificationChannels.presentViewOverTabBar,
                  options: row['view'],
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(row['name']),
              ),
            ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        decoration: BoxDecoration(
          color: SKColors.menu_blue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [UIAssets.boxShadow],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      '${SKUser.current.student.nameFirst} ${SKUser.current.student.nameLast}',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...menuOptions,
                  Spacer(),
                  GestureDetector(
                    onTapUp: (details) => DartNotificationCenter.post(
                        channel: NotificationChannels.toggleMenu),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      child: Text(
                        'Dismiss',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SKColors.skoller_blue),
                      ),
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
