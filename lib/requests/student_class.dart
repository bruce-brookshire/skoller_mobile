part of 'requests_core.dart';

class StudentClass {
  int id;
  int enrollment;

  double grade;
  double completion;

  String name;
  String _color;
  String meetDays;
  String subject;
  String code;
  String section;

  TimeOfDay meetTime;

  Status status;
  Professor professor;

  List<Weight> weights;
  List<Assignment> assignments;

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
    this.weights,
    this.meetDays,
    this.meetTime,
    this.status,
    this.subject,
    this.code,
    this.section,
    this.professor,
  );

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

  Future<RequestResponse> createAssignment(
    String name,
    Weight weight,
    DateTime dueDate,
  ) {
    return SKRequests.post(
        '/students/${SKUser.current.student.id}/classes/${this.id}/assignments',
        {
          "due": dueDate.toIso8601String(),
          "weight_id": weight.id,
          "name": name,
          "is_completed": false,
          "is_private": false,
          "created_on": "mobile"
        },
        Assignment._fromJsonObj);
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
    final String startString = content['meet_start_time'];
    final startComponents = startString == null
        ? null
        : startString
            .split(':')
            .map((component) => int.parse(component))
            .toList();
    final startTime = (startString == null || startComponents.length < 2)
        ? null
        : TimeOfDay(hour: startComponents[0], minute: startComponents[1]);

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
      content['meet_days'],
      startTime,
      Status._fromJsonObj(content['status']),
      content['subject'],
      content['code'],
      content['section'],
      Professor._fromJsonObj(content['professor']),
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

class Status {
  int id;
  String name;

  Status(this.id, this.name);

  static Status _fromJsonObj(Map content) {
    return Status(
      content['id'],
      content['name'],
    );
  }
}

class Professor {
  int id;
  String first_name;
  String last_name;
  String email;
  String phone_number;
  String availability;
  String office_location;

  Professor(
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.phone_number,
    this.availability,
    this.office_location,
  );

  static Professor _fromJsonObj(Map content) {
    return Professor(
      content['id'],
      content['name_first'],
      content['name_last'],
      content['email'],
      content['phone_number'],
      content['availability'],
      content['office_location'],
    );
  }
}
