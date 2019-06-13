import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/menu/manage_classes_view.dart';
import 'package:skoller/screens/main_app/menu/my_points_view.dart';
import 'package:skoller/screens/main_app/menu/profile_link_sharing_view.dart';
import 'package:skoller/screens/main_app/menu/profile_view.dart';
import 'package:skoller/screens/main_app/menu/reminders_view.dart';

class MenuView extends StatelessWidget {
  final List<Widget> menuOptions = [
    {'name': 'Profile', 'view': ProfileView()},
    {'name': 'Share Skoller', 'view': ProfileLinkSharingView()},
    {'name': 'My Points', 'view': MyPointsView()},
    {'name': 'Reminders', 'view': RemindersView()},
    {'name': 'Drop/add classes', 'view': ManageClassesView()},
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
          color: SKColors.background_gray,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SKColors.light_gray,
                          shape: BoxShape.circle,
                          image: SKUser.current.avatarUrl == null
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(SKUser.current.avatarUrl),
                                ),
                        ),
                        margin: EdgeInsets.only(left: 12),
                        height: 44,
                        width: 44,
                        child: SKUser.current.avatarUrl == null
                            ? Text(
                                SKUser.current.student.nameFirst[0] +
                                    SKUser.current.student.nameLast[0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  letterSpacing: -0.25,
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                          child: Text(
                            '${SKUser.current.student.nameFirst} ${SKUser.current.student.nameLast}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
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
