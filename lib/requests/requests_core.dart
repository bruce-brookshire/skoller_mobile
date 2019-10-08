library requests_core;

import 'package:skoller/screens/main_app/classes/modals/class_link_sharing_modal.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:skoller/screens/main_app/menu/my_points_view.dart';
import 'package:time_machine/time_machine.dart' as time_machine;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_apns/apns_connector.dart';
import 'package:package_info/package_info.dart';
import '../constants/timezone_manager.dart';
import 'package:flutter_apns/apns.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';

part 'student_class.dart';
part 'assignment.dart';
part 'school.dart';
part 'chat.dart';
part 'user.dart';
part 'mod.dart';
part 'auth.dart';

const bool isProd = false;
const bool isLocal = false;

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
        } else if (context is Map) {
          this.obj = constructor(context);
        } else {
          this.obj = context;
        }
      } else {
        this.obj = context;
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
  static const String _environment = isProd
      ? 'https://api.skoller.co'
      : (isLocal
          ? 'http://10.1.10.107:4000'
          : 'https://api-staging.skoller.co');

  static final String _baseUrl = '$_environment/api/v1';

  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Map<String, Future<http.Response>> _currentRequests = {};

  static Future<RequestResponse> get<T>(
    String url,
    _DecodableConstructor<T> construct, {
    bool cacheResult = false,
    String cachePath,
    VoidCallback postRequestAction,
  }) async {
    //Whether or not we need to remove the request entry in the request map
    bool shouldRemove = false;

    //If there is not currently an active request for this URL we need to create it
    if (_currentRequests[url] == null) {
      //Take ownership for the request
      shouldRemove = true;
      //Create request
      _currentRequests[url] = http.get(
        _baseUrl + url,
        headers: _headers,
      );
    }
    //Construct and start request
    http.Response request = await _currentRequests[url];

    //Remove request entry if we have ownership
    if (shouldRemove) {
      _currentRequests.remove(url);
      if (postRequestAction != null && [200, 204].contains(request.statusCode))
        postRequestAction();
    }

    //Handle request and return future
    final result = await futureProcessor<T>(request, construct);

    //Cache result if we are supposed to
    if (cacheResult && result.wasSuccessful())
      SKCacheManager.writeContents(cachePath, request.body);

    //Return result
    return result;
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

class SKCacheManager {
  static Future<void> classesLoader;

  static Future<String> get _homePath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  static Future<File> _fileAtPath(String subPath) =>
      _homePath.then((path) => File('$path/data/$subPath'));

  static Future<String> getContents(String subPath) async {
    final file = await _fileAtPath(subPath);

    return file.readAsString();
  }

  static void createCacheDir() async {
    final path = await _homePath;
    final directory = Directory('$path/data');

    final exists = await directory.exists();

    if (!exists) {
      await directory.create(recursive: true);
    }
  }

  static void writeContents(String subPath, String contents) async {
    final file = await _fileAtPath(subPath);

    file.writeAsString(contents);
  }

  static Future<bool> deleteCache() async {
    return _homePath
        .then((path) => Directory('$path/data').delete(recursive: true))
        .then((_) => true)
        .catchError((_) => false);
  }

  static void restoreCachedData() {
    //Load classes
    classesLoader = getContents('student_classes.json')
        .then(
          (contents) {
            if (StudentClass.currentClasses.length != 0) {
              throw 'Already loaded from server';
            } else {
              return JsonListMaker.convert(
                (content) => StudentClass._fromJsonObj(content),
                json.decode(contents ?? '[]'),
              );
            }
          },
        )
        .then(
          (classes) => classes.forEach((studentClass) {
            StudentClass.currentClasses[studentClass.id] = studentClass;
          }),
        )
        .catchError((error) {});
  }
}
