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
      if (postRequestAction != null) postRequestAction();
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

enum LogInResponse { success, needsVerification, failed, internetError }

class Auth {
  static String userPhone;

  static Future<bool> enforceMinVersion() async {
    final response = await http.get('${SKRequests._baseUrl}/min-version');
    var content;
    try {
      content = response.body != null ? json.decode(response.body) : null;
    } catch (e) {
      content = response.body;
    }

    if (content is List) {
      final version = (await PackageInfo.fromPlatform()).version;
      UIAssets.versionNumber = version;

      final platformName =
          Platform.isIOS ? 'min_ios_version' : 'min_android_version';
      final thisPlatform =
          content.firstWhere((platform) => platform['name'] == platformName);

      if (thisPlatform == null) return false;

      final device =
          version.split('.').map((str) => int.tryParse(str)).toList();
      final preferred = (thisPlatform['value'] as String)
          .split('.')
          .map((str) => int.tryParse(str))
          .toList();

      final max =
          device.length > preferred.length ? preferred.length : device.length;
      int index = 0;

      while (index < max) {
        final devicePartial = device[index];
        final preferredPartial = preferred[index];

        if (devicePartial > preferredPartial)
          return true;
        else if (devicePartial < preferredPartial)
          return false;
        else
          index++;
      }
    }
    return true;
  }

  static SKUser _fromJsonAuth(Map context) {
    final user = SKUser._fromJson(context['user']);

    String token = context['token'];
    SharedPreferences.getInstance()
        .then((inst) => inst.setString(PreferencesKeys.kSharedToken, token));
    SKRequests._headers['Authorization'] = 'Bearer $token';

    return user;
  }

  static SKUser _fromJsonNoAuth(Map context) {
    return SKUser._fromJson(context['user']);
  }

  static Future<LogInResponse> attemptLogin() async {
    final inst = await SharedPreferences.getInstance();
    final token = inst.getString(PreferencesKeys.kSharedToken);
    userPhone = inst.getString(PreferencesKeys.kStudentPhone);

    if (token != null) {
      SKRequests._headers['Authorization'] = 'Bearer $token';

      //Check if we can use the previously stored token
      final validToken = await tokenLogin();

      //If token login didnt work, we need to remove the bad token
      if (!validToken) {
        SKRequests._headers.remove('Authorization');
      }

      //Token is valid
      if (validToken) {
        _setupNotifications();
        return LogInResponse.success;
      }
      //Token is invalid, do we have the phone number?
      else if (userPhone != null) {
        //We do. Request the user to sign in again
        final status = await requestLogin(userPhone);
        //Did the request complete correctly?
        if ([200, 204].contains(status))
          return LogInResponse.needsVerification;
        //Request failed, just have the user sign in again
        else if (status == 404)
          return LogInResponse.failed;
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

  static Future<int> requestLogin(String phone) {
    return SKRequests.post(
      '/students/login',
      {"phone": phone},
      null,
    ).then((onValue) {
      return onValue.status;
    });
  }

  static Future<RequestResponse> logIn(String phone, String code) {
    return SKRequests.post(
      '/students/login',
      {"phone": phone, "verification_code": code},
      _fromJsonAuth,
    ).then((response) {
      if (response.wasSuccessful()) {
        _setupNotifications();
        SharedPreferences.getInstance().then(
            (inst) => inst.setString(PreferencesKeys.kStudentPhone, phone));

        userPhone = phone;
        return response;
      } else {
        throw response.status == 401
            ? 'Invalid code'
            : 'Unknown issue. If this persists, please contact us';
      }
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
    SKCacheManager.deleteCache();

    Assignment.currentAssignments = {};
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
    final utc_hour_notification = 9 - offset;
    final utc_hour_future_notification = 17 - offset;

    final timeStrFactory = (int hour) {
      final newHr = hour.abs() % 24;
      print(newHr);

      if (newHr >= 10)
        return '$newHr:00:00.000';
      else
        return '0$newHr:00:00.000';
    };

    return SKRequests.post(
        '/users',
        {
          'email': email,
          'student': {
            'name_first': nameFirst,
            'name_last': nameLast,
            'phone': phone,
            'notification_time': timeStrFactory(utc_hour_notification),
            'future_reminder_notification_time':
                timeStrFactory(utc_hour_future_notification),
          },
        },
        SKUser._fromJson);
  }

  static void saveNotificationToken(String token) {
    assert(SKUser.current != null && token != null);
    SKRequests.post(
      '/users/${SKUser.current.id}/register',
      {
        'udid': token,
        "type": Platform.isIOS ? 'ios' : 'android',
      },
      null,
    );
  }

  static ApnsPushConnector _apnsConnector;
  static FirebaseMessaging _firebaseMessaging;

  static void requestNotificationPermissions() {
    if (Platform.isIOS) {
      _apnsConnector = createPushConnector();
      _apnsConnector.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (message != null && message['aps'] != null) {
            final body = message['aps']['alert'];
            final category = message['aps']['category'];

            _dropdownNotifications(
                null, body, () => _handleNotificationAction(category, message));
          }
        },
        onResume: _iosBackgroundHandler,
        onLaunch: _iosBackgroundHandler,
      );
      _apnsConnector.requestNotificationPermissions();
    } else {
      _firebaseMessaging = FirebaseMessaging();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          if (message != null && message['notification'] != null) {
            final title = message['notification']['title'];
            final body = message['notification']['body'];
            final category = message['data']['category'];

            _dropdownNotifications(title, body,
                () => _handleNotificationAction(category, message['data']));
          }
          print('on message $message');
        },
        onResume: _androidBackgroundHandler,
        onLaunch: _androidBackgroundHandler,
      );
    }
  }

  static Future<dynamic> _androidBackgroundHandler(
      Map<String, dynamic> message) async {
    print(message);
    _handleNotificationAction(message['data']['category'], message['data']);
  }

  static Future<dynamic> _iosBackgroundHandler(
      Map<String, dynamic> message) async {
    print(message);
    _handleNotificationAction(message['aps']['category'], message);
  }

  static void _dropdownNotifications(
    String title,
    String body,
    VoidCallback tapCallback,
  ) {
    DropdownBanner.showBanner(
      duration: Duration(seconds: 5),
      color: SKColors.menu_blue,
      text:
          '${title ?? ''}${(title != null && body != null) ? '\n' : ''}${body ?? ''}',
      textStyle: TextStyle(fontSize: 14),
      tapCallback: tapCallback,
    );
  }

  // Handles a notification action
  static void _handleNotificationAction(
      [String category, Map data, int attempt = 0]) {
    //If we have no category or if we have exceeded our attempts, return
    if (category == null || attempt == 3) return;

    if (StudentClass.classesLoaded) {
      String channel;
      dynamic options;

      if (PushNotificationCategories.isClasses(category)) {
        channel = NotificationChannels.selectTab;
        options = CLASSES_TAB;
      } else if (PushNotificationCategories.isChat(category)) {
        channel = NotificationChannels.selectTab;
        options = CHAT_TAB;
      } else if (PushNotificationCategories.isActivity(category)) {
        channel = NotificationChannels.selectTab;
        options = ACTIVITY_TAB;
      } else if (PushNotificationCategories.isForecast(category)) {
        channel = NotificationChannels.selectTab;
        options = FORECAST_TAB;
      }
      // Is this a grow community notification and do we have the student class loaded?
      else if (PushNotificationCategories.growCommunity == category &&
          StudentClass.currentClasses[data['class_id'] ?? 0] != null) {
        channel = NotificationChannels.presentViewOverTabBar;
        options = ClassLinkSharingModal(data['class_id']);
      } else if (PushNotificationCategories.points == category) {
        channel = NotificationChannels.presentViewOverTabBar;
        options = MyPointsView();
      }

      if (channel != null && options != null)
        Timer(
          Duration(milliseconds: 500),
          () => DartNotificationCenter.post(channel: channel, options: options),
        );
    } else
      Timer(
        Duration(milliseconds: 500 * (attempt + 1)),
        () => _handleNotificationAction(category, data, attempt + 1),
      );
  }

  static void _setupNotifications() {
    if (Platform.isIOS) {
      final tokenNotifier = _apnsConnector.token;

      if (tokenNotifier.value != null && SKUser.current != null) {
        saveNotificationToken(tokenNotifier.value);
      } else {
        _apnsConnector.token.addListener(() {
          final token = _apnsConnector.token.value;
          if (token != null && SKUser.current != null) {
            saveNotificationToken(token);
          }
        });
      }
    } else if (Platform.isAndroid) {
      _firebaseMessaging.getToken().then((token) {
        if (token != null && SKUser.current != null)
          saveNotificationToken(token);
      }).catchError(print);
    }
  }
}
