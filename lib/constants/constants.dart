library constants;

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui' as dartUI;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:skoller/model/my_subscriptions.dart';

import '../requests/requests_core.dart';

part 'image_names.dart';
part 'skoller_widgets.dart';
part 'typedefs.dart';
part 'utilities.dart';

const FORECAST_TAB = 0;
const CALENDAR_TAB = 1;
const CLASSES_TAB = 2;
const JOBS_TAB = 3;

const PARTY_SIZE = 4;

class SKColors {
  static const skoller_blue = Color(0xFF4A4A4A);
  static const skoller_blue1 = Color(0xFF57B9E4);
  static const menu_blue = Color(0xFFEDFAFF);

  // General
  static const dark_gray = Color(0xFF4A4A4A);
  static const background_gray = Color(0xFFF5F7F9);
  static const selected_gray = Color(0xFFF8F8F8);
  static const border_gray = Color(0xFFEDEDED);
  static const light_gray = Color(0xFFAAAAAA);
  static const text_light_gray = Color(0xFFC7C7CD);
  static const inactive_gray = Color(0xFFEEEEEE);

  static const success = Color(0xFF0FB25C);
  static const alert_orange = Color(0xFFEF4B0A);
  static const warning_red = Color(0xFFEF183D);

  // Skoller Jobs
  static Color jobs_dark_green = Color(0xFF19A394);
  static Color jobs_light_green = Color(0xFF61D8A0);

  static Color darken(Color color, [double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

class Analytics {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
}

class UIAssets {
  static final boxShadow = [
    BoxShadow(
      color: Color(0x21000000),
      offset: Offset(0, 1.75),
      blurRadius: 3.5,
    )
  ];
  static String? versionNumber = '';
}

class ClassStatuses {
  static const needs_setup = 1100;
  static const syllabus_submitted = 1200;
  static const needs_student_input = 1300;
  static const class_setup = 1400;
  static const class_issue = 1500;
}

class NotificationChannels {
  static const toggleMenu = 'toggle-menu';
  static const presentViewOverTabBar = 'present-view-over-tab-bar';
  static const presentModalViewOverTabBar = 'present-modal-view-over-tab-bar';
  static const userChanged = 'user-changed';
  static const classChanged = 'class-changed';
  static const assignmentChanged = 'assignment-changed';
  static const modsChanged = 'mods-changed';
  static const appStateChanged = 'app-state-changed';
  static const selectTab = 'select-tab';
  static const newTabSelected = 'new-tab-selected';
  static const jobsChanged = 'jobs-changed';
}

class PreferencesKeys {
  static const kShouldReview = 'SHOULD_REVIEW';
  static const kSharedToken = 'STUDENT_TOKEN';
  static const kStudentPhone = 'STUDENT_PHONE';
  static const kShouldAskMajor = 'SHOULD_ASK_MAJOR';
}

class PushNotificationCategories {
  // Classes tab
  static const classComplete = 'Class.Complete';
  static const classPrompt = 'ClassPeriod.Prompt';
  static const needsSyllabus = 'Manual.NeedsSyllabus';
  static const secondClass = 'Class.JoinSecond';

// Chat tab
  static const chatComment = 'ClassChat.Comment';
  static const chatReply = 'ClassChat.Reply';
  static const chatPost = 'ClassChat.Post';

  // Forecast tab
  static const assignmentReminderToday = 'Assignment.Reminder.Today';
  static const assignmentReminderFuture = 'Assignment.Reminder.Future';
  static const assignmentPost = 'Assignment.Post';

  // Activity tab
  static const updateAuto = 'Update.Auto';
  static const updatePending = 'Update.Pending';

  // Modal
  static const classStart = 'Class.Start';
  static const growCommunity = 'Class.Community';
  static const points = 'Points.1Thousand';

  // Other
  static const custom = 'Manual.Custom';
  static const signupLinkUsed = 'SignupLink.Used';

  static bool isClasses(String category) => _validateMember(
      [classComplete, classPrompt, needsSyllabus, classStart], category);

  static bool isActivity(String category) =>
      _validateMember([updateAuto, updatePending], category);

  static bool isForecast(String category) => _validateMember(
      [assignmentReminderToday, assignmentReminderFuture], category);

  static bool _validateMember(List<String> categories, category) =>
      categories.contains(category);
}

Map tokenLoginMap = Map();

class Subscriptions {
  static MySubscriptions? mySubscriptions;
}

final statesMap = LinkedHashMap.fromIterables([
  "Alabama",
  "Alaska",
  "Arizona",
  "Arkansas",
  "California",
  "Colorado",
  "Connecticut",
  "Delaware",
  "District Of Columbia",
  "Florida",
  "Georgia",
  "Hawaii",
  "Idaho",
  "Illinois",
  "Indiana",
  "Iowa",
  "Kansas",
  "Kentucky",
  "Louisiana",
  "Maine",
  "Maryland",
  "Massachusetts",
  "Michigan",
  "Minnesota",
  "Mississippi",
  "Missouri",
  "Montana",
  "Nebraska",
  "Nevada",
  "New Hampshire",
  "New Jersey",
  "New Mexico",
  "New York",
  "North Carolina",
  "North Dakota",
  "Ohio",
  "Oklahoma",
  "Oregon",
  "Pennsylvania",
  "Rhode Island",
  "South Carolina",
  "South Dakota",
  "Tennessee",
  "Texas",
  "Utah",
  "Vermont",
  "Virginia",
  "Washington",
  "West Virginia",
  "Wisconsin",
  "Wyoming"
], [
  "AL",
  "AK",
  "AZ",
  "AR",
  "CA",
  "CO",
  "CT",
  "DE",
  "DC",
  "FL",
  "GA",
  "HI",
  "ID",
  "IL",
  "IN",
  "IA",
  "KS",
  "KY",
  "LA",
  "ME",
  "MD",
  "MA",
  "MI",
  "MN",
  "MS",
  "MO",
  "MT",
  "NE",
  "NV",
  "NH",
  "NJ",
  "NM",
  "NY",
  "NC",
  "ND",
  "OH",
  "OK",
  "OR",
  "PA",
  "RI",
  "SC",
  "SD",
  "TN",
  "TX",
  "UT",
  "VT",
  "VA",
  "WA",
  "WV",
  "WI",
  "WY"
]);
