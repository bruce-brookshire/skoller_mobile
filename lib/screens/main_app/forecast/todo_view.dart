import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/screens/main_app/activity/update_info_view.dart';
import 'package:skoller/screens/main_app/menu/add_classes_view.dart';
import 'package:skoller/screens/main_app/tutorial/todo_tutorial_view.dart';
import 'package:skoller/tools.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';

enum Todo { tenDay, thirtyDay, all }

class TodoView extends StatefulWidget {
  State createState() => _TodoState();
}

class _TodoState extends State<TodoView> {
  List<_TaskLikeItem> _taskItems = [];
  Todo todo = Todo.tenDay;
  bool showingCompletedTasks = false;
  bool completedTasksAvailable = false;

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
    if (Todo == Todo.all)
      outlook = 365;
    else if (Todo == Todo.thirtyDay)
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

  void tappedChangeTodo(TapUpDetails details) async {
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
        title: 'To-Do\'s',
        subtitle: 'How far out do you want to look?',
        items: ['10-day', '30-day', 'Semester outlook'],
        onSelect: (selection) => selectedIndex = selection,
      ),
    );

    if (results is bool && results && selectedIndex != null) {
      if (selectedIndex == 0)
        todo = Todo.tenDay;
      else if (selectedIndex == 1)
        todo = Todo.thirtyDay;
      else
        todo = Todo.all;

      loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    //If we do not have a setup class
    if (!StudentClass.liveClassesAvailable)
      return TodoTutorialView(
        () => DartNotificationCenter.post(
            channel: NotificationChannels.selectTab, options: CLASSES_TAB),
        'Setup first class',
      );
    final setupSecondClass = StudentClass.currentClasses.length == 2 &&
        StudentClass.currentClasses.values
            .any((c) => c.status.id == ClassStatuses.needs_setup);

    String TodoStr;
    switch (todo) {
      case Todo.tenDay:
        TodoStr = '10';
        break;
      case Todo.thirtyDay:
        TodoStr = '30';
        break;
      case Todo.all:
        TodoStr = '';
        break;
    }

    return SKNavView(
      title: 'To-Do\'s',
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
                                        ImageNames.todoImages.forecast),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: setupSecondClass
                                    ? Text(
                                        'Todo works best when all of you’re classes are set up.',
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
                                              text: 'Your personal Todo shows ',
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
                                                Todo == Todo.all
                                                    ? TextSpan(
                                                        text: ' left to do.',
                                                      )
                                                    : TextSpan(
                                                        text:
                                                            ' due in the next $TodoStr days.',
                                                      ),
                                              ],
                                            ),
                                          )),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (index <= _taskItems.length)
                      return _TodoRow(_taskItems[index - 1]);
                    else
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
                        onTapUp: tappedChangeTodo,
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
                              boxShadow: UIAssets.boxShadow,
                              color: StudentClass.currentClasses.length == 1
                                  ? SKColors.skoller_blue
                                  : Colors.white),
                          child: StudentClass.currentClasses.length == 1
                              ? Text(
                                  'Join your 2nd class 👌',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  Todo == Todo.all
                                      ? 'Semester outlook'
                                      : '$TodoStr-day outlook',
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

class _TodoRow extends StatefulWidget {
  final _TaskLikeItem item;

  _TodoRow(this.item);

  @override
  State<StatefulWidget> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  bool isTapped = false;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) =>
      widget.item.isMod ? buildModCell() : buildTaskCell();

  Widget buildTaskCell() {
    final Assignment task = widget.item.getParent;

    final mods = Mod.modsByAssignmentId[task.id];

    if ((mods ?? []).length > 0)
      return buildTaskUpdatesCell(task, mods);
    else if (isChecked)
      return buildTaskCheckedCell(task);
    else
      return buildTasksNormalCell(task);
  }

  Widget buildModCell() {
    final Mod mod = widget.item.getParent;

    return GestureDetector(
      onTapUp: (details) => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => UpdateInfoView([mod]),
          settings: RouteSettings(name: 'UpdateInfoView'),
        ),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.dark_gray, width: 1),
          boxShadow: UIAssets.boxShadow,
          color: Colors.white,
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

  Widget buildTaskUpdatesCell(Assignment task, List<Mod> mods) {
    String modDesc;

    if (mods.length == 1)
      switch (mods.first.modType) {
        case ModType.due:
          modDesc = 'Due Date Change ALERT';
          break;
        case ModType.weight:
          modDesc = 'Weight Change ALERT';
          break;
        case ModType.delete:
          modDesc = 'Delete Change ALERT';
          break;
        default:
          modDesc = '';
      }
    else
      modDesc = 'Multiple changes';

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          isTapped = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isTapped = false;
        });
      },
      onTapUp: (details) {
        setState(() {
          isTapped = false;
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
                name:
                    mods.length == 1 ? 'UpdateInfoView' : 'AssignmentInfoView'),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.text_light_gray, width: 1),
            boxShadow: UIAssets.boxShadow,
            color: Colors.white,
            gradient: LinearGradient(colors: [
              task.parentClass.getColor(),
              task.parentClass.getColor().withAlpha(100)
            ])),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    modDesc,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    'TAP HERE to view!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Image.asset(ImageNames.peopleImages.people_white),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTaskCheckedCell(Assignment task) => GestureDetector(
        child: Container(
          margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray, width: 1),
            boxShadow: UIAssets.boxShadow,
            color: SKColors.menu_blue,
          ),
          child: Row(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) => setState(() => isChecked = false),
                child: Container(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: SKColors.text_light_gray),
                      borderRadius: BorderRadius.circular(10),
                      color: SKColors.skoller_blue,
                    ),
                    width: 20,
                    height: 20,
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        task?.name ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: task.parentClass.getColor(),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontSize: 17),
                      ),
                    ),
                    Text(
                      DateUtilities.getFutureRelativeString(task.due),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SKColors.skoller_blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: ShakeAnimation(
                  child: Text(
                    'Mark as complete',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10),
                  ),
                ),
              )
            ],
          ),
        ),
      );

  Widget buildTasksNormalCell(Assignment task) => GestureDetector(
        onTapDown: (details) {
          setState(() {
            isTapped = true;
          });
        },
        onTapCancel: () {
          setState(() {
            isTapped = false;
          });
        },
        onTapUp: (details) {
          setState(() {
            isTapped = false;
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray, width: 1),
            boxShadow: UIAssets.boxShadow,
            color: isTapped ? SKColors.selected_gray : Colors.white,
          ),
          child: Row(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) => setState(() => isChecked = true),
                child: Container(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: SKColors.text_light_gray),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            task?.name ?? 'N/A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: task.parentClass.getColor(),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                fontSize: 17),
                          ),
                        ),
                        if (task.weight_id != null && task.weight != null)
                          SKAssignmentImpactGraph(
                            task.weight,
                            task.parentClass.getColor(),
                            size: ImpactGraphSize.small,
                          )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateUtilities.getFutureRelativeString(task.due),
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Expanded(
                          child: Text(
                            task?.parentClass?.name ?? 'N/A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: SKColors.text_light_gray,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
