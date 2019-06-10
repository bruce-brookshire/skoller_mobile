import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';

class TasksView extends StatefulWidget {
  State createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<_TaskLikeItem> _taskItems;
  int _tappedIndex;

  SlidableController controller = SlidableController();

  @override
  void initState() {
    super.initState();

    if (Assignment.currentTasks != null) {
      _taskItems = Assignment.currentTasks
          .map((task) => _TaskLikeItem(
                task.id,
                false,
                task.due,
              ))
          .toList();
    }
    _fetchTasks();
  }

  void _fetchTasks() async {
    _taskItems = [];

    Future<RequestResponse> assignmentsRequest = Assignment.getTasks();
    Future<RequestResponse> modsRequest = Mod.fetchNewAssignmentMods();

    RequestResponse assignmentResponse = await assignmentsRequest;

    List<_TaskLikeItem> tasks = [];

    if (assignmentResponse.wasSuccessful()) {
      tasks.addAll((assignmentResponse.obj as List<Assignment>)
          .map(
            (task) => _TaskLikeItem(
                  task.id,
                  false,
                  task.due,
                ),
          )
          .toList());
    }

    RequestResponse modResponse = await modsRequest;

    if (modResponse.wasSuccessful()) {
      List<_TaskLikeItem> temp = (modResponse.obj as List<Mod>)
          .map(
            (mod) => _TaskLikeItem(
                  mod.id,
                  true,
                  mod.data.due,
                ),
          )
          .toList();

      final now = DateTime.now();
      final referenceDate = DateTime(now.year, now.month, now.day);

      temp.removeWhere((task) =>
          task.dueDate.isBefore(referenceDate) ||
          task.getParent.isAccepted != null);

      tasks.addAll(temp);
    }

    tasks.sort((task1, task2) {
      if (task1.dueDate == null && task2.dueDate == null) {
        return task1.parentObjectId.compareTo(task2.parentObjectId);
      } else if (task1.dueDate != null && task2.dueDate == null) {
        return -1;
      } else if (task1.dueDate == null && task2.dueDate != null) {
        return 1;
      } else {
        return task1.dueDate.compareTo(task2.dueDate);
      }
    });

    setState(() {
      _taskItems = tasks;
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
          builder: (context) => AssignmentWeightView(class_id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Tasks',
      callbackBack: () {
        DartNotificationCenter.post(channel: NotificationChannels.toggleMenu);
      },
      rightBtnImage: ImageNames.rightNavImages.plus,
      callbackRight: () {
        tappedAdd(context);
      },
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemBuilder: (context, index) => _taskItems[index].isMod
                ? buildModCell(context, index)
                : buildTaskCell(context, index),
            itemCount: _taskItems.length,
          ),
        ),
      ],
    );
  }

  Widget buildTaskCell(BuildContext context, int index) {
    final Assignment task = _taskItems[index].getParent;

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
              builder: (context) => AssignmentInfoView(assignment_id: task.id)),
        );
      },
      // child: Slidable(
      //   key: Key('${task.id}'),
      //   dismissal: SlidableDismissal(
      //     child: SlidableDrawerDismissal(),
      //     onDismissed: (actionType) {
      //       setState(() {
      //         _taskItems.removeAt(index);
      //       });
      //     },
      //   ),
      //   actionPane: SlidableDrawerActionPane(
      //       key: Key('${task.id}')), //SlidableScrollActionPane(),
      //   actionExtentRatio: 0.25,
      //   closeOnScroll: true,
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
      //   secondaryActions: <Widget>[
      //     SlideAction(
      //       onTap: () {
      //         task.toggleComplete();
      //       },
      //       child: Container(
      //         color: SKColors.skoller_blue,
      //         child: Center(
      //           child:
      //               Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      //             Container(
      //               padding: EdgeInsets.only(bottom: 4),
      //               child: Text('Done',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                   )),
      //             ),
      //             Image.asset(ImageNames.activityImages.add_white),
      //           ]),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget buildModCell(BuildContext context, int index) {
    final Mod mod = _taskItems[index].getParent;

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
            builder: (context) => UpdateInfoView([mod]),
          ),
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
              : SKColors.menu_blue,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      mod.parentClass.name,
                      style: TextStyle(
                          color: mod.parentClass.getColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                  Text(
                    'New Assignment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: SKColors.skoller_blue,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: mod.parentClass.getColor(),
                      shape: BoxShape.circle),
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(right: 4),
                  child: Image.asset(
                    ImageNames.assignmentInfoImages.updates_available,
                  ),
                ),
                Expanded(
                  child: Text(
                    mod.data.name,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TaskLikeItem {
  bool isMod;
  int parentObjectId;
  DateTime dueDate;

  dynamic get getParent => isMod
      ? Mod.currentMods[parentObjectId]
      : Assignment.currentAssignments[parentObjectId];

  _TaskLikeItem(this.parentObjectId, this.isMod, this.dueDate);
}
