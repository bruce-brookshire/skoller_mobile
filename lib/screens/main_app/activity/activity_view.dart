import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/tutorial/activity_tutorial_view.dart';
import '../../../requests/requests_core.dart';
import 'package:skoller/constants/constants.dart';

class ActivityView extends StatefulWidget {
  @override
  State createState() => _ActivityState();
}

class _ActivityState extends State<ActivityView> {
  List<List<Mod>> stackedMods = [];

  @override
  void initState() {
    super.initState();

    stackedMods = stackAndSortMods(Mod.currentMods.values.toList());

    Mod.fetchMods().then((response) {
      if (response.wasSuccessful()) {
        final mods = stackAndSortMods(response.obj ?? []);
        setState(() {
          stackedMods = mods;
        });
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to get mods',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  List<List<Mod>> stackAndSortMods(List<Mod> mods) {
    Map<String, List<Mod>> modHash = {};

    for (Mod mod in mods) {
      if (mod.modType == ModType.newAssignment) {
        modHash['${mod.id} new'] = [mod];
      } else {
        String key =
            '${mod.parentAssignment?.id ?? mod.id} ${mod.modType.index}';

        if (modHash[key] == null) {
          modHash[key] = [mod];
        } else {
          modHash[key].add(mod);
        }
      }
    }

    final unsortedStack = modHash.values.toList();
    unsortedStack.forEach((typeList) {
      typeList.sort((elem1, elem2) {
        return elem2.createdOn.compareTo(elem1.createdOn);
      });
    });

    unsortedStack.sort((elem1, elem2) {
      return elem2[0].createdOn.compareTo(elem1[0].createdOn);
    });

    return unsortedStack;
  }

  String getDescrImageName(Mod mod) {
    switch (mod.modType) {
      case ModType.name:
        return '';
        break;
      case ModType.weight:
        return ImageNames.activityImages.weight_white;
        break;
      case ModType.due:
        return ImageNames.activityImages.due_white;
        break;
      case ModType.newAssignment:
        return ImageNames.activityImages.add_white;
        break;
      case ModType.delete:
        return ImageNames.activityImages.delete_white;
        break;
    }

    throw 'image not found';
  }

  @override
  Widget build(BuildContext context) {
    if (!StudentClass.liveClassesAvailable)
      return ActivityTutorialView(
        () => DartNotificationCenter.post(
            channel: NotificationChannels.selectTab, options: 3),
        'Setup first class',
      );

    final body = SKNavView(
      title: 'Activity',
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      children: <Widget>[
        stackedMods.length == 0
            ? Padding(
                padding: EdgeInsets.only(top: 8),
                child: SammiSpeechBubble(
                  sammiPersonality: SammiPersonality.wow,
                  speechBubbleContents: Text.rich(
                    TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: 'No activity yet!\n',
                          style: TextStyle(fontSize: 17),
                        ),
                        TextSpan(
                          text: 'When classmates ',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: 'change the schedule',
                        ),
                        // TextSpan(
                        //   text: ' or ',
                        //   style: TextStyle(fontWeight: FontWeight.normal),
                        // ),
                        // TextSpan(
                        //   text: 'chat with each other',
                        // ),
                        TextSpan(
                          text: ', it will show up here!',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 4),
                  itemCount: stackedMods.length,
                  itemBuilder: buildListItem,
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
                    border: Border.all(color: Colors.white)
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

  Widget buildListItem(BuildContext context, int index) {
    Mod mod = stackedMods[index][0];

    return GestureDetector(
      onTapUp: (details) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => UpdateInfoView(stackedMods[index]),
            settings: RouteSettings(name: 'UpdateInfoView'),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mod.isAccepted == null
                      ? mod.parentClass.getColor()
                      : SKColors.light_gray),
              child: Image.asset(this.getDescrImageName(mod)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        mod.parentClass.name,
                        style: TextStyle(
                            color: mod.isAccepted == null
                                ? mod.parentClass.getColor()
                                : SKColors.light_gray),
                      ),
                      Text(
                        DateUtilities.getPastRelativeString(mod.createdOn),
                        style: TextStyle(
                            color: SKColors.text_light_gray,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Text(
                    mod.isAccepted == null
                        ? mod.shortMsg
                        : '${mod.isAccepted ? 'Copied:' : 'Dismissed:'} ${mod.shortMsg}',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: mod.isAccepted == null
                            ? SKColors.dark_gray
                            : SKColors.light_gray),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
