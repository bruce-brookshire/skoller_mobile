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

  Weight get weightObject {
    return Weight.currentWeights[weight_id];
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

    return SKRequests.put(
      '/assignments/${id}',
      {'is_completed': newComplete},
      (content) => _fromJsonObj(content, shouldPersist: false),
    ).then((response) {
      final success = response.wasSuccessful();

      if (success) {
        Assignment.currentAssignments[id].completed = response.obj.completed;
      }
      return success;
    });
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
      (content) => _fromJsonObj(content, shouldPersist: false),
    ).then((response) {
      if (response.wasSuccessful()) {
        Assignment.currentAssignments[id].grade = response.obj.grade;
        Assignment.currentAssignments[id].completed = response.obj.completed;
        parentClass.refetchSelf();
      }

      return response;
    });
  }

  Future<RequestResponse> removeGrade() {
    return SKRequests.post(
      '/assignments/${id}/grades',
      {'grade': null},
      (content) => _fromJsonObj(content, shouldPersist: false),
    ).then((response) {
      if (response.wasSuccessful()) {
        Assignment.currentAssignments[id].grade = null;
        parentClass.refetchSelf();
      }

      return response;
    });
  }

  Future<bool> saveNotes(String notes) {
    return SKRequests.put(
      '/assignments/${id}',
      {'notes': notes},
      (content) => _fromJsonObj(content, shouldPersist: false),
    ).then((response) {
      final success = response.wasSuccessful();

      if (success) Assignment.currentAssignments[id].notes = response.obj.notes;

      return success;
    });
  }

  Future<bool> togglePostNotifications() {
    return SKRequests.put(
      '/assignments/${id}',
      {'is_post_notifications': !isPostNotifications},
      (content) => _fromJsonObj(content, shouldPersist: false),
    ).then((response) {
      final success = response.wasSuccessful();

      if (success)
        Assignment.currentAssignments[id].isPostNotifications =
            response.obj.isPostNotifications;

      return success;
    });
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

    return SKRequests.put(
      '/assignments/${id}',
      {
        'is_private': isPrivate,
        'due': tzCorrectedString,
      },
      Assignment._fromJsonObj,
    );
  }

  Future<RequestResponse> addDueDate(DateTime dueDate) async {
    String tzCorrectedString = dueDate.toUtc().toIso8601String();

    DateTime correctedDueDate =
        await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
      dueDate,
      parentClass.getSchool().timezone,
    );

    if (correctedDueDate != null) {
      tzCorrectedString = correctedDueDate.toIso8601String();
    }

    return SKRequests.put(
      '/assignments/${id}/add-due-date',
      {
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

  Future<RequestResponse> updateName(String name) {
    return SKRequests.put(
      '/assignments/${id}',
      {
        'is_private': true,
        'name': name,
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
    return SKRequests.get(
      '/assignments/${id}',
      Assignment._fromJsonObj,
    ).then((response) => response.wasSuccessful());
  }

  //--------------//
  //Static Members//
  //--------------//

  static Map<int, Assignment> currentAssignments = {};

  static Assignment _fromJsonObj(Map content, {bool shouldPersist = true}) {
    if (content == null) {
      return null;
    }
    final due = content['due'] != null ? DateTime.parse(content['due']) : null;

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
