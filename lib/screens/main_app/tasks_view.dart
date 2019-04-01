import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../requests/requests_core.dart';

class TasksView extends StatefulWidget {

  fetchTasks() {
    
  }
  State createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {



  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  height: 44,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Color(0x1C000000),
                      offset: Offset(0, 3.5),
                      blurRadius: 3.5,
                    )
                  ], color: Theme.of(context).backgroundColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Center(
                          child: Text('b'),
                        ),
                        width: 44,
                        height: 44,
                      ),
                      Text('Tasks'),
                      Container(
                        child: Center(
                          child: Text('b'),
                        ),
                        width: 44,
                        height: 44,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text('hi'),
                  margin: EdgeInsets.only(top: 16),
                )
              ],
            ),
          ),
        ),
      );
}
