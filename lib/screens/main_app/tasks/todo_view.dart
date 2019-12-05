import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/screens/main_app/tasks/dateless_assignments_modal.dart';
import 'package:skoller/screens/main_app/tasks/todo_preferences_modal.dart';
import '../activity/mod_modal.dart';
import '../menu/add_classes_view.dart';
import '../tutorial/todo_tutorial_view.dart';
import '../classes/assignment_info_view.dart';
import '../classes/assignment_weight_view.dart';
import 'package:skoller/tools.dart';

class TodoView extends StatefulWidget {
  State createState() => _TodoState();
}

class _TodoState extends State<TodoView> {
  List<_TaskLikeItem> _taskItems = [];
  List<int> _datelessAssignments = [];

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

    final student = SKUser.current.student;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdueDate = today.subtract(Duration(days: student.todoDaysPast));
    final outlookDate = today.add(Duration(days: student.todoDaysFuture));

    int minDaysOutCompleted = 1000;
    bool newCompletedTasksAvailable = false;

    List<_TaskLikeItem> tasks = (Assignment.currentAssignments.values.toList()
          ..removeWhere((a) =>
              (a.due?.isBefore(overdueDate) ?? true) || a.parentClass == null)
          ..removeWhere((a) {
            if (a.isCompleted) {
              newCompletedTasksAvailable = true;

              int daysOut = a.due.difference(today).inDays;
              print(daysOut);
              if (daysOut < minDaysOutCompleted && daysOut >= 0) {
                print(a.name);
                print(daysOut);
                minDaysOutCompleted = daysOut;
              }
            }
            // Remove if we are not showing completed tasks and the task is completed,
            // OR if we are showing completed tasks and the task's due date is before today
            return a.isCompleted &&
                (!showingCompletedTasks || a.due.isBefore(today));
          }))
        .map((a) => _TaskLikeItem(a.id, false, a.due))
        .toList();

    // If there are tasks that are completed before its due date, show the
    // 'view completed assignments' button
    if (newCompletedTasksAvailable &&
        minDaysOutCompleted > student.todoDaysFuture)
      newCompletedTasksAvailable = false;

    // Fetch mods
    RequestResponse modResponse = await modsRequest;

    // If mods fetched successfully, process and add to task list
    if (modResponse.wasSuccessful()) {
      List<_TaskLikeItem> temp = (modResponse.obj as List<Mod>)
          .map((m) => _TaskLikeItem(m.id, true, m.data.due))
          .toList();

      // Remove mods that are past due and that have not been accepted yet
      temp.removeWhere((task) =>
          task.dueDate.isBefore(today) || task.getParent?.isAccepted != null);

      tasks.addAll(temp);
    }

    // Remove where the parent object does not exist or the assignment/task
    // is due after the max outlook date
    tasks
      ..removeWhere((task) {
        if (task.getParent == null) return true;

        return task.dueDate.isAfter(outlookDate);
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

    _datelessAssignments = Assignment.currentAssignments.values
        .where((a) => a.due == null)
        .map((a) => a.id)
        .toList();

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
        title: 'Add Assignment',
        subtitle: 'Select a class',
        items: classes.map((cl) => cl.name).toList(),
        onSelect: (newIndex) => selectedIndex = newIndex,
        onOptionChildTapped: () => DartNotificationCenter.post(
            channel: NotificationChannels.presentViewOverTabBar,
            options: AddClassesView()),
        optionChild: Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.only(top: 4, bottom: 4),
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: SKColors.border_gray),
                bottom: BorderSide(color: SKColors.border_gray)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Can\'t find your class? ',
                  style: TextStyle(fontWeight: FontWeight.w300)),
              Text(
                'Add class',
                style: TextStyle(
                    color: SKColors.skoller_blue, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
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

  void onCompleteAssignment(Assignment task) async {
    final index = _taskItems
        .indexWhere((item) => !item.isMod && item.parentObjectId == task.id);

    bool success;

    if (!showingCompletedTasks) {
      final item = _taskItems.removeAt(index);

      setState(() {});

      success = await task.toggleComplete();

      if (!success) _taskItems.insert(index, item);
    } else
      success = await task.toggleComplete();

    if (success)
      DartNotificationCenter.post(
          channel: NotificationChannels.assignmentChanged);
  }

  void tappedChangeTodo(TapUpDetails details) async {
    if (StudentClass.currentClasses.length == 1) {
      DartNotificationCenter.post(
        channel: NotificationChannels.presentViewOverTabBar,
        options: AddClassesView(),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      SKNavOverlayRoute(builder: (_) => TodoPreferencesModal()),
    );

    if (result is bool && result) loadTasks();
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

    final titleOption = _datelessAssignments.length == 0
        ? null
        : GestureDetector(
            onTapUp: (_) => Navigator.push(
              context,
              SKNavOverlayRoute(
                  builder: (context) =>
                      DatelessAssignmentsModal(_datelessAssignments)),
            ),
            child: Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.only(left: 4, top: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: SKColors.alert_orange),
              child: Text(
                '!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
              ),
            ),
          );

    final todoDaysFuture = SKUser.current.student.todoDaysFuture;

    return SKNavView(
      title: 'To-Do\'s',
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () {
        DartNotificationCenter.post(channel: NotificationChannels.toggleMenu);
      },
      rightBtn: Image.asset(ImageNames.rightNavImages.plus),
      callbackRight: tappedAdd,
      titleOption: titleOption,
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: fetchTasks,
            child: Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(top: 4, bottom: 64),
                  itemCount: _taskItems.length == 0
                      ? 2
                      : (_taskItems.length + (completedTasksAvailable ? 2 : 1)),
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return createSammiPrompt(
                          setupSecondClass, todoDaysFuture);
                    else if (index <= _taskItems.length)
                      return _TodoRow(
                        _taskItems[index - 1],
                        this.onCompleteAssignment,
                      );
                    else if (_taskItems.length == 0)
                      return Image.asset(
                          ImageNames.todoImages.students_in_pool);
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
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                              : Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.calendar_view_day,
                                        color: SKColors.skoller_blue,
                                      ),
                                    ),
                                    Text(
                                      todoDaysFuture == 180
                                          ? 'Full semester'
                                          : 'Next $todoDaysFuture days',
                                      style: TextStyle(
                                          color: SKColors.skoller_blue),
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

  Widget createSammiPrompt(bool setupSecondClass, int todoDaysFuture) {
    final day = DateFormat('EEEE').format(DateTime.now());
    final assignments = _taskItems.length;

    Widget sammiBody;

    if (setupSecondClass)
      sammiBody = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Get your classes set up 💪',
            style: TextStyle(fontSize: 17),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text.rich(
              TextSpan(
                text: 'To-do\'s works best when ',
                children: [
                  TextSpan(
                    text: 'all your classes ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: 'are setup on Skoller.'),
                ],
              ),
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            ),
          ),
        ],
      );
    else
      sammiBody = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Happy $day, ${SKUser.current.student.nameFirst}!',
            style: TextStyle(fontSize: 17),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: assignments == 0
                ? Text(
                    'You’re all caught up! 😃',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  )
                : Text.rich(
                    TextSpan(
                      text: 'You have ',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 13),
                      children: [
                        TextSpan(
                          text:
                              '${assignments} assignment${assignments == 1 ? '' : 's'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        todoDaysFuture == 180
                            ? TextSpan(
                                text: ' left to do.',
                              )
                            : TextSpan(
                                text: ' due in the next $todoDaysFuture days.',
                              ),
                      ],
                    ),
                  ),
          ),
        ],
      );

    return Padding(
      key: Key('top item'),
      padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
      child: SammiSpeechBubble(
        sammiPersonality: SammiPersonality.smile,
        speechBubbleContents: sammiBody,
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

class _TodoRow extends StatefulWidget {
  final _TaskLikeItem item;
  final AssignmentCallback onCompleted;

  _TodoRow(this.item, this.onCompleted);

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = task.due.isBefore(today);

    if ((mods ?? []).length > 0)
      return buildTaskUpdatesCell(task, mods);
    else if (isChecked || task.isCompleted)
      return buildTaskCheckedCell(task);
    else if (isOverdue)
      return buildTaskOverdueCell(task);
    else
      return buildTasksNormalCell(task);
  }

  Widget buildModCell() {
    final Mod mod = widget.item.getParent;
    final task = mod.data;

    return GestureDetector(
      onTapUp: (details) {
        Navigator.push(
          context,
          SKNavOverlayRoute(builder: (context) => ModModal(mod)),
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
                    'New Assignment ALERT',
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
      onTapUp: (details) {
        Route nextRoute;

        if (mods.length == 1)
          nextRoute = SKNavOverlayRoute(
            builder: (context) => ModModal(mods.first),
          );
        else
          nextRoute = CupertinoPageRoute(
            builder: (context) => AssignmentInfoView(assignmentId: task.id),
            settings: RouteSettings(
                name:
                    mods.length == 1 ? 'UpdateInfoView' : 'AssignmentInfoView'),
          );

        Navigator.push(context, nextRoute);
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
        onTapUp: task.isCompleted
            ? (_) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        AssignmentInfoView(assignmentId: task.id),
                    settings: RouteSettings(name: 'AssignmentInfoView'),
                  ),
                );
              }
            : null,
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
                      color: task.isCompleted
                          ? SKColors.dark_gray
                          : SKColors.skoller_blue,
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
                      task.isCompleted
                          ? 'Completed'
                          : DateUtilities.getFutureRelativeString(task.due),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) {
                  widget.onCompleted(task);
                  setState(() {
                    isChecked = false;
                  });
                },
                child: Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? SKColors.dark_gray
                        : SKColors.skoller_blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: task.isCompleted
                      ? Text(
                          'Mark incomplete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10),
                        )
                      : ShakeAnimation(
                          child: Text(
                            'Mark as complete',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildTaskOverdueCell(Assignment task) => GestureDetector(
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
              builder: (context) => AssignmentInfoView(assignmentId: task.id),
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
            color: isTapped ? SKColors.selected_gray : SKColors.border_gray,
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
                      border: Border.all(color: SKColors.warning_red),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        task?.name ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: SKColors.dark_gray,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontSize: 17),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateUtilities.getPastRelativeString(task.due),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: SKColors.warning_red),
                        ),
                        Expanded(
                          child: Text(
                            task?.parentClass?.name ?? 'N/A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: SKColors.light_gray,
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
              builder: (context) => AssignmentInfoView(assignmentId: task.id),
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
