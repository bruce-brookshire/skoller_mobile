part of 'requests_core.dart';

class Assignment {
  //----------------//
  //Instance Members//
  //----------------//

  int id;
  int _parent_assignment_id;
  int class_id;
  int weight_id;

  double weight;
  double grade;

  bool completed;
  bool _dueDateShifted = false;
  bool isPostNotifications;

  String name;
  String notes;

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
    this._parent_assignment_id,
    this.isPostNotifications,
    this.notes,
  );

  Future<bool> toggleComplete() {
    final newComplete = !(completed ?? false);

    Future<RequestResponse> request = SKRequests.put(
      '/assignments/${id}',
      {'is_completed': newComplete},
      _fromJsonObj,
    );

    return _storeSuccessfulRequest(request);
  }

  String getWeightName() {
    final weight = this.parentClass.getWeightForId(weight_id);

    return weight == null ? 'Not graded' : weight.name;
  }

  Future<RequestResponse> savePost(String post) {
    return SKRequests.post(
      '/assignments/${_parent_assignment_id}/posts',
      {'post': post},
      AssignmentChat._fromJsonObj,
    );
  }

  Future<RequestResponse> saveGrade(num grade) {
    return SKRequests.post(
      '/assignments/${id}/grades',
      {'grade': grade},
      Assignment._fromJsonObj,
    );
  }

  Future<RequestResponse> removeGrade() {
    return SKRequests.post(
      '/assignments/${id}/grades',
      {'grade': null},
      Assignment._fromJsonObj,
    );
  }

  Future<bool> saveNotes(String notes) {
    Future<RequestResponse> request = SKRequests.put(
      '/assignments/${id}',
      {'notes': notes},
      _fromJsonObj,
    );

    return _storeSuccessfulRequest(request);
  }

  Future<bool> togglePostNotifications() {
    Future<RequestResponse> request = SKRequests.put(
      '/assignments/${id}',
      {'is_post_notifications': !isPostNotifications},
      Assignment._fromJsonObj,
    );

    return _storeSuccessfulRequest(request);
  }

  Future<bool> _storeSuccessfulRequest(
    Future<RequestResponse> request,
  ) async {
    RequestResponse response = await request;

    bool success = response.wasSuccessful();

    if (success) {
      Assignment assignment = response.obj;
      currentAssignments[assignment.id] = assignment;
    }

    return success;
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
      content['assignment_id'],
      content['is_post_notifications'],
      content['notes'],
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
        currentTasks.forEach((assignment) {
          Assignment.currentAssignments[assignment.id] = assignment;
          assignment.configureDateTimeOffset();
        });
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
        (response.obj as List<Assignment>).forEach((assignment) =>
            Assignment.currentAssignments[assignment.id] = assignment);
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
