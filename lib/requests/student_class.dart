part of 'requests_core.dart';

class StudentClass {
  int id;
  int enrollment;

  bool isPoints;
  bool isNotifications;

  double grade;
  double completion;

  String name;
  String _color;
  String meetDays;
  String subject;
  String code;
  String section;
  String enrollmentLink;

  TimeOfDay meetTime;

  Status status;
  Professor professor;
  Period classPeriod;

  List<Weight> weights;
  List<Assignment> assignments;
  List<PublicStudent> students;

  Map<String, dynamic> gradeScale;

  static DateTimeZoneProvider tzdb;

  static final _classColors = [
    '9b55e5ff', // purple
    'ff71a8ff', // pink
    '57b9e4ff', // blue
    '4cd8bdff', // mint
    '4add58ff', // green
    'f7d300ff', // yellow
    'ffae42ff', // orange
    'dd4a63ff', // red
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
    this.weights,
    this.meetDays,
    this.meetTime,
    this.status,
    this.subject,
    this.code,
    this.section,
    this.professor,
    this.classPeriod,
    this.students,
    this.enrollmentLink,
    this.gradeScale,
    this.isPoints,
    this.isNotifications,
  );

  School getSchool() => School.currentSchools[classPeriod.schoolId];

  Color getColor() {
    final colorizer = (String colorStr) {
      String substr = 'ff' + colorStr.substring(0, colorStr.length - 2);
      return Color(int.parse(substr, radix: 16));
    };

    if (_color != null) {
      return colorizer(_color);
    } else {
      String newColor;

      //Make this an ordered map so we can iterate in order through the available colors
      final colorMap = LinkedHashMap.fromIterables(
        StudentClass._classColors,
        List.generate(StudentClass._classColors.length, (val) => false),
      );

      for (final studentClass in StudentClass.currentClasses.values) {
        if (studentClass._color != null) {
          colorMap[studentClass._color] = true;
        }
      }

      if (colorMap.containsValue(false)) {
        colorMap.removeWhere((key, val) => val);
        newColor = colorMap.keys.first;
      } else {
        final loc = Random.secure().nextInt(colorMap.length);
        newColor = colorMap.keys.toList()[loc];
      }

      _update({'color': newColor}).then((response) {
        if (response.wasSuccessful()) {
          this.refetchSelf();
        }
      });

      return colorizer(newColor);
    }
  }

  Future<RequestResponse> setColor(Color color) {
    this._color = color.value.toRadixString(16).substring(2) + 'ff';
    StudentClass.currentClasses[id]._color = this._color;

    return _update({'color': this._color}).then((response) {
      if (response.wasSuccessful()) {
        return this.refetchSelf();
      } else {
        return response;
      }
    });
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

  Future<RequestResponse> _update(Map params) {
    return SKRequests.put(
      '/students/${SKUser.current.student.id}/classes/${id}',
      params,
      StudentClass._fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        return refetchSelf();
      } else {
        return response;
      }
    });
  }

  /**
   * Creates an assignment for [this] StudentClass due at the local reference DateTime specified
   */
  Future<RequestResponse> createAssignment(
    String name,
    Weight weight,
    DateTime dueDate,
  ) async {
    String tzCorrectedString = dueDate.toUtc().toIso8601String();

    DateTime correctedDueDate =
        await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
      dueDate,
      getSchool().timezone,
    );

    if (correctedDueDate != null) {
      tzCorrectedString = correctedDueDate.toIso8601String();
    }

    return SKRequests.post(
        '/students/${SKUser.current.student.id}/classes/${this.id}/assignments',
        {
          "due": tzCorrectedString,
          "weight_id": weight.id,
          "name": name,
          "is_completed": false,
          "is_private": false,
          "created_on": "mobile"
        },
        Assignment._fromJsonObj);
  }

  Future<RequestResponse> createBatchAssignment(
    String name,
    Weight weight,
    DateTime dueDate,
  ) async {
    String tzCorrectedString = dueDate.toUtc().toIso8601String();

    DateTime correctedDueDate =
        await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
      dueDate,
      getSchool().timezone,
    );

    if (correctedDueDate != null) {
      tzCorrectedString = correctedDueDate.toIso8601String();
    }

    return SKRequests.post(
        '/classes/${this.id}/assignments',
        {
          "due": tzCorrectedString,
          "weight_id": weight.id,
          "name": name,
          "created_on": "mobile"
        },
        Assignment._fromJsonObj);
  }

  Future<RequestResponse> acquireAssignmentLock(Weight weight) {
    return SKRequests.post(
      "/classes/${id}/lock/assignments",
      {"subsection": weight.id},
      null,
    );
  }

  Future<RequestResponse> acquireWeightLock() {
    return SKRequests.post(
      "/classes/${id}/lock/weights",
      null,
      null,
    );
  }

  Future<bool> createWeights(
    bool isPoints,
    List<Map> weights,
  ) async {
    List<Future<RequestResponse>> requests = weights
        .toList()
        .map(
          (weight) => SKRequests.post(
              '/classes/$id/weights',
              {
                'name': weight['name'],
                'weight': weight['value'],
                'created_on': 'mobile'
              },
              null),
        )
        .toList();

    bool success = true;

    for (final request in requests) {
      final response = await request;
      if (!response.wasSuccessful()) {
        success = false;
        break;
      }
    }

    return success;
  }

  Future<RequestResponse> releaseDIYLock({bool isCompleted = true}) {
    return SKRequests.post(
      "/classes/${id}/unlock",
      {"is_completed": isCompleted},
      null,
    );
  }

  Future<RequestResponse> createStudentChat(String post) {
    return SKRequests.post(
      '/classes/$id/posts',
      {'post': post},
      Chat._fromJsonObj,
    ).then((response) {
      if (response.wasSuccessful()) {
        Chat.currentChats[response.obj.id] = response.obj;
      }
      return response;
    });
  }

  Future<RequestResponse> addGradeScale(Map scale) {
    return SKRequests.put(
      '/classes/$id',
      {'grade_scale': scale},
      null,
    ).then((response) {
      if (response.wasSuccessful()) {
        StudentClass.currentClasses[id].gradeScale =
            response.obj['grade_scale'];
      }
      return response;
    });
  }

  Future<RequestResponse> speculateClass() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes/$id/speculate',
      null,
    );
  }

  Future<bool> dropClass() {
    return SKRequests.delete(
      '/students/${SKUser.current.student.id}/classes/$id',
      null,
    ).then((response) {
      bool success = [200, 204].contains(response);
      if (success) {
        StudentClass.currentClasses.remove(id);
      }
      return success;
    });
  }

  Future<bool> toggleIsNotifications() {
    this.isNotifications = !this.isNotifications;

    return _update({'is_notifications': this.isNotifications})
        .then((response) => response.wasSuccessful());
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

  static StudentClass _fromJsonObj(Map content,
      {bool shouldPersistAssignments = true}) {
    if (content == null) {
      return null;
    }

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

    StudentClass studentClass = StudentClass(
      content['id'],
      content['name'],
      JsonListMaker.convert(
        (content) => Assignment._fromJsonObj(content,
            shouldPersist: shouldPersistAssignments),
        content['assignments'] ?? [],
      ),
      content['color'],
      content['grade'],
      content['completion'],
      content['enrollment'],
      JsonListMaker.convert(
        Weight._fromJsonObj,
        content['weights'] ?? [],
      ),
      content['meet_days'],
      startTime,
      Status._fromJsonObj(content['status']),
      content['subject'],
      content['code'],
      content['section'],
      Professor._fromJsonObj(content['professor']),
      Period._fromJsonObj(content['class_period']),
      JsonListMaker.convert(
        PublicStudent._fromJsonObj,
        content['students'] ?? [],
      ),
      content['enrollment_link'],
      content['grade_scale'],
      content['is_points'],
      content['is_notifications'],
    );

    StudentClass.currentClasses[studentClass.id] = studentClass;

    (studentClass.assignments ?? [])
        .forEach((assignment) => assignment.configureDateTimeOffset());

    return studentClass;
  }

  static Future<RequestResponse> getStudentClasses() {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes',
      (content) => _fromJsonObj(content, shouldPersistAssignments: false),
    );
  }

  static Future<RequestResponse> getStudentClassById(int id) {
    return SKRequests.get(
      '/students/${SKUser.current.student.id}/classes/${id}',
      _fromJsonObj,
    );
  }
}

class SchoolClass {
  int id;
  int enrollment;

  String name;
  String meetDays;
  String subject;
  String code;
  String section;

  TimeOfDay meetTime;

  Professor professor;
  Period classPeriod;

  //----------------//
  //Member functions//
  //----------------//

  SchoolClass(
    this.id,
    this.name,
    this.enrollment,
    this.meetDays,
    this.meetTime,
    this.subject,
    this.code,
    this.section,
    this.professor,
    this.classPeriod,
  );

  static SchoolClass _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

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

    SchoolClass schoolClass = SchoolClass(
      content['id'],
      content['name'],
      content['enrollment'],
      content['meet_days'],
      startTime,
      content['subject'],
      content['code'],
      content['section'],
      Professor._fromJsonObj(content['professor']),
      Period._fromJsonObj(content['class_period']),
    );

    return schoolClass;
  }

  Future<RequestResponse> enrollInClass() {
    return SKRequests.post(
      '/students/${SKUser.current.student.id}/classes/$id',
      null,
      StudentClass._fromJsonObj,
    );
  }

  static Future<http.Response> _activeClassSearch;

  static void invalidateCurrentClassSearch() {
    _activeClassSearch?.timeout(Duration.zero);
  }

  static Future<RequestResponse> searchSchoolClasses(
    String searchText,
    Period period,
  ) async {
    if (_activeClassSearch != null) {
      _activeClassSearch.timeout(Duration.zero);
      _activeClassSearch = null;
    }

    _activeClassSearch = SKRequests.rawGetRequest(
        '/periods/${period.id}/classes?class_name=$searchText');

    final request = await _activeClassSearch;

    return SKRequests.futureProcessor(request, _fromJsonObj);
  }
}

class Weight {
  int id;
  double weight;
  String name;

  Weight(this.id, this.weight, this.name);

  static Weight _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

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
    if (content == null) {
      return null;
    }

    return Status(
      content['id'],
      content['name'],
    );
  }
}

class Professor {
  int id;
  String firstName;
  String lastName;
  String email;
  String phone_number;
  String availability;
  String office_location;

  String get fullName {
    return (firstName ?? '') +
        (firstName == null || lastName == null ? '' : ' ') +
        (lastName ?? '');
  }

  Professor(
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone_number,
    this.availability,
    this.office_location,
  );

  static Professor _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

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
