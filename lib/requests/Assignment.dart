part of 'requests_core.dart';

class Assignment {
  int id;
  int class_id;
  String name;
  DateTime due;

  Assignment(this.id, this.name, this.due, this.class_id);

  static Assignment _fromJsonObj(Map content) {
    var due = content['due'] != null ? DateTime.parse(content['due']) : null;
    return Assignment(content['id'], content['name'], due, content['class_id']);
  }

  static List<Assignment> _fromJsonArr(List content) {
    return JsonListMaker.convert(_fromJsonObj, content);
  }
}
