library requests_core;

import 'package:skoller/constants/constants.dart';
import 'package:time_machine/time_machine.dart';
import '../constants/timezone_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
    if (context != null && status == 200 && constructor != null) {
      if (context is List) {
        this.obj = JsonListMaker.convert<T>(constructor, context);
      } else {
        this.obj = constructor(context);
      }
    } else {
      this.obj = null;
    }

    this.status = status;
  }

  RequestResponse._fromError(this._errorMsg);

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
  static final String _environment = 'http://127.0.0.1:4000'; //LOCAL
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
    var content = statusCode == 200 && request.body != null ? json.decode(request.body) : null;
    return RequestResponse<T>(
      statusCode,
      content,
      constructor: constructor,
    );
  }
}

class Auth {
  static SKUser user;

  static SKUser _fromJson(Map context) {
    user = SKUser._fromJson(context['user']);
    SKRequests._headers['Authorization'] = 'Bearer ' + context['token'];
    return user;
  }

  static Future<bool> logIn(String username, String password) {
    return SKRequests.post(
      '/users/login',
      {"email": username, "password": password},
      _fromJson,
    ).then((onValue) {
      return onValue.wasSuccessful();
    });
  }
}
