part of 'requests_core.dart';

class Assignment {
  //----------------//
  //Instance Members//
  //----------------//

  int id;
  int _parent_assignment_id;
  int classId;
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
    if (!_dueDateShifted && due != null && parentClass.getSchool() != null) {
      _dueDateShifted = true;

      due = await TimeZoneManager.createLocalRelativeAssignmentDueDate(
        due,
        parentClass.getSchool().timezone,
      );
    }
  }

  StudentClass get parentClass {
    return StudentClass.currentClasses[classId];
  }

  Assignment(
    this.id,
    this.name,
    this.due,
    this.classId,
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

  Future<RequestResponse> updateDueDate(
    bool isPrivate,
    DateTime dueDate,
  ) async {
    String tzCorrectedString = dueDate.toUtc().toIso8601String();

    DateTime correctedDueDate =
        await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
      dueDate,
      parentClass.getSchool().timezone,
    );

    if (correctedDueDate != null) {
      tzCorrectedString = correctedDueDate.toIso8601String();
    }

    return await SKRequests.put(
      '/assignments/${id}',
      {
        'is_private': isPrivate,
        'due': tzCorrectedString,
      },
      Assignment._fromJsonObj,
    );
  }

  Future<RequestResponse> updateWeightCategory(bool isPrivate, Weight weight) {
    return SKRequests.put(
      '/assignments/${id}',
      {
        'is_private': isPrivate,
        'weight_id': weight.id,
      },
      Assignment._fromJsonObj,
    );
  }

  Future<bool> delete(bool isPrivate) async {
    int statusCode = await SKRequests.delete(
      '/assignments/${id}',
      {'is_private': isPrivate},
    );

    if ([200, 204].contains(statusCode)) {
      Assignment.currentAssignments.remove(id);
      StudentClass.currentClasses[classId].assignments
          .removeWhere((a) => a.id == id);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> refetchSelf() {
    Future<RequestResponse> request = SKRequests.get(
      '/assignments/${id}',
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

  static Map<int, Assignment> currentAssignments = {};

  static Assignment _fromJsonObj(Map content, {bool shouldPersist = true}) {
    if (content == null) {
      return null;
    }
    var due = content['due'] != null ? DateTime.parse(content['due']) : null;
    if (content['class_id'] == null) {
      print(content['class_id'] == null);
      print(StackTrace.current);
      print(StackTrace.current.toString() == '');
      print(StackTrace.current.toString());
      print('hi');
    }

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

    if (shouldPersist) {
      currentAssignments[assignment.id] = assignment;
    }

    return assignment;
  }

// /**
//  * Gets the current assignments for the User.
//  * Assignments are from all active classes
//  */
//   static Future<RequestResponse> getAssignments() {
//     return SKRequests.get(
//       '/students/${SKUser.current.student.id}/assignments',
//       _fromJsonObj,
//       cachePath: 'assignments.json',
//       cacheResult: true,
//     );
//   }
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
