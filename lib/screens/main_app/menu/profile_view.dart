import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/menu/edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  @override
  State createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTapUp: (details) => Navigator.pop(context),
                    child: Container(
                      height: 32,
                      width: 32,
                      child: Image.asset(ImageNames.navArrowImages.down),
                    ),
                  ),
                  GestureDetector(
                    onTapUp: (details) => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => EditProfileView(),
                          ),
                        ),
                    child: Container(
                      height: 32,
                      width: 32,
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '${SKUser.current.student.nameFirst} ${SKUser.current.student.nameLast}',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 9, left: 12, right: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [UIAssets.boxShadow],
                                border: Border.all(color: SKColors.dark_gray),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                SKUser.current.student.bio ?? 'no bio here...',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Bio',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 9, left: 12, right: 12, bottom: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [UIAssets.boxShadow],
                                border: Border.all(color: SKColors.dark_gray),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                SKUser.current.student.organizations ??
                                    'no orgs here...',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Organizations',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: SKColors.light_gray,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Private info',
                      style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: SKColors.light_gray,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 9, left: 8, right: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [UIAssets.boxShadow],
                                      border:
                                          Border.all(color: SKColors.dark_gray),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      SKUser.current.email ?? 'N/A...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(left: 20),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                'Email',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 9, left: 8, right: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [UIAssets.boxShadow],
                                      border:
                                          Border.all(color: SKColors.dark_gray),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      SKUser.current.student.formattedPhone ??
                                          'N/A...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(left: 20),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                'Phone',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
