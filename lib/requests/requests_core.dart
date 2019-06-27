library requests_core;

import 'package:intl/intl.dart';
import 'package:time_machine/time_machine.dart';
import '../constants/timezone_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

part 'student_class.dart';
part 'assignment.dart';
part 'school.dart';
part 'chat.dart';
part 'user.dart';
part 'mod.dart';

class RequestResponse<T> {
  int status;
  dynamic obj;
  String _errorMsg;

  RequestResponse(
    int status,
    dynamic context, {
    _DecodableConstructor<T> constructor,
  }) {
    if (status == 200 || status == 204) {
      if (constructor != null && context != null) {
        if (context is List) {
          this.obj = JsonListMaker.convert<T>(constructor, context);
        } else {
          this.obj = constructor(context);
        }
      }
    } else {
      this.obj = context;
    }

    this.status = status;
  }

  RequestResponse._fromError(this._errorMsg, this.status);

  bool wasSuccessful() {
    return [200, 204].contains(status) && _errorMsg == null;
  }
}

typedef T _DecodableConstructor<T>(Map content);

class JsonListMaker {
  static List convert<T>(_DecodableConstructor<T> maker, List content) {
    return content.map<T>((obj) => maker(obj)).toList();
  }
}

class SKRequests {
  static final String _environment = 'http://10.1.10.122:4000'; //LOCAL
  // static final String _environment = 'https://api-staging.skoller.co'; //STAGING
  // static final String _environment = 'https://api.skoller.co'; //PRODUCTION
  static final String _baseUrl = '$_environment/api/v1';

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<RequestResponse> get<T>(
    String url,
    _DecodableConstructor<T> construct,
  ) async {
    // Construct and start request
    http.Response request = await http.get(
      _baseUrl + url,
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor<T>(request, construct);
  }

  static Future<http.Response> rawGetRequest<T>(String url) {
    // Construct and start request
    return http.get(
      _baseUrl + url,
      headers: _headers,
    );
  }

  static Future<RequestResponse> post<T>(
    String url,
    Map body,
    _DecodableConstructor<T> constructor,
  ) async {
    // Construct and start request
    http.Response request = await http.post(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor<T>(request, constructor);
  }

  static Future<RequestResponse> put<T>(
    String url,
    Map body,
    _DecodableConstructor<T> constructor,
  ) async {
    // Construct and start request
    http.Response request = await http.put(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor<T>(request, constructor);
  }

  static Future<int> delete(
    String url,
    Map body,
  ) async {
    // Construct and start request
    http.Response request = await http.delete(
      _baseUrl + url,
      headers: _headers,
    );

    // Handle request and return future
    return request.statusCode;
  }

  static RequestResponse futureProcessor<T>(
    http.Response request,
    _DecodableConstructor<T> constructor,
  ) {
    int statusCode = request.statusCode;
    var content;
    try {
      content = request.body != null ? json.decode(request.body) : null;
    } catch (e) {
      content = request.body;
    }

    return RequestResponse<T>(
      statusCode,
      content,
      constructor: constructor,
    );
  }
}

enum LogInResponse { success, needsVerification, failed, internetError }

class Auth {
  // static SKUser user;

  static final _kSharedToken = 'STUDENT_TOKEN';
  static final _kStudentPhone = 'STUDENT_PHONE';

  static String userPhone;

  static SKUser _fromJsonAuth(Map context) {
    final user = SKUser._fromJson(context['user']);

    String token = context['token'];
    SharedPreferences.getInstance()
        .then((inst) => inst.setString(_kSharedToken, token));
    SKRequests._headers['Authorization'] = 'Bearer $token';

    return user;
  }

  static SKUser _fromJsonNoAuth(Map context) {
    return SKUser._fromJson(context['user']);
  }

  static Future<LogInResponse> attemptLogin() async {
    final inst = await SharedPreferences.getInstance();
    final token = inst.getString(_kSharedToken);
    userPhone = inst.getString(_kStudentPhone);

    if (token != null) {
      SKRequests._headers['Authorization'] = 'Bearer $token';

      //Check if we can use the previously stored token
      final validToken = await tokenLogin();

      //If token login didnt work, we need to remove the bad token
      if (!validToken) SKRequests._headers.remove('Authorization');

      //Token is valid
      if (validToken)
        return LogInResponse.success;
      //Token is invalid, do we have the phone number?
      else if (userPhone != null) {
        //We do. Request the user to sign in again
        final successfullyRequested = await requestLogin(userPhone);
        //Did the request complete correctly?
        if (successfullyRequested)
          return LogInResponse.needsVerification;
        //Request failed, just have the user sign in again
        else
          return LogInResponse.internetError;
      }
      //We have no valid token nor phone number. Have the user sign in again
      else
        return LogInResponse.failed;
    }
    //We have no token, so
    else
      return LogInResponse.failed;
  }

  static Future<bool> requestLogin(String phone) {
    return SKRequests.post(
      '/students/login',
      {"phone": phone},
      null,
    ).then((onValue) {
      return onValue.wasSuccessful();
    });
  }

  static Future<RequestResponse> logIn(String phone, String code) {
    return SKRequests.post(
      '/students/login',
      {"phone": phone, "verification_code": code},
      _fromJsonAuth,
    ).then((response) {
      if (response.wasSuccessful()) {
        SharedPreferences.getInstance()
            .then((inst) => inst.setString(_kStudentPhone, phone));

        userPhone = phone;
      }
      return response;
    });
  }

  static Future<bool> tokenLogin() {
    return SKRequests.post(
      '/users/token-login',
      null,
      _fromJsonNoAuth,
    ).then((onValue) => onValue.wasSuccessful());
  }

  static Future<bool> logOut() async {
    final inst = await SharedPreferences.getInstance();
    inst.clear();
    SKRequests._headers.remove('Authorization');

    Assignment.currentAssignments = {};
    Assignment.currentTasks = [];
    StudentClass.currentClasses = {};
    Chat.currentChats = {};
    InboxNotification.currentInbox = [];
    Mod.currentMods = {};
    School.currentSchools = {};
    Period.currentPeriods = {};
    SKUser.current = null;

    return true;
  }

  static Future<RequestResponse> createUser({
    @required String nameFirst,
    @required String nameLast,
    @required String email,
    @required String phone,
  }) {
    final offset = DateTime.now().timeZoneOffset.inHours;
    final utc_hour = 9 - offset;

    String notificationTime;

    if (utc_hour >= 10)
      notificationTime = '$utc_hour:00:00.000';
    else
      notificationTime = '0$utc_hour:00:00.000';

    print(notificationTime);

    return SKRequests.post(
        '/users',
        {
          'email': email,
          'student': {
            'name_first': nameFirst,
            'name_last': nameLast,
            'phone': phone,
            'notification_time': notificationTime,
            'future_reminder_notification_time': notificationTime,
          },
        },
        SKUser._fromJson);
  }
}
