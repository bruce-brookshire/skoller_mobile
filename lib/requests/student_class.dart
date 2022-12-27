part of 'requests_core.dart';

class StudentClass {
  int id;
  int? enrollment;

  bool isPoints;
  bool isNotifications;
  bool isOnline;

  double grade;
  double completion;

  String? name = null;
  String _color;
  String? meetDays;
  String? subject;
  String? code;
  String? section;
  String enrollmentLink;

  TimeOfDay? meetTime;

  Status status;
  Professor professor;
  Period classPeriod;

  List<Weight>? weights;
  List<Assignment>? assignments;
  List<PublicStudent>? students;
  List<ClassDocument> documents;

  Map<String, dynamic> gradeScale;

  List<ChangeRequest> changeRequests;

  static time_machine.DateTimeZoneProvider? tzdb;

  static final _classColors = [
    'AE77BDFF', // Lavendar
    'E882ACFF', // Pink
    '3484E3FF', // Blue
    '61D8A0FF', // Mint
    '19A394FF', // Teal
    'F1AA39FF', // Yello
    'E2762DFF', // Orange
    'D73F76FF', // Magenta
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
    this.documents,
    this.isOnline,
    this.changeRequests,
  );

  String get shareMessage {
    return id % 2 == 0
        ? 'Ditch your paper planner. Skoller unlocks academic organization and keeps you on track all year long. Our class $name is already set up. Sign up using this link to join me!\n\n$enrollmentLink'
        : 'This new app takes our syllabus and sends reminders about upcoming due dates, organizes assignments into a calendar, and much more. Our class $name is already set up. Sign up using this link to join me!\n\n$enrollmentLink';
  }

  School get parentSchool => School.currentSchools[classPeriod.schoolId]!;

  List<ChangeRequest> get gradeScaleChangeRequests =>
      _filterChangesForType(100);
  List<ChangeRequest> get weightChangeRequests => _filterChangesForType(200);
  List<ChangeRequest> get professorInfoChangeRequests =>
      _filterChangesForType(300);
  List<ChangeRequest> get classInfoChangeRequests => _filterChangesForType(400);

  List<ChangeRequest> _filterChangesForType(int id) => changeRequests
      .where(
          (c) => c.changeType.id == id && c.members.any((m) => !m.isCompleted))
      .toList();

  Color getColor() {
    final colorizer = (String colorStr) {
      String substr = 'ff' + colorStr.substring(0, colorStr.length - 2);
      return Color(int.parse(substr, radix: 16));
    };

    return colorizer(_color != null ? _color : initializeColor());
  }

  String initializeColor() {
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

    return newColor;
  }

  Future<RequestResponse> setColor(Color color) {
    this._color = color.value.toRadixString(16).substring(2) + 'ff';
    StudentClass.currentClasses[id]!._color = this._color;

    return _update({'color': this._color}).then((response) {
      if (response.wasSuccessful()) {
        return this.refetchSelf();
      } else {
        return response;
      }
    });
  }

  Weight? getWeightForId(weight_id) {
    for (Weight weight in weights!) {
      if (weight.id == weight_id) {
        return weight;
      }
    }
    return null;
  }

  Future<RequestResponse> refetchSelf() {
    return getStudentClassById(id);
  }

  Future<RequestResponse> _update(Map params) {
    return SKRequests.put(
      '/students/${SKUser.current?.student.id}/classes/${id}',
      params,
      (content) => StudentClass._fromJsonObj(content),
    ).then((response) {
      if (response.wasSuccessful()) {
        return refetchSelf();
      } else {
        return response;
      }
    }).then((response) {
      if ((response as RequestResponse).wasSuccessful()) {
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);
      }
      return response;
    });
  }

  Future<RequestResponse> _updateParentClass(Map params) {
    return SKRequests.put('/classes/$id', params, null);
  }

  /**
   * Creates an assignment for [this] StudentClass due at the local reference DateTime specified
   */
  Future<RequestResponse> createAssignment(
    String name,
    Weight weight,
    DateTime dueDate,
    bool isPrivate,
  ) async {
    String? tzCorrectedString = dueDate.toUtc().toIso8601String();

    DateTime? correctedDueDate = dueDate == null
        ? null
        : await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
            dueDate,
            parentSchool.timezone,
          );

    if (correctedDueDate != null) {
      tzCorrectedString = correctedDueDate.toIso8601String();
    }

    return SKRequests.post(
        '/students/${SKUser.current?.student.id}/classes/${this.id}/assignments',
        {
          "due": tzCorrectedString,
          "weight_id": weight.id,
          "name": name,
          "is_completed": false,
          "is_private": isPrivate,
          "created_on": "mobile"
        },
        (content) =>
            Assignment._fromJsonObj(content, shouldPersist: false)).then(
        (response) {
      if (response.wasSuccessful()) {
        (response.obj as Assignment).refetchSelf();
      }
      return response;
    });
  }

  Future<RequestResponse> createBatchAssignment(
    String name,
    Weight weight,
    DateTime? dueDate,
  ) async {
    String? tzCorrectedString = dueDate?.toUtc().toIso8601String();

    DateTime? correctedDueDate = dueDate == null
        ? null
        : await TimeZoneManager.convertUtcOffsetFromLocalToSchool(
            dueDate,
            parentSchool.timezone,
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
        (content) => Assignment._fromJsonObj(content, shouldPersist: false));
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
      Map(),
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

    final updatePoints = await _updateParentClass({'is_points': isPoints});

    bool success = updatePoints.wasSuccessful();

    if (success)
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

  Future<RequestResponse> addGradeScale(Map scale) {
    return SKRequests.put(
      '/classes/$id',
      {'grade_scale': scale},
      null,
    ).then((response) {
      if (response.wasSuccessful()) {
        StudentClass.currentClasses[id]!.gradeScale =
            response.obj['grade_scale'];
      }
      return response;
    });
  }

  Future<RequestResponse> speculateClass() {
    return SKRequests.get(
      '/students/${SKUser.current?.student.id}/classes/$id/speculate',
      null,
    );
  }

  Future<bool> dropClass() {
    return SKRequests.delete(
      '/students/${SKUser.current?.student.id}/classes/$id',
      Map(),
    ).then((response) {
      bool success = [200, 204].contains(response);
      if (success) {
        StudentClass.currentClasses.remove(id);
        Assignment.currentAssignments.removeWhere((_, v) => v.classId == id);
      }
      return success;
    });
  }

  Future<bool> toggleIsNotifications() {
    this.isNotifications = !this.isNotifications;

    return _update({'is_notifications': this.isNotifications})
        .then((response) => response.wasSuccessful());
  }

  Future<bool> submitClassChangeRequest({
    TimeOfDay? meetTime,
    String? meetDays,
    String? name,
    String? subject,
    String? code,
    String? section,
    bool? isOnline,
  }) {
    Map<String, dynamic> body = {
      'id': id,
      'meet_days': meetDays,
      'meet_start_time': isOnline! ? 'online' : _startTimeString(meetTime!),
      'name': name,
      'subject': subject,
      'code': code,
      'section': section,
    };

    body.removeWhere((k, v) => v == null);
    if (body.length == 1) return Future.value(true);

    return SKRequests.post('/classes/$id/changes/400', {'data': body}, null)
        .then((response) => response.wasSuccessful());
  }

  Future<bool> submitProfessorChangeRequest({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? officeLocation,
    String? availability,
  }) {
    Map<String, dynamic> body = {
      'id': id,
      'name_first': firstName,
      'name_last': lastName,
      'email': email,
      'phone': phoneNumber,
      'office_location': officeLocation,
      'office_availability': availability,
    };

    body.removeWhere((k, v) => v == null);
    if (body.length == 1) return Future.value(true);

    return SKRequests.post('/classes/$id/changes/300', {'data': body}, null)
        .then((response) {
      return response.wasSuccessful();
    });
  }

  String? _startTimeString(TimeOfDay time) => time == null
      ? null
      : '${time.hour < 10 ? '0' : ''}${time.hour}:${time.minute < 10 ? '0' : ''}${time.minute}:00';

  Future<bool> submitWeightChangeRequest(bool isPoints, List<Map> weights) {
    final body = weights.fold<Map>(
      Map(),
      (c, e) => c..[e['name']] = e['value'],
    );

    if (isPoints != this.isPoints) body['is_points'] = '$isPoints';

    return SKRequests.post('/classes/$id/changes/200', {'data': body}, null)
        .then((response) => true);
  }

  Future<bool> submitGradeScaleChangeRequest(Map data) {
    return SKRequests.post('/classes/$id/changes/100', {'data': data}, null)
        .then((response) => response.wasSuccessful());
  }

  //--------------//
  //Static Members//
  //--------------//

  static bool classesLoaded = false;
  static Map<int, StudentClass> currentClasses = {};

  static StudentClass? _fromJsonObj(Map content) {
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
    final startTime = (startString == null ||
            startString == 'online' ||
            startComponents!.length < 2)
        ? null
        : TimeOfDay(hour: startComponents[0], minute: startComponents[1]);

    StudentClass studentClass = StudentClass(
      content['id'],
      content['name'],
      JsonListMaker.convert(
        (content) => Assignment._fromJsonObj(content, shouldPersist: true),
        content['assignments'] ?? [],
      ) as List<Assignment>,
      content['color'],
      content['grade'],
      content['completion'],
      content['enrollment'],
      JsonListMaker.convert(
        Weight._fromJsonObj,
        content['weights'] ?? [],
      ) as List<Weight>,
      content['meet_days'],
      startTime,
      Status._fromJsonObj(content['status'])!,
      content['subject'],
      content['code'],
      content['section'],
      Professor._fromJsonObj(content['professor']) ??
          Professor.blankProfessor(),
      Period._fromJsonObj(content['class_period'])!,
      JsonListMaker.convert(
        PublicStudent._fromJsonObj,
        content['students'] ?? [],
      ) as List<PublicStudent>,
      content['enrollment_link'],
      content['grade_scale'],
      content['is_points'],
      content['is_notifications'],
      JsonListMaker.convert(
        ClassDocument._fromJsonObj,
        content['documents'] ?? [],
      ) as List<ClassDocument>,
      startString == 'online',
      JsonListMaker.convert(
              ChangeRequest._fromJsonObj, content['change_requests'] ?? [])
          as List<ChangeRequest>,
    );

    StudentClass.currentClasses[studentClass.id] = studentClass;

    return studentClass
      ..assignments?.forEach((a) => a.configureDateTimeOffset());
  }

  static Future<RequestResponse> getStudentClasses() {
    return SKRequests.get(
      '/students/${SKUser.current?.student.id}/classes',
      _fromJsonObj,
      cacheResult: true,
      cachePath: 'student_classes.json',
      postRequestAction: () {
        classesLoaded = true;
        StudentClass.currentClasses = {};
        Assignment.currentAssignments = {};
      },
    );
  }

  static Future<RequestResponse> getStudentClassById(int id) {
    return SKRequests.get(
      '/students/${SKUser.current?.student.id}/classes/${id}',
      _fromJsonObj,
      postRequestAction: () =>
          Assignment.currentAssignments.removeWhere((_, a) => a.classId == id),
    );
  }

  static bool get liveClassesAvailable =>
      currentClasses.values.toList().any((studentClass) => [
            ClassStatuses.class_setup,
            ClassStatuses.class_issue
          ].contains(studentClass.status.id));
}

class SchoolClass {
  int id;
  int? enrollment;

  String name;
  String? meetDays;
  String? subject;
  String? code;
  String? section;

  TimeOfDay? meetTime;

  Professor? professor;
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

  static SchoolClass? _fromJsonObj(Map content) {
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
    final startTime = (startString == null || startComponents!.length < 2)
        ? null
        : TimeOfDay(hour: startComponents[0], minute: startComponents[1]);

    SchoolClass schoolClass = SchoolClass(
      content['id'],
      content['name'],
      content['enrollment'],
      content['meet_days'],
      startTime!,
      content['subject'],
      content['code'],
      content['section'],
      Professor._fromJsonObj(content['professor']) ??
          Professor.blankProfessor(),
      Period._fromJsonObj(content['class_period'])!,
    );

    return schoolClass;
  }

  Future<RequestResponse> enrollInClass() async {
    final RequestResponse<StudentClass> response = await SKRequests.post(
      '/students/${SKUser.current?.student.id}/classes/$id',
      null,
      StudentClass._fromJsonObj,
    ) as RequestResponse<StudentClass>;

    if (response.wasSuccessful() && response.obj._color == null) {
      response.obj.initializeColor();
    }
    return response;
  }

  static Future<http.Response>? _activeClassSearch = null;

  static void invalidateCurrentClassSearch() {
    _activeClassSearch?.timeout(Duration.zero);
  }

  static Future<RequestResponse> searchSchoolClasses(
    String searchText,
    Period period,
  ) async {
    if (_activeClassSearch != null) {
      _activeClassSearch!.timeout(Duration.zero);
      _activeClassSearch = null;
    }

    _activeClassSearch = SKRequests.rawGetRequest(
        '/periods/${period.id}/classes?class_name=$searchText');

    final request = await _activeClassSearch;

    return SKRequests.futureProcessor(request!, _fromJsonObj);
  }
}

class Weight {
  int id;
  double weight;
  String name;

  Weight(this.id, this.weight, this.name);

  static Map<int, Weight> currentWeights = {};

  static Weight? _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    final weight = Weight(
      content['id'],
      content['weight'],
      content['name'],
    );

    currentWeights[weight.id] = weight;
    return weight;
  }
}

class Status {
  int? id;
  String name;

  Status(this.id, this.name);

  static Status? _fromJsonObj(Map content) {
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
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? availability;
  String? officeLocation;

  String? get fullName {
    return (firstName ?? '') +
        (firstName == null || lastName == null ? '' : ' ') +
        (lastName ?? '');
  }

  Professor(
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.availability,
    this.officeLocation,
  );

  Future<bool> updateInfo(
    String email,
    String phoneNumber,
    String availability,
    String officeLocation,
  ) {
    final Map<String, String> body = {
      'email': email,
      'phone': phoneNumber,
      'office_location': officeLocation,
      'office_availability': availability,
    };

    body.removeWhere((_, v) => v == null);
    if (body.length == 0) return Future.value(true);

    return SKRequests.put('/professors/$id', body, Professor._fromJsonObj)
        .then((response) {
      print(response);
      return response.wasSuccessful();
    });
  }

  static Professor? _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    return Professor(
      content['id'],
      content['name_first'],
      content['name_last'],
      content['email'],
      content['phone'],
      content['office_availability'],
      content['office_location'],
    );
  }

  static Professor blankProfessor() {
    return Professor(0, '-', '-', '-', '-', '-', '-');
  }
}

class ClassDocument {
  final String name;
  final String path;

  ClassDocument(this.name, this.path);

  static ClassDocument _fromJsonObj(Map content) => ClassDocument(
        content['name'],
        content['path'],
      );
}

class ChangeRequest {
  final int id;
  final List<ChangeRequestMember> members;
  final TypeObject changeType;
  final DateTime insertedAt;

  ChangeRequest(this.id, this.members, this.changeType, this.insertedAt);

  static ChangeRequest _fromJsonObj(Map content) => ChangeRequest(
        content['id'],
        JsonListMaker.convert(
                ChangeRequestMember._fromJsonObj, content['members'] ?? [])
            as List<ChangeRequestMember>,
        TypeObject._fromJsonObj(content['change_type']),
        _dateParser(content['inserted_at'])!,
      );
}

class ChangeRequestMember {
  final bool isCompleted;
  final String name;
  final String value;

  ChangeRequestMember(this.isCompleted, this.name, this.value);

  static ChangeRequestMember _fromJsonObj(Map content) => ChangeRequestMember(
      content['is_completed'], content['member_name'], content['member_value']);
}
