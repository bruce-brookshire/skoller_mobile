import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/menu/skoller_jobs_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/tools.dart';
import 'package:skoller/screens/main_app/menu/manage_classes_view.dart';
import 'package:skoller/screens/main_app/menu/my_points_view.dart';
import 'package:skoller/screens/main_app/menu/profile_link_sharing_view.dart';
import 'package:skoller/screens/main_app/menu/profile_view.dart';
import 'package:skoller/screens/main_app/menu/reminders_view.dart';

class MenuView extends StatelessWidget {
  final List<Widget> menuOptions = [
    [
      {
        'name': Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': ProfileView(),
        'image': Image.asset(ImageNames.peopleImages.person_blue)
      }
    ],
    [
      {
        'name': Text(
          'Share Skoller',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': ProfileLinkSharingView(),
        'image': Image.asset(ImageNames.peopleImages.people_blue)
      },
      {
        'name': Text(
          'My points',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': MyPointsView(),
        'image': Image.asset(ImageNames.menuImages.points)
      },
    ],
    [
      {
        'name': Text(
          'Reminders',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': RemindersView(),
        'image': Image.asset(ImageNames.menuImages.reminders)
      },
      {
        'name': Text(
          'Manage classes',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': ManageClassesView()
      },
    ],
    [
      {
        'name': Text.rich(
          TextSpan(
            text: 'Skoller',
            children: [
              TextSpan(
                text: 'Jobs',
                style: TextStyle(
                    fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
              ),
            ],
            style: TextStyle(fontSize: 16),
          ),
        ),
        'view': SkollerJobsView(),
        'image': Image.asset(ImageNames.menuImages.briefcase)
      },
    ],
    [
      {
        'name': Text(
          'Send us feedback',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'action': () async {
          final url = 'mailto:support@skoller.co?subject=Feedback';

          if (await canLaunch(url)) {
            launch(url);
          }
        },
      },
      {
        'name': Text(
          'Tutorial',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        'view': ProfileView()
      },
    ]
  ]
      .map((group) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: SKColors.border_gray)),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: group
                  .map(
                    (row) => Container(
                      height: 44,
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: SKColors.border_gray))),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTapUp: (details) {
                          if (row.containsKey('view'))
                            DartNotificationCenter.post(
                              channel:
                                  NotificationChannels.presentViewOverTabBar,
                              options: row['view'],
                            );
                          else if (row.containsKey('action'))
                            (row['action'] as VoidCallback)();
                        },
                        child: Row(
                          children: [
                            ...row.containsKey('image')
                                ? [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: 8, bottom: 1),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: row['image']),
                                    ),
                                  ]
                                : [],
                            Expanded(child: row['name']),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        decoration: BoxDecoration(
          color: SKColors.background_gray,
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
                          padding:
                              EdgeInsets.symmetric(vertical: 24, horizontal: 8),
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
                  Text(
                    'v${UIAssets.versionNumber ?? '-'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontWeight: FontWeight.normal,
                        fontSize: 13),
                  ),
                  Text(
                    '© 2019 Skoller, Inc.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontWeight: FontWeight.normal,
                        fontSize: 13),
                  ),
                  SafeArea(
                    top: false,
                    child: GestureDetector(
                      onTapUp: (details) {
                        Auth.logOut();
                        DartNotificationCenter.post(
                            channel: NotificationChannels.appStateChanged,
                            options: AppState.auth);
                      },
                      child: Container(
                        color: SKColors.skoller_blue,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: Text(
                          'Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
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
