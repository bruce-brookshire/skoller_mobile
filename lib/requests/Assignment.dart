part of 'requests_core.dart';

class Assignment {
  int id;
  int class_id;
  String name;
  DateTime due;
  double weight;
  int weight_id;

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
  );

  static Assignment _fromJsonObj(Map content) {
    var due = content['due'] != null ? DateTime.parse(content['due']) : null;
    return Assignment(content['id'], content['name'], due, content['class_id'],
        content['weight'], content['weight_id']);
  }

  static List<Assignment> _fromJsonArr(List content) {
    return JsonListMaker.convert(_fromJsonObj, content);
  }

  static Future<RequestResponse> getTasks() {
    DateTime now = DateTime.now();
    DateTime utcDate = DateTime.utc(now.year, now.month, now.day);

    return SKRequests.get(
      '/students/${SKUser.current.student.id}/assignments?is_complete=false&date=${utcDate.toIso8601String()}',
      listConstruct: _fromJsonArr,
    );
  }
}
