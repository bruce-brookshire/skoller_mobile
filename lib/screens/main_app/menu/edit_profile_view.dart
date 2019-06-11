import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/constants/constants.dart';

class EditProfileView extends StatefulWidget {
  @override
  State createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final firstNameController =
      TextEditingController(text: SKUser.current.student.nameFirst);
  final lastNameController =
      TextEditingController(text: SKUser.current.student.nameLast);
  final bioController = TextEditingController(text: SKUser.current.student.bio);
  final organizationsController =
      TextEditingController(text: SKUser.current.student.organizations);

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Edit Profile',
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
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          style: TextStyle(fontSize: 15),
                          decoration: BoxDecoration(border: null),
                          controller: firstNameController,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            onTapUp: (details) => print('delete me'),
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
