import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';

class AssignmentInfo extends StatefulWidget {
  final Assignment task;

  AssignmentInfo({Key key, this.task}) : super(key: key);

  @override
  State createState() => _AssignmentInfoState();
}

class _AssignmentInfoState extends State<AssignmentInfo> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                SKNavBar(
                  widget.task.parentClass.name,
                  backBtnEnabled: true,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [UIAssets.boxShadow],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: SKColors.selected_gray,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Assignment Details',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      Text('This is the body')
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [UIAssets.boxShadow],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: SKColors.selected_gray,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Personal Details',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      Text('This is the body')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
