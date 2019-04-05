import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import '../classes/assignment_info_view.dart';

class TasksView extends StatefulWidget {
  State createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<Assignment> _tasks = [];
  int _tappedIndex;

  @override
  void initState() {
    super.initState();

    _fetchTasks();
  }

  void _fetchTasks() {
    Assignment.getTasks().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          _tasks = response.obj;
        });
      } //Else: error out
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: SKColors.background_gray,
          child: Center(
            child: Column(
              children: <Widget>[
                SKNavBar(
                  'Tasks',
                  rightBtnImage: ImageNames.rightNavImages.plus,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 4),
                    itemBuilder: buildCell,
                    itemCount: _tasks.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCell(BuildContext context, int index) {
    final task = _tasks[index];
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _tappedIndex = index;
        });
      },
      onTapCancel: () {
        setState(() {
          _tappedIndex = null;
        });
      },
      onTapUp: (details) {
        setState(() {
          _tappedIndex = null;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignmentInfoView(task: task)),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray, width: 1),
          boxShadow: [UIAssets.boxShadow],
          color: _tappedIndex == index
              ? SKColors.selected_gray
              : Theme.of(context).cardColor,
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    task.parentClass.name,
                    style: TextStyle(
                        color: task.parentClass.getColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  Text(
                    DateUtilities.getFutureRelativeString(task.due),
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  task.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                Text(
                  task.weight_id == null
                      ? 'Not graded'
                      : NumberUtilities.formatWeightAsPercentage(task.weight),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
