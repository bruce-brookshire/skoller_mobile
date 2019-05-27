import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../constants/constants.dart';
import '../../../requests/requests_core.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';

class TasksView extends StatefulWidget {
  State createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<_TaskLikeItem> _tasks = [];
  int _tappedIndex;

  SlidableController controller = SlidableController();

  @override
  void initState() {
    super.initState();

    if (Assignment.currentTasks != null) {
      _tasks = Assignment.currentTasks
          .map((task) => _TaskLikeItem(
                task.id,
                false,
              ))
          .toList();
    }
    _fetchTasks();
  }

  void _fetchTasks() async {
    Future<RequestResponse> assignmentsRequest = Assignment.getTasks();
    Future<RequestResponse> modsRequest = Mod.fetchNewAssignmentMods();

    RequestResponse assignmentResponse = await assignmentsRequest;
    List<_TaskLikeItem> tasks;

    if (assignmentResponse.wasSuccessful()) {
      tasks = (assignmentResponse.obj as List<Assignment>)
          .map(
            (task) => _TaskLikeItem(
                  task.id,
                  false,
                ),
          )
          .toList();
    }

    RequestResponse modResponse = await modsRequest;

    if (modResponse.wasSuccessful()) {
      tasks.addAll(
        (modResponse.obj as List<Mod>).map(
          (mod) => _TaskLikeItem(
                mod.id,
                true,
              ),
        ),
      );
    }

    setState(() {
      _tasks = tasks;
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
      isBack: false,
      rightBtnImage: ImageNames.rightNavImages.plus,
      callbackRight: () {
        tappedAdd(context);
      },
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemBuilder: (context, index) {
              _tasks[index].isMod
                  ? buildTaskCell(context, index)
                  : buildModCell(context, index);
            },
            itemCount: _tasks.length,
          ),
        ),
      ],
    );
  }

  Widget buildTaskCell(BuildContext context, int index) {
    final Assignment task = _tasks[index].getParent;

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
      child: Slidable(
        key: Key('${task.id}'),
        dismissal: SlidableDismissal(
          child: SlidableDrawerDismissal(),
          onDismissed: (actionType) {
            setState(() {
              _tasks.removeAt(index);
            });
          },
        ),
        actionPane: SlidableDrawerActionPane(
            key: Key('${task.id}')), //SlidableScrollActionPane(),
        actionExtentRatio: 0.25,
        closeOnScroll: true,
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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    task.name,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    task.weight_id == null
                        ? 'Not graded'
                        : NumberUtilities.formatWeightAsPercent(task.weight),
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ],
              )
            ],
          ),
        ),
        secondaryActions: <Widget>[
          SlideAction(
            onTap: () {
              task.toggleComplete();
            },
            child: Container(
              color: SKColors.skoller_blue,
              child: Center(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('Done',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                  Image.asset(ImageNames.activityImages.add_white),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildModCell(BuildContext context, int index) {
    return Container(
      child: Text('this is a mod'),
    );
  }
}

class _TaskLikeItem {
  bool isMod;
  int parentObjectId;

  dynamic get getParent => isMod
      ? Mod.currentMods[parentObjectId]
      : Assignment.currentAssignments[parentObjectId];

  _TaskLikeItem(this.parentObjectId, this.isMod);
}
