part of 'requests_core.dart';

class SKUser {
  static SKUser current;

  int id;
  String email;
  String avatarUrl;
  Student student;

  SKUser._fromJson(Map content) {
    id = content['id'];
    student = Student._fromJson(content['student']);
    email = content['email'];
    avatarUrl = content['avatar'];

    SKUser.current = this;
  }
}

class Student {
  int id;
  String nameFirst;
  String nameLast;
  String phone;
  String primaryOrganization;
  bool isVerified;
  int points;
  String gradYear;
  List<School> schools;

  Student._fromJson(Map content) {
    final school_list =
        JsonListMaker.convert(School._fromJsonObject, content['schools']) ?? [];
    School.currentSchools = {};

    for (final school in school_list) {
      School.currentSchools[school.id] = school;
    }

    id = content['id'];
    nameFirst = content['name_first'];
    nameLast = content['name_last'];
    phone = content['phone'];
    primaryOrganization = content['primary_organization'];
    isVerified = content['is_verified'];
    points = content['points'];
    gradYear = content['grad_year'];
    schools = school_list;
  }
}
