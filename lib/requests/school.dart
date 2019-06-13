part of 'requests_core.dart';

class School {
  int id;
  List<Period> periods;
  String timezone;
  String name;

  School(this.id, this.timezone, this.periods, this.name);

  static Map<int, School> currentSchools = {};

  static School _fromJsonObject(Map content) {
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

    return School(
      content['id'],
      content['timezone'],
      period_list,
      content['name'],
    );
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
