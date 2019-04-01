part of 'requests_core.dart';

class StudentClass {
  int id;
  String name;
  List<Assignment> assignments;
  static Map<int, StudentClass> currentClasses = {};

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
      List<StudentClass> classes = response.obj;
      if (classes != null) {
        for (var student_class in classes) {
          currentClasses[student_class.id] = student_class;
        }
      }
      return classes;
    });
  }
}
