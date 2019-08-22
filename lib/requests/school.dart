part of 'requests_core.dart';

class School {
  int id;
  List<Period> periods;
  String timezone;
  String name;
  String adrRegion;
  String adrLocality;
  Color color;

  School(
    this.id,
    this.timezone,
    this.periods,
    this.name,
    this.adrRegion,
    this.adrLocality,
    this.color,
  );

  Future<http.Response> _activeProfessorSearch;

  void invalidateCurrentProfessorSearch() {
    _activeProfessorSearch?.timeout(Duration.zero);
  }

  Future<RequestResponse> searchProfessors(String searchText) async {
    if (_activeProfessorSearch != null) {
      _activeProfessorSearch.timeout(Duration.zero);
      _activeProfessorSearch = null;
    }

    _activeProfessorSearch = SKRequests.rawGetRequest(
        '/schools/$id/professors?professor_name=$searchText');

    final request = await _activeProfessorSearch;

    return SKRequests.futureProcessor(request, Professor._fromJsonObj);
  }

  Future<RequestResponse> createProfessor({
    String nameFirst,
    String nameLast,
  }) {
    return SKRequests.post(
        '/schools/$id/professors',
        {'name_first': nameFirst, 'name_last': nameLast},
        Professor._fromJsonObj);
  }

  static Map<int, School> currentSchools = {};

  static School _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    List<Period> period_list = JsonListMaker.convert(
      Period._fromJsonObj,
      content['periods'] ?? [],
    );
    Period.currentPeriods = {};

    for (final period in period_list) {
      Period.currentPeriods[period.id] = period;
    }

    String color = content['color'];

    if (color != null) {
      color = 'ff' + color.substring(1);
    }

    return School(
      content['id'],
      content['timezone'],
      period_list,
      content['name'],
      content['adr_region'],
      content['adr_locality'],
      color != null ? Color(int.parse(color, radix: 16) ?? 0xFF4A4A4A) : null,
    );
  }

  Period getBestCurrentPeriod() {
    final today = DateTime.now();

    List<Period> periods = (SKUser.current.student.primarySchool?.periods ?? [])
      ..sort(
        (p1, p2) {
          if (p1.startDate == null && p2.startDate == null) {
            return p1.name.compareTo(p2.name);
          } else if (p1.startDate == null) {
            return 1;
          } else if (p2.startDate == null) {
            return -1;
          } else {
            return p1.startDate.compareTo(p2.startDate);
          }
        },
      )
      ..removeWhere((period) => (period.endDate ?? today).isBefore(today));

    final findSemester = (int status) {
      for (final Period period in periods) {
        if (period.periodStatusId == status && period.isMainPeriod) {
          return period;
        }
      }
      return null;
    };

    Period activePeriod = findSemester(200);

    if (activePeriod == null) {
      activePeriod = findSemester(400);
    }

    return activePeriod;
  }

  static Future<RequestResponse> createSchool({
    @required bool isUniversity,
    @required String schoolName,
    @required String cityName,
    @required String stateAbv,
  }) {
    return SKRequests.post(
        '/schools/',
        {
          'is_university': isUniversity,
          'name': schoolName,
          'adr_locality': cityName,
          'adr_region': stateAbv,
          'adr_country': 'us'
        },
        School._fromJsonObj);
  }

  static Future<http.Response> _activeSchoolSearch;

  static void invalidateCurrentSchoolSearch() {
    _activeSchoolSearch?.timeout(Duration.zero);
  }

  static Future<RequestResponse> searchSchools(String searchText) async {
    if (_activeSchoolSearch != null) {
      _activeSchoolSearch.timeout(Duration.zero);
      _activeSchoolSearch = null;
    }

    _activeSchoolSearch =
        SKRequests.rawGetRequest('/school/list?name=$searchText');

    final request = await _activeSchoolSearch;

    return SKRequests.futureProcessor(request, _fromJsonObj);
  }
}

class Period {
  int id;
  int schoolId;
  int periodStatusId;

  bool isMainPeriod;

  String name;
  DateTime startDate;
  DateTime endDate;

  Period(
    this.id,
    this.schoolId,
    this.name,
    this.startDate,
    this.endDate,
    this.isMainPeriod,
    this.periodStatusId,
  );

  School getSchool() => School.currentSchools[schoolId];

  Future<RequestResponse> createClass({
    @required String className,
    @required String subject,
    @required String code,
    @required String section,
    @required int professorId,
    bool isOnline,
    String meetDays,
    TimeOfDay meetTime,
  }) {
    Map body = {
      "name": className,
      "professor_id": professorId,
      "subject": subject,
      "section": section,
      "code": code,
      "created_on": "mobile"
    };

    if (isOnline) {
      body['meet_days'] = 'online';
    } else {
      body['meet_days'] = meetDays;
      body['meet_start_time'] =
          '${meetTime.hour < 10 ? '0' : ''}${meetTime.hour}:${meetTime.minute < 10 ? '0' : ''}${meetTime.minute}:00';
    }

    return SKRequests.post(
        '/periods/$id/classes/', body, SchoolClass._fromJsonObj);
  }

  static Map<int, Period> currentPeriods = {};

  static Period _fromJsonObj(Map content) {
    if (content == null) {
      return null;
    }

    return Period(
      content['id'],
      content['school_id'],
      content['name'],
      content['start_date'] != null
          ? DateTime.parse(content['start_date'])
          : null,
      content['end_date'] != null ? DateTime.parse(content['end_date']) : null,
      content['is_main_period'] ?? false,
      content['class_period_status']['id'],
    );
  }
}
