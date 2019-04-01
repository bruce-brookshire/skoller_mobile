part of 'requests_core.dart';

class StudentClass {
  int id;
  String name;
  List<Assignment> assignments;

  StudentClass(
    this.id,
    this.name,
    this.assignments,
  );

  static StudentClass _fromJsonObj(Map content) {
    return StudentClass(
      content['id'],
      content['name'],
      Assignment._fromJsonArr(content['assignments']),
    );
  }

  static List<StudentClass> _fromJsonArr(List content) {
    return JsonListMaker.convert(_fromJsonObj, content);
  }

  static Future<List<StudentClass>> getStudentClasses() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes',
      listConstruct: _fromJsonArr,
    ).then((response) {
      print(response);
      return response.obj;
    });
  }
}
