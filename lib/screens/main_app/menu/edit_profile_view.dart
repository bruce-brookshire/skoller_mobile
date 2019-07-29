import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class EditProfileView extends StatefulWidget {
  @override
  State createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileView> {
  final firstNameController =
      TextEditingController(text: SKUser.current.student.nameFirst);
  final lastNameController =
      TextEditingController(text: SKUser.current.student.nameLast);
  final bioController = TextEditingController(text: SKUser.current.student.bio);
  final organizationsController =
      TextEditingController(text: SKUser.current.student.organizations);



  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    organizationsController.dispose();
  }

  void tappedSave() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final bio = bioController.text.trim();
    final organizations = organizationsController.text.trim();

    if (firstName.length > 0 && lastName.length > 0) {
      SKUser.current
          .update(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        organizations: organizations,
      )
          .then((success) {
        if (success) {
          Navigator.pop(context);
        }
      });
    } else {
      DropdownBanner.showBanner(
        text: 'You must have a first and last name',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Edit Profile',
      rightBtn: Text(
        'Save',
        style: TextStyle(
            color: SKColors.skoller_blue, fontWeight: FontWeight.normal),
      ),
      callbackRight: tappedSave,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(children: [
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
              margin: EdgeInsets.only(bottom: 12),
              height: 64,
              width: 64,
              child: SKUser.current.avatarUrl == null
                  ? Text(
                      SKUser.current.student.nameFirst[0] +
                          SKUser.current.student.nameLast[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 1,
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 4, 0, 8),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'First name',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          padding: EdgeInsets.all(0),
                          placeholder: 'Alex',
                          style: TextStyle(fontSize: 15),
                          decoration: BoxDecoration(border: null),
                          controller: firstNameController,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 4, 0, 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Last name',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          padding: EdgeInsets.all(0),
                          placeholder: 'Smith',
                          style: TextStyle(fontSize: 15),
                          decoration: BoxDecoration(border: null),
                          controller: lastNameController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Bio',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                minLines: 4,
                maxLines: 4,
                placeholder: 'Tell your classmates a bit about yourself!',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                controller: bioController,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Organizations',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                minLines: 4,
                maxLines: 4,
                placeholder: 'What organizations are you involved with?',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                controller: organizationsController,
              ),
            ],
          ),
        ),
        Spacer(),
        SafeArea(
          top: false,
          child: GestureDetector(
            onTapUp: (details) {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: Text(
                    'Delete Account',
                    style: TextStyle(
                        color: SKColors.dark_gray,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  message: Text(
                    'DANGER ZONE: This action is irreversible. IF YOU DELETE YOUR ACCOUNT, YOUR DATA IS GONE FOREVER. WE CAN\'T HELP. Are you sure you want to proceed?',
                    style: TextStyle(color: SKColors.dark_gray),
                  ),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      isDestructiveAction: true,
                      child: Text(
                        'I\m sure. Delete me.',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        Navigator.popUntil(
                            context, (route) => route.settings.isInitialRoute);

                        bool success = await SKUser.current.delete();
                        if (success) success = await Auth.logOut();

                        if (success)
                          DartNotificationCenter.post(
                              channel: NotificationChannels.appStateChanged,
                              options: AppState.auth);
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: Text(
                        'Take me to safety!',
                        style: TextStyle(fontSize: 16, color: SKColors.success),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
            child: Text(
              'Delete account',
              style: TextStyle(
                color: SKColors.warning_red,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        )
      ],
    );
  }
}
