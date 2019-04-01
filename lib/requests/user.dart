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

  Student._fromJson(Map content) {
    id = content['id'];
    nameFirst = content['name_first'];
    nameLast = content['name_last'];
    phone = content['phone'];
    primaryOrganization = content['primary_organization'];
    isVerified = content['is_verified'];
    points = content['points'];
    gradYear = content['grad_year'];
  }
}
