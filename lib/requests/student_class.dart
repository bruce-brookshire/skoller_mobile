part of 'requests_core.dart';

class StudentClass {
  int id;
  String name;
  List<Assignment> assignments;
  String _color;
  static Map<int, StudentClass> currentClasses = {};
  double grade;
  double completion;
  int enrollment;

  static final List<Color> colors = [
    Color(0xFFdd4a63), //Red
    Color(0xFFFFAE42), //orange
    Color(0xFFF7D300), //yellow
    Color(0xFF4ADD58), //green
    Color(0xFF4CD8BD), //mint
    Color(0xFF57B9E4), //blue
    Color(0xFFFF71A8), //pink
    Color(0xFF9B55E5), //purple
  ];

  //----------------//
  //Member functions//
  //----------------//

  StudentClass(
    this.id,
    this.name,
    this.assignments,
    this._color,
    this.grade,
    this.completion,
    this.enrollment,
  );

  Color getColor() {
    if (_color != null) {
      String substr = 'ff' + _color.substring(0, _color.length - 2);
      return Color(int.parse(substr, radix: 16));
    } else {
      return colors[1];
    }
  }

  //----------------//
  //Static functions//
  //----------------//

  static StudentClass _fromJsonObj(Map content) {
    return StudentClass(
      content['id'],
      content['name'],
      Assignment._fromJsonArr(content['assignments']),
      content['color'],
      content['grade'],
      content['completion'],
      content['enrollment'],
    );
  }

  static List<StudentClass> _fromJsonArr(List content) {
    return JsonListMaker.convert(_fromJsonObj, content);
  }

  static Future<RequestResponse> getStudentClasses() {
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
      return response;
    });
  }
}
