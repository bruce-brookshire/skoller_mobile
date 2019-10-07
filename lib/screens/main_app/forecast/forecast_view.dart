import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/tutorial/forecast_tutorial_view.dart';
import 'package:skoller/tools.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';

enum Forecast { tenDay, thirtyDay, all }

class ForecastView extends StatefulWidget {
  State createState() => _ForecastState();
}

class _ForecastState extends State<ForecastView> {
  List<_TaskLikeItem> _taskItems = [];
  Forecast forecast = Forecast.tenDay;
  bool showingCompletedTasks = false;
  bool completedTasksAvailable = false;

  int _tappedIndex;

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

    int minDaysOutCompleted;
    bool newCompletedTasksAvailable = false;
    List<_TaskLikeItem> tasks = (Assignment.currentAssignments.values.toList()
          ..removeWhere((a) =>
              (a.due?.isBefore(today) ?? true) ||
              a.parentClass == null ||
              a.weight_id == null)
          ..removeWhere((a) {
            if (a.completed) {
              newCompletedTasksAvailable = true;

              int daysOut = a.due.difference(today).inDays;
              if (daysOut < (minDaysOutCompleted ?? 1000))
                minDaysOutCompleted = daysOut;
            }
            return !showingCompletedTasks && a.completed;
          }))
        .map((a) => _TaskLikeItem(a.id, false, a.due))
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

    int outlook;
    if (forecast == Forecast.all)
      outlook = 365;
    else if (forecast == Forecast.thirtyDay)
      outlook = 30;
    else
      outlook = 10;

    if (newCompletedTasksAvailable && outlook < minDaysOutCompleted)
      newCompletedTasksAvailable = false;

    tasks
      ..removeWhere((task) {
        if (task.getParent == null) return true;

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

    _taskItems = tasks;
    completedTasksAvailable = newCompletedTasksAvailable;
    if (mounted) setState(() {});
  }

  void tappedAdd() async {
    final classes = StudentClass.currentClasses.values.toList();

    if (classes.length == 0) {
      return;
    }

    classes
      ..sort((class1, class2) {
        return class1.name.compareTo(class2.name);
      })
      ..removeWhere((studentClass) => (studentClass.weights ?? []).length == 0);

    int selectedIndex = 0;

    final result = await showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Select a class',
        subtitle: 'Choose a class to add an assignment to',
        items: classes.map((cl) => cl.name).toList(),
        onSelect: (newIndex) => selectedIndex = newIndex,
      ),
    );

    if (result is bool && result) {
      final class_id = classes[selectedIndex].id;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AssignmentWeightView(class_id),
          settings: RouteSettings(name: 'AssignmentWeightView'),
        ),
      );
    }
  }

  void tappedChangeForecast(TapUpDetails details) async {
    if (StudentClass.currentClasses.length == 1) {
      DartNotificationCenter.post(
        channel: NotificationChannels.presentViewOverTabBar,
        options: AddClassesView(),
      );
      return;
    }

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
    //If we do not have a setup class
    if (!StudentClass.liveClassesAvailable)
      return ForecastTutorialView(
        () => DartNotificationCenter.post(
            channel: NotificationChannels.selectTab, options: CLASSES_TAB),
        'Setup first class',
      );
    final setupSecondClass = StudentClass.currentClasses.length == 2 &&
        StudentClass.currentClasses.values
            .any((c) => c.status.id == ClassStatuses.needs_setup);

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
      title: 'Forecast',
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () {
        DartNotificationCenter.post(channel: NotificationChannels.toggleMenu);
      },
      rightBtn: Image.asset(ImageNames.rightNavImages.plus),
      callbackRight: tappedAdd,
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchTasks,
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(top: 4, bottom: 64),
                  itemCount:
                      _taskItems.length + (completedTasksAvailable ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final day = DateFormat('EEEE').format(DateTime.now());
                      final assignments = _taskItems.length;

                      return Padding(
                        key: Key('top item'),
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
                                        ImageNames.forecastImages.forecast),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: setupSecondClass
                                    ? Text(
                                        'Forecast works best when all of you’re classes are set up.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14),
                                      )
                                    : (assignments == 0
                                        ? Text(
                                            'You’re all caught up! 😃',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14),
                                          )
                                        : Text.rich(
                                            TextSpan(
                                              text:
                                                  'Your personal forecast shows ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${assignments} assignment${assignments == 1 ? '' : 's'}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                          )),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (index <= _taskItems.length) {
                      final item = _taskItems[index - 1];

                      return Dismissible(
                          key: Key('${item.parentObjectId} ${item.isMod}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: SKColors.skoller_blue,
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                item.isMod ? 'Accept' : 'Done',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            if (item.isMod)
                              (item.getParent as Mod).acceptMod();
                            else
                              (item.getParent as Assignment).toggleComplete();
                            setState(() {
                              _taskItems.removeAt(index - 1);
                            });
                          },
                          child: item.isMod
                              ? buildModCell(context, index - 1)
                              : buildTaskCell(context, index - 1));
                    } else
                      return GestureDetector(
                        key: Key('bottom item'),
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) {
                          setState(() =>
                              showingCompletedTasks = !showingCompletedTasks);
                          loadTasks();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Text(
                            showingCompletedTasks
                                ? 'Hide completed tasks'
                                : 'Show completed tasks',
                            style: TextStyle(
                                color: SKColors.skoller_blue,
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                        ),
                      );
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
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: StudentClass.currentClasses.length == 1
                                      ? Colors.white
                                      : SKColors.skoller_blue),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [UIAssets.boxShadow],
                              color: StudentClass.currentClasses.length == 1
                                  ? SKColors.skoller_blue
                                  : Colors.white),
                          child: StudentClass.currentClasses.length == 1
                              ? Text(
                                  'Join your 2nd class 👌',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  forecast == Forecast.all
                                      ? 'Semester outlook'
                                      : '$forecastStr-day forecast',
                                  style:
                                      TextStyle(color: SKColors.skoller_blue),
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

    final mods = Mod.modsByAssignmentId[task.id];

    if ((mods ?? []).length > 0) {
      String modDesc;

      if (mods.length == 1)
        switch (mods.first.modType) {
          case ModType.due:
            modDesc = 'Due date change';
            break;
          case ModType.weight:
            modDesc = 'Weight change';
            break;
          case ModType.delete:
            modDesc = 'Delete change';
            break;
          default:
            modDesc = '';
        }
      else
        modDesc = 'Multiple changes';

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
          StatefulWidget nextPage;

          if (mods.length == 1)
            nextPage = UpdateInfoView(mods);
          else
            nextPage = AssignmentInfoView(assignment_id: task.id);

          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => nextPage,
              settings: RouteSettings(
                  name: mods.length == 1
                      ? 'UpdateInfoView'
                      : 'AssignmentInfoView'),
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
              Padding(
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
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      task.parentClass?.name ?? '',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.normal),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: SKColors.warning_red),
                    child: Image.asset(ImageNames.forecastImages.harry_potter),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      modDesc,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: SKColors.warning_red),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else
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
              builder: (context) => AssignmentInfoView(assignment_id: task.id),
              settings: RouteSettings(name: 'AssignmentInfoView'),
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
            color:
                _tappedIndex == index ? SKColors.selected_gray : Colors.white,
          ),
          child: Column(
            children: <Widget>[
              Padding(
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
                    task.parentClass?.name ?? '',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                  if (task.weight_id != null && task.weight != null)
                    SKAssignmentImpactGraph(
                      task.weight,
                      task.parentClass.getColor(),
                      size: ImpactGraphSize.small,
                    )
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
            settings: RouteSettings(name: 'UpdateInfoView'),
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
            Padding(
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
