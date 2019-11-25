part of 'requests_core.dart';

class SKUser {
  static SKUser current;

  int id;
  String email;
  String avatarUrl;
  Student student;

  SKUser(this.id, this.email, this.avatarUrl, this.student);

  static SKUser _fromJson(Map content) {
    SKUser.current = SKUser(
      content['id'],
      content['email'],
      content['avatar'],
      Student._fromJson(content['student']),
    );

    return SKUser.current;
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
    School primarySchool,
    Period primaryPeriod,
    List<int> fieldsOfStudy,
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
          DateFormat('HH:mm:ss').format(notificationTime.toUtc());
      params['notification_time'] = formattedNotificationTime;
    }

    if (futureNotificationTime != null) {
      final formattedFutureNotificationTime =
          DateFormat('HH:mm:ss').format(futureNotificationTime.toUtc());
      params['future_reminder_notification_time'] =
          formattedFutureNotificationTime;
    }

    if (notificationDays != null &&
        notificationDays != this.student.notificationDays)
      params['notification_days_notice'] = notificationDays;

    if (isAssignmentPostNotifications != null &&
        isAssignmentPostNotifications != this.student.isAssignPostNotifications)
      params['is_assign_post_notifications'] = isAssignmentPostNotifications;

    if (primarySchool != null &&
        primarySchool.id != this.student.primarySchool?.id)
      params['primary_school_id'] = primarySchool.id;

    if (primaryPeriod != null &&
        primaryPeriod.id != this.student.primaryPeriod?.id)
      params['primary_period_id'] = primaryPeriod.id;

    if (params['primary_period_id'] == null && params['primary_school_id'] != null)
      params['primary_period_id'] = primarySchool.periods?.first?.id;

    if (fieldsOfStudy != null) params['fields_of_study'] = fieldsOfStudy;

    if (params.length == 1) {
      return Future.value(true);
    }

    return SKRequests.put('/users/$id', {'student': params}, null)
        .then((response) {
      if (response.wasSuccessful()) {
        return Auth.tokenLogin();
      } else {
        return false;
      }
    });
  }

  Future<int> uploadProfilePhoto(String path) async {
    final uri = Uri.parse(SKRequests._baseUrl + '/users/$id');
    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = SKRequests._headers['Authorization'];

    request.files.add(await http.MultipartFile.fromPath(
      '${id}_profilephoto.jpg',
      path,
      contentType: MediaType('image', 'jpeg'),
    ));
    return (await request.send()).statusCode;
  }

  Future<RequestResponse> checkEmailDomain() {
    final emailDomain = email.split('@')[1];
    return SKRequests.get(
        '/email_domains/$emailDomain/check', School._fromJsonObj);
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
  List<FieldsOfStudy> fieldsOfStudy;

  School primarySchool;
  Period primaryPeriod;

  DateTime notificationTime;
  DateTime futureNotificationTime;

  String get formattedPhone {
    if (phone != null && phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6, 10)}';
    } else {
      return phone;
    }
  }

  Student._fromJson(Map content) {
    schools =
        JsonListMaker.convert(School._fromJsonObj, content['schools'] ?? []) ??
            [];
    School.currentSchools = {};

    for (final school in schools) {
      School.currentSchools[school.id] = school;
    }

    primarySchool = content['primary_school'] == null
        ? null
        : School._fromJsonObj(
            content['primary_school'],
          );

    if (primarySchool != null) {
      School.currentSchools[primarySchool.id] = primarySchool;
    }

    id = content['id'];
    nameFirst = content['name_first'];
    nameLast = content['name_last'];
    phone = content['phone'];
    primaryOrganization = content['primary_organization'];
    isVerified = content['is_verified'];
    points = content['points'];
    gradYear = content['grad_year'];
    bio = content['bio'];
    organizations = content['organization'];
    enrollmentLink = content['enrollment_link'];

    primarySchool = content['primary_school'] != null
        ? School._fromJsonObj(content['primary_school'])
        : null;

    primaryPeriod = content['primary_period'] != null
        ? Period._fromJsonObj(content['primary_period'])
        : null;

    final utcNow = DateTime.now().toUtc();

    List listTime = content['notification_time']
        ?.split(':')
        ?.map((item) => int.parse(item))
        ?.toList();

    notificationTime = listTime != null
        ? DateTime.utc(
            utcNow.year,
            utcNow.month,
            utcNow.day,
            listTime[0],
            listTime[1],
          ).toLocal()
        : null;

    listTime = content['future_reminder_notification_time']
        ?.split(':')
        ?.map((item) => int.parse(item))
        ?.toList();

    futureNotificationTime = listTime != null
        ? DateTime.utc(
            utcNow.year,
            utcNow.month,
            utcNow.day,
            listTime[0],
            listTime[1],
          ).toLocal()
        : null;

    notificationDays = content['notification_days_notice'];
    isAssignPostNotifications = content['is_assign_post_notifications'];

    fieldsOfStudy = JsonListMaker.convert(
      FieldsOfStudy._fromJsonObj,
      content['fields_of_study'],
    );
  }
}

class FieldsOfStudy {
  final int id;
  final String field;

  FieldsOfStudy(this.id, this.field);

  int get hashCode => id;

  static FieldsOfStudy _fromJsonObj(Map content) => FieldsOfStudy(
        content['id'],
        content['field'],
      );

  static Future<RequestResponse> getFieldsOfStudy() {
    return SKRequests.get('/fields-of-study/list', _fromJsonObj);
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
