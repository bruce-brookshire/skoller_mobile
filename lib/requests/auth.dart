part of 'requests_core.dart';

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
            final aps = message['aps'];
            final alert = aps['alert'];

            final title = alert is String ? null : alert['title'];
            final body = alert is String ? alert : alert['body'];
            
            final category = aps['category'];

            _dropdownNotifications(title, body,
                () => _handleNotificationAction(category, message));
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
        },
        onResume: _androidBackgroundHandler,
        onLaunch: _androidBackgroundHandler,
      );
    }
  }

  static Future<dynamic> _androidBackgroundHandler(
      Map<String, dynamic> message) async {
    _handleNotificationAction(message['data']['category'], message['data']);
  }

  static Future<dynamic> _iosBackgroundHandler(
      Map<String, dynamic> message) async {
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

      () async {
        await StudentClass.getStudentClasses();
        await Mod.fetchMods();
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);
      }();

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
      else if (PushNotificationCategories.growCommunity == category) {
        dynamic class_id = data['class_id'];
        if (class_id is String) class_id = int.parse(data['class_id']);

        if (StudentClass.currentClasses[class_id] != null) {
          channel = NotificationChannels.presentModalViewOverTabBar;
          options = ClassLinkSharingModal(class_id);
        }
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
