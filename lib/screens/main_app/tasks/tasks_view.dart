import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import 'package:skoller/tools.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';

enum Forecast { tenDay, thirtyDay, all }

class TasksView extends StatefulWidget {
  State createState() => _TasksState();
}

class _TasksState extends State<TasksView> {
  List<_TaskLikeItem> _taskItems = [];
  int _tappedIndex;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Forecast forecast = Forecast.all;

  SlidableController controller = SlidableController();

  @override
  void initState() {
    super.initState();

    loadTasks();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.assignmentChanged,
        onNotification: loadTasks);

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.classChanged,
        onNotification: loadTasks);

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.modsChanged,
        onNotification: loadTasks);
  }

  @override
  void dispose() {
    super.dispose();
    DartNotificationCenter.unsubscribe(observer: this);
  }

  Future fetchTasks() async {
    await StudentClass.getStudentClasses();
    loadTasks();
  }

  Future loadTasks([dynamic options]) async {
    Future<RequestResponse> modsRequest = Mod.fetchNewAssignmentMods();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<_TaskLikeItem> tasks = (Assignment.currentAssignments.values.toList()
          ..removeWhere((a) =>
              (a.due?.isBefore(today) ?? true) ||
              a.parentClass == null ||
              a.weight_id == null ||
              a.completed)
          ..sort(
            (a1, a2) {
              return -1;
            },
          ))
        .map(
          (a) => _TaskLikeItem(
            a.id,
            false,
            a.due,
          ),
        )
        .toList();

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
          task.getParent?.isAccepted != null);

      tasks.addAll(temp);
    }

    tasks
      ..removeWhere((task) {
        if (task.getParent == null) return true;
        
        int outlook;
        if (forecast == Forecast.all)
          outlook = 365;
        else if (forecast == Forecast.thirtyDay)
          outlook = 30;
        else
          outlook = 10;

        return task.dueDate.difference(today).inDays > outlook;
      })
      ..sort((task1, task2) {
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

  void tappedChangeForecast(TapUpDetails details) async {
    int selectedIndex;
    final results = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Forecast',
        subtitle: 'How far out do you want to look?',
        items: ['10-day', '30-day', 'Semester outlook'],
        onSelect: (selection) => selectedIndex = selection,
      ),
    );

    if (results is bool && results && selectedIndex != null) {
      if (selectedIndex == 0)
        forecast = Forecast.tenDay;
      else if (selectedIndex == 1)
        forecast = Forecast.thirtyDay;
      else
        forecast = Forecast.all;

      loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    String forecastStr;
    switch (forecast) {
      case Forecast.tenDay:
        forecastStr = '10';
        break;
      case Forecast.thirtyDay:
        forecastStr = '30';
        break;
      case Forecast.all:
        forecastStr = '';
        break;
    }

    return SKNavView(
      title: 'Tasks',
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () {
        DartNotificationCenter.post(channel: NotificationChannels.toggleMenu);
      },
      rightBtn: Image.asset(ImageNames.rightNavImages.plus),
      callbackRight: () {
        tappedAdd(context);
      },
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchTasks,
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(top: 4, bottom: 64),
                  itemCount: _taskItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final day = DateFormat('EEEE').format(DateTime.now());
                      final assignments = _taskItems.length;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                        child: SammiSpeechBubble(
                          sammiPersonality: SammiPersonality.smile,
                          speechBubbleContents: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Happy $day, ${SKUser.current.student.nameFirst}!',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: Image.asset(
                                        ImageNames.tasksImages.forecast),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Your personal forecast is showing ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 13),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${assignments} assignment${assignments == 1 ? '' : 's'}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      forecast == Forecast.all
                                          ? TextSpan(
                                              text: ' left to do.',
                                            )
                                          : TextSpan(
                                              text:
                                                  ' due in the next $forecastStr days.',
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else
                      return _taskItems[index - 1].isMod
                          ? buildModCell(context, index - 1)
                          : buildTaskCell(context, index - 1);
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTapUp: tappedChangeForecast,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 7),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                              border: Border.all(color: SKColors.skoller_blue),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [UIAssets.boxShadow],
                              color: Colors.white),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                child: Image.asset(
                                    ImageNames.tasksImages.forecast),
                                padding: EdgeInsets.only(right: 4),
                              ),
                              Text(
                                forecast == Forecast.all
                                    ? 'Semester outlook'
                                    : '$forecastStr-day forecast',
                                style: TextStyle(color: SKColors.skoller_blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
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
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      task?.name ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: task.parentClass.getColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
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
                  task.parentClass?.name ?? '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                if (task.weight_id != null && task.weight != null)
                  SKAssignmentImpactGraph(task, size: ImpactGraphSize.small)
              ],
            )
          ],
        ),
      ),
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
                      mod.data.name,
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
                      color: SKColors.warning_red,
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
                    mod.parentClass?.name ?? '',
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
