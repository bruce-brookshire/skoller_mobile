part of 'requests_core.dart';

class Assignment {
  //----------------//
  //Instance Members//
  //----------------//

  int id;
  int class_id;
  int weight_id;

  double weight;
  double grade;

  bool completed;
  bool _dueDateShifted = false;

  String name;
  DateTime due;

  List<AssignmentChat> posts;

  Future configureDateTimeOffset() async {
    if (!_dueDateShifted && due != null) {
      _dueDateShifted = true;

      due = await TimeZoneManager.createLocalRelativeAssignmentDueDate(
        due,
        parentClass.getSchool().timezone,
      );
    }
  }

  StudentClass get parentClass {
    return StudentClass.currentClasses[class_id];
  }

  Assignment(
    this.id,
    this.name,
    this.due,
    this.class_id,
    this.weight,
    this.weight_id,
    this.grade,
    this.completed,
    this.posts,
  );

  Future<RequestResponse> toggleComplete() {
    final newComplete = !(completed ?? false);
    return SKRequests.put(
      '/assignments/${id}',
      {'is_completed': newComplete},
      _fromJsonObj,
    );
  }

  String getWeightName() {
    final weight = this.parentClass.getWeightForId(weight_id);

    return weight == null ? 'Not graded' : weight.name;
  }

  //--------------//
  //Static Members//
  //--------------//

  static List<Assignment> currentTasks;
  static Map<int, Assignment> currentAssignments = {};

  static Assignment _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }
    var due = content['due'] != null ? DateTime.parse(content['due']) : null;

    Assignment assignment = Assignment(
      content['id'],
      content['name'],
      due,
      content['class_id'],
      content['weight'],
      content['weight_id'],
      content['grade'],
      content['is_completed'],
      JsonListMaker.convert(
          AssignmentChat._fromJsonObj, content['posts'] ?? []),
    );

    currentAssignments[assignment.id] = assignment;

    return assignment;
  }

/**
 * Gets the current tasks for the User.
 * Tasks are assignments for active classes that are in the future (and on today) and have not been completed
 */
  static Future<RequestResponse> getTasks() {
    DateTime now = DateTime.now();
    DateTime utcDate = DateTime.utc(now.year, now.month, now.day);

    return SKRequests.get(
      '/students/${SKUser.current.student.id}/assignments?is_complete=false&date=${utcDate.toIso8601String()}',
      _fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful() && response.obj != null) {
        currentTasks = response.obj;
        currentTasks
            .forEach((assignment) => assignment.configureDateTimeOffset());
      }
      return response;
    });
  }

/**
 * Gets the current assignments for the User.
 * Assignments are from all active classes
 */
  static Future<RequestResponse> getAssignments() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/assignments',
      _fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful() && response.obj != null) {
        currentTasks = response.obj;
      }
      return response;
    });
  }
}

class AssignmentChat {
  int id;
  PublicStudent student;
  String post;
  DateTime inserted_at;

  AssignmentChat(
    this.id,
    this.student,
    this.post,
    this.inserted_at,
  );

  static AssignmentChat _fromJsonObj(Map content) {
    return AssignmentChat(
        content['id'],
        PublicStudent._fromJsonObj(content['student']),
        content['post'],
        DateTime.parse(content['inserted_at']));
  }
}
