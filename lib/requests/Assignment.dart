part of 'requests_core.dart';

class Assignment {
  //----------------//
  //Instance Members//
  //----------------//

  int id;
  int class_id;
  String name;
  DateTime due;
  double weight;
  int weight_id;
  double grade;
  bool completed;

  StudentClass get parentClass {
    return StudentClass.currentClasses[class_id];
  }

  Assignment(this.id, this.name, this.due, this.class_id, this.weight,
      this.weight_id, this.grade, this.completed);

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

  static Assignment _fromJsonObj(Map content) {
    var due = content['due'] != null ? DateTime.parse(content['due']) : null;
    return Assignment(
        content['id'],
        content['name'],
        due,
        content['class_id'],
        content['weight'],
        content['weight_id'],
        content['grade'],
        content['is_completed']);
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
