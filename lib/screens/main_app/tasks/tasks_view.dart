import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_add_view.dart';

class TasksView extends StatefulWidget {
  State createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<Assignment> _tasks = [];
  int _tappedIndex;

  @override
  void initState() {
    super.initState();

    if (Assignment.currentTasks != null) _tasks = Assignment.currentTasks;
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

  void tappedAdd(BuildContext context) async {
    final classes = StudentClass.currentClasses.values.toList();

    if (classes.length == 0) {
      return;
    }

    classes.sort((class1, class2) {
      return class1.name.compareTo(class2.name);
    });

    int selectedIndex = 0;

    final result = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: <Widget>[
                Text(
                  'Add an assignment',
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8, top: 2),
                  child: Text(
                    'Select a class',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            content: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: SKColors.border_gray),
                  top: BorderSide(color: SKColors.border_gray),
                ),
              ),
              height: 180,
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                childCount: classes.length,
                itemBuilder: (context, index) => Container(
                      alignment: Alignment.center,
                      child: Text(
                        classes[index].name,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: SKColors.skoller_blue, fontSize: 16),
                ),
                isDefaultAction: false,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'Select',
                  style: TextStyle(
                      color: SKColors.skoller_blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });

    if (result is bool && result) {
      final class_id = classes[selectedIndex].id;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AssignmentAddView(class_id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Tasks',
      isBack: false,
      rightBtnImage: ImageNames.rightNavImages.plus,
      callbackRight: () {
        tappedAdd(context);
      },
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemBuilder: buildCell,
            itemCount: _tasks.length,
          ),
        ),
      ],
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
          CupertinoPageRoute(
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
                      : NumberUtilities.formatWeightAsPercent(task.weight),
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
