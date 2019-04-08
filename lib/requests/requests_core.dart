library requests_core;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

part 'user.dart';
part 'student_class.dart';
part 'assignment.dart';

class RequestResponse<T> {
  int status;
  dynamic obj;
  String _errorMsg;

  RequestResponse(
    int status,
    dynamic context, {
    _DecodableConstructor constructor,
  }) {
    if (context != null && status == 200) {
      if (context is List) {
        this.obj = JsonListMaker.convert(constructor, context);
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

typedef dynamic _DecodableConstructor<T>(Map content);
// typedef List _ListDecodableConstructor(List content);
// typedef T _ListConstructor<T>(Map content);

class JsonListMaker {
  static List<T> convert<T>(_DecodableConstructor<T> maker, List content) {
    return content.map((obj) => maker(obj)).toList();
  }
}

class SKRequests {
  // static final String _environment = 'http://127.0.0.1:4000'; //LOCAL
  static final String _environment = 'https://api-staging.skoller.co'; //STAGING
  // static final String _environment = 'https://api.skoller.co'; //PRODUCTION
  static final String _baseUrl = '$_environment/api/v1';

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<RequestResponse> get(
    String url,
    _DecodableConstructor construct,
  ) async {
    // Construct and start request
    http.Response request = await http.get(
      _baseUrl + url,
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, construct);
  }

  static Future<RequestResponse> post(
    String url,
    Map body,
    _DecodableConstructor constructor,
  ) async {
    // Construct and start request
    http.Response request = await http.post(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, constructor);
  }

  static Future<RequestResponse> put(
    String url,
    Map body,
    _DecodableConstructor constructor,
  ) async {
    // Construct and start request
    http.Response request = await http.put(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, constructor);
  }

  static RequestResponse futureProcessor(
    http.Response request,
    _DecodableConstructor constructor,
  ) {
    int statusCode = request.statusCode;
    var content = statusCode == 200 ? json.decode(request.body) : null;
    return RequestResponse(
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
