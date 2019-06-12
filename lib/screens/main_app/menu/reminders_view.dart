import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class RemindersView extends StatefulWidget {
  @override
  State createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Notifications',
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      children: <Widget>[
        Expanded(
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [UIAssets.boxShadow],
                ),
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                        decoration: BoxDecoration(
                          color: SKColors.selected_gray,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Upcoming assignments',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              'Set the schedule for when you would like to be reminded about assignment due dates',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 13),
                            ),
                          ],
                        )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'On due date:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 8, 4, 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'What time?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                                Text(
                                  '9:00 AM',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: SKColors.skoller_blue),
                                )
                              ],
                            ),
                          ),
                          Text(
                            'Before due date:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 8, 4, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Start reminders',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                                Text(
                                  '3 days out',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: SKColors.skoller_blue),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'What time?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                                Text(
                                  '9:00 AM',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: SKColors.skoller_blue),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [UIAssets.boxShadow],
                ),
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Assignment comments',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            'Get notified when a classmate asks or answers a question on an assignment.',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Comment notifications',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                          CupertinoSwitch(
                            value: true,
                            activeColor: SKColors.skoller_blue,
                            onChanged: (newVal) {
                              //TODO save new state
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [UIAssets.boxShadow],
                ),
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Custom by class',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            'Skoller lets you turn assignment reminders on or off by class.',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ...StudentClass.currentClasses.values
                        .map(
                          (studentClass) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      studentClass.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ),
                                    CupertinoSwitch(
                                      value: true,
                                      activeColor: SKColors.skoller_blue,
                                      onChanged: (newVal) {
                                        //TODO save new state
                                      },
                                    )
                                  ],
                                ),
                              ),
                        )
                        .toList()
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
