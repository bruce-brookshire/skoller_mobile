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

  Future<bool> delete() {
    return SKRequests.delete('/users/$id', null)
        .then((response) => [200, 204].contains(response));
  }

  Future<bool> update({
    String firstName,
    String lastName,
    String bio,
    String organizations,
    DateTime notificationTime,
    DateTime futureNotificationTime,
    int notificationDays,
    bool isAssignmentPostNotifications,
  }) {
    Map<String, dynamic> params = {'id': this.student.id};

    if (firstName != null && firstName != this.student.nameFirst)
      params['name_first'] = firstName;

    if (lastName != null && lastName != this.student.nameLast)
      params['name_last'] = lastName;

    if (bio != null && bio != this.student.bio) params['bio'] = bio;

    if (organizations != null && organizations != this.student.organizations)
      params['organization'] = organizations;

    if (notificationTime != null) {
      final formattedNotificationTime =
          DateFormat('HH:mm:ss').format(notificationTime);
      params['notification_time'] = formattedNotificationTime;
    }

    if (futureNotificationTime != null) {
      final formattedFutureNotificationTime =
          DateFormat('HH:mm:ss').format(futureNotificationTime);
      params['future_reminder_notification_time'] =
          formattedFutureNotificationTime;
    }

    if (notificationDays != null &&
        notificationDays != this.student.notificationDays)
      params['notification_days_notice'] = notificationDays;

    if (isAssignmentPostNotifications != null &&
        isAssignmentPostNotifications != this.student.isAssignPostNotifications)
      params['is_assign_post_notifications'] = isAssignmentPostNotifications;

    if (params.length == 1) {
      return Future.value(true);
    }

    return SKRequests.put('/users/$id', {'student': params}, null)
        .then((response) {
      if (response.wasSuccessful()) {
        return Auth.logIn('bruce@skoller.co', 'password1');
      } else {
        return false;
      }
    });
  }
}

class Student {
  int id;
  int points;
  int notificationDays;
  bool isAssignPostNotifications;

  bool isVerified;

  String nameFirst;
  String nameLast;
  String phone;
  String primaryOrganization;
  String gradYear;
  String bio;
  String organizations;
  String enrollmentLink;

  List<School> schools;

  School primarySchool;

  TimeOfDay notificationTime;
  TimeOfDay futureNotificationTime;

  String get formattedPhone {
    if (phone != null && phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6, 10)}';
    } else {
      return phone;
    }
  }

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
    bio = content['bio'];
    organizations = content['organization'];
    enrollmentLink = content['enrollment_link'];
    primarySchool = content['primary_school'] != null
        ? School._fromJsonObject(content['primary_school'])
        : null;

    List tempTime = content['notification_time']
        ?.split(':')
        ?.map((item) => int.parse(item))
        ?.toList();

    notificationTime = tempTime != null
        ? TimeOfDay(hour: tempTime[0], minute: tempTime[1])
        : null;

    tempTime = content['future_reminder_notification_time']
        ?.split(':')
        ?.map((item) => int.parse(item))
        ?.toList();

    futureNotificationTime = tempTime != null
        ? TimeOfDay(hour: tempTime[0], minute: tempTime[1])
        : null;

    notificationDays = content['notification_days_notice'];
    isAssignPostNotifications = content['is_assign_post_notifications'];
  }
}

class PublicStudent {
  int id;
  int points;

  String name_first;
  String name_last;
  String org;
  String bio;

  PublicUser user;

  PublicStudent(
    this.id,
    this.name_first,
    this.name_last,
    this.user,
    this.points,
    this.org,
    this.bio,
  );

  static PublicStudent _fromJsonObj(Map content) {
    return PublicStudent(
      content['id'],
      content['name_first'],
      content['name_last'],
      PublicUser._fromJsonObj(content['user']),
      content['points'],
      content['organization'],
      content['bio'],
    );
  }
}

class PublicUser {
  int id;
  String email;
  String avatar;

  PublicUser(
    this.id,
    this.email,
    this.avatar,
  );

  static PublicUser _fromJsonObj(Map content) {
    return PublicUser(
      content['id'],
      content['email'],
      content['avatar'],
    );
  }
}
