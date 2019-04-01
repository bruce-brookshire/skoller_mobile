library requests_core;

import 'package:http/http.dart' as http;
import 'dart:convert';

part 'user.dart';
part 'student_class.dart';
part 'assignment.dart';

class RequestResponse {
  int status;
  dynamic obj;
  String _errorMsg;

  RequestResponse(
    int status,
    dynamic context, {
    _DecodableConstructor jsonConstruct,
    _ListDecodableConstructor listConstruct,
  }) {
    if (context != null && status == 200) {
      if (context is List) {
        this.obj = listConstruct(context);
      } else {
        this.obj = jsonConstruct(context);
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

typedef dynamic _DecodableConstructor(Map content);
typedef List _ListDecodableConstructor(List content);
typedef T _ListConstructor<T>(Map content);

class JsonListMaker {
  static List<T> convert<T>(_ListConstructor<T> maker, List content) {
    return content.map((obj) => maker(obj)).toList(); 
  }
}

class SKRequests {
  static final String _environment = 'http://127.0.0.1:4000'; //LOCAL
  // static final String environment = 'https://api-staging.skoller.co'; //STAGING
  // static final String environment = 'https://api.skoller.co'; //PRODUCTION
  static final String _baseUrl = '$_environment/api/v1';

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<RequestResponse> get(
    String url, {
    _DecodableConstructor jsonConstruct,
    _ListDecodableConstructor listConstruct,
  }) {
    // Construct and start request
    Future<http.Response> request = http.get(
      _baseUrl + url,
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, jsonConstruct, listConstruct);
  }

  static Future<RequestResponse> post(
    String url,
    Map body, {
    _DecodableConstructor jsonConstruct,
    _ListDecodableConstructor listConstruct,
  }) {
    // Construct and start request
    Future<http.Response> request = http.post(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, jsonConstruct, listConstruct);
  }

  static Future<RequestResponse> put(
    String url,
    Map body, {
    _DecodableConstructor jsonConstruct,
    _ListDecodableConstructor listConstruct,
  }) {
    // Construct and start request
    Future<http.Response> request = http.put(
      _baseUrl + url,
      body: json.encode(body),
      headers: _headers,
    );

    // Handle request and return future
    return futureProcessor(request, jsonConstruct, listConstruct);
  }

  static Future<RequestResponse> futureProcessor(
    Future<http.Response> request,
    _DecodableConstructor jsonConstruct,
    _ListDecodableConstructor listConstruct,
  ) {
    return request.then(
      (response) {
        int statusCode = response.statusCode;
        var content = statusCode == 200 ? json.decode(response.body) : null;
        return RequestResponse(
          statusCode,
          content,
          jsonConstruct: jsonConstruct,
          listConstruct: listConstruct,
        );
      },
    ).catchError((onError) {
      return RequestResponse._fromError(onError.message);
    });
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
      jsonConstruct: _fromJson,
    ).then((onValue) {
      return onValue.wasSuccessful();
    });
  }
}
