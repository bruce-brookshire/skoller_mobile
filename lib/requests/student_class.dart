part of 'requests_core.dart';

class StudentClass {
  int id;
  String name;
  List<Assignment> assignments;
  String _color;
  double grade;
  double completion;
  int enrollment;
  List<Weight> weights;

  //----------------//
  //Member functions//
  //----------------//

  StudentClass(this.id, this.name, this.assignments, this._color, this.grade,
      this.completion, this.enrollment, this.weights);

  Color getColor() {
    if (_color != null) {
      String substr = 'ff' + _color.substring(0, _color.length - 2);
      return Color(int.parse(substr, radix: 16));
    } else {
      return colors[1];
    }
  }

  Weight getWeightForId(weight_id) {
    for (Weight weight in weights) {
      if (weight.id == weight_id) {
        return weight;
      }
    }
    return null;
  }

  Future<RequestResponse> refetchSelf() {
    return getStudentClassById(id).then((response) {
      if (response.wasSuccessful()) {
        StudentClass copy = response.obj;
        StudentClass.currentClasses[copy.id] = copy;
      }
      return response;
    });
  }

  //--------------//
  //Static Members//
  //--------------//

  static Map<int, StudentClass> currentClasses = {};
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

  static StudentClass _fromJsonObj(Map content) {
    return StudentClass(
      content['id'],
      content['name'],
      JsonListMaker.convert(
        Assignment._fromJsonObj,
        content['assignments'],
      ),
      content['color'],
      content['grade'],
      content['completion'],
      content['enrollment'],
      JsonListMaker.convert(
        Weight._fromJsonObj,
        content['weights'],
      ),
    );
  }

  static Future<RequestResponse> getStudentClasses() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes',
      _fromJsonObj,
    ).then((response) {
      List classes = response.obj;
      if (classes != null && response.wasSuccessful()) {
        for (StudentClass studentClass in classes) {
          currentClasses[studentClass.id] = studentClass;
        }
      }
      return response;
    });
  }

  static Future<RequestResponse> getStudentClassById(int id) {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes/${id}',
      _fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        StudentClass studentClass = response.obj;
        currentClasses[studentClass.id] = studentClass;
      }
      return response;
    });
  }
}

class Weight {
  int id;
  double weight;
  String name;

  Weight(this.id, this.weight, this.name);

  static Weight _fromJsonObj(Map content) {
    return Weight(
      content['id'],
      content['weight'],
      content['name'],
    );
  }
}
