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
  String name;
  String startDate;
  String endDate;

  Period(this.id, this.schoolId, this.name, this.startDate, this.endDate);

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
      content['start_date'],
      content['end_date'],
    );
  }
}
