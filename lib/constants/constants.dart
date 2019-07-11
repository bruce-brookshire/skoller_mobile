library constants;

import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../requests/requests_core.dart';
import 'dart:ui' as dartUI;
import 'dart:async';

part 'skoller_widgets.dart';
part 'utilities.dart';
part 'typedefs.dart';

class SKColors {
  static const dark_gray = Color(0xFF4A4A4A);
  static const background_gray = Color(0xFFF5F7F9);
  static const selected_gray = Color(0xFFF8F8F8);
  static const border_gray = Color(0xFFEDEDED);
  static const light_gray = Color(0xFFAAAAAA);
  static const text_light_gray = Color(0xFFC7C7CD);
  static const inactive_gray = Color(0xFFEEEEEE);

  static const skoller_blue = Color(0xFF57B9E4);
  static const menu_blue = Color(0xFFEDFAFF);
  static const success = Color(0xFF4ADD58);
  static const alert_orange = Color(0xFFFF6D00);
  static const warning_red = Color(0xFFFF4159);
}

class UIAssets {
  static BoxShadow boxShadow = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 1.75),
    blurRadius: 3.5,
  );
  static String versionNumber;
}

class ClassStatuses {
  static const needs_setup = 1100;
  static const syllabus_submitted = 1200;
  static const needs_student_input = 1300;
  static const class_setup = 1400;
  static const class_issue = 1500;
}

/// Image paths within the image_assets/ folder
class ImageNames {
  static final signUpImages = _SignUpImages();
  static final rightNavImages = _RightNavImages();
  static final navArrowImages = _NavigationArrowImages();
  static final assignmentInfoImages = _AssignmentInfoImages();
  static final peopleImages = _PeopleImages();
  static final statusImages = _StatusImages();
  static final activityImages = _ActivityImages();
  static final chatImages = _ChatImages();
  static final sammiImages = _SammiImages();
  static final menuImages = _MenuImages();
  static final tutorialImages = _TutorialImages();
}

class _MenuImages {
  static const _base = 'image_assets/menu_assets';

  final briefcase = '${_base}/briefcase.png';
  final points = '${_base}/points.png';
  final reminders = '${_base}/reminders.png';
}

class _TutorialImages {
  static const _base = 'image_assets/tutorial_assets';

  final syllabus = '${_base}/syllabus.png';
}

class _ChatImages {
  static const _base = 'image_assets/chat_assets';

  final star_yellow = '${_base}/star_yellow.png';
  final commented_blue = '${_base}/commented_blue.png';
  final commented_gray = '${_base}/commented_gray.png';
  final commented_white = '${_base}/commented_white.png';
  final compose = '${_base}/compose.png';
  final filter = '${_base}/filter.png';
  final inbox_unread = '${_base}/inbox_unread.png';
  final inbox = '${_base}/inbox.png';
  final like_blue = '${_base}/like_blue.png';
  final like_gray = '${_base}/like_gray.png';
  final reply_back_gray = '${_base}/reply_back_gray.png';
  final reply_down_gray = '${_base}/reply_down_gray.png';
  final reply_down_white = '${_base}/reply_down_white.png';
  final reply_forward_gray = '${_base}/reply_forward_gray.png';
  final star_gray = '${_base}/star_gray.png';
}

class _ActivityImages {
  static const _base = 'image_assets/activity_assets';

  final add_gray = '${_base}/add_gray.png';
  final add_white = '${_base}/add_white.png';
  final weight_gray = '${_base}/weight_gray.png';
  final weight_white = '${_base}/weight_white.png';
  final due_gray = '${_base}/due_gray.png';
  final due_white = '${_base}/due_white.png';
  final delete_gray = '${_base}/delete_gray.png';
  final delete_white = '${_base}/delete_white.png';
  final chat_white = '${_base}/chat_white.png';
}

class _SignUpImages {
  static const _base = 'image_assets/sign_up_assets';

  final happy_classmates = '${_base}/happy_classmates.png';
  final text_verify = '${_base}/text_verify.png';
  final syllabus_activity = '${_base}/syllabus_activity.png';
  final activities = '${_base}/activities.png';
  final logo_wide_blue = '${_base}/logo_wide_blue.png';
  final search_back_arrow = '${_base}/search_back_arrow.png';
}

class _NavigationArrowImages {
  static const _base = 'image_assets/navigation_arrow_assets';

  final left = '${_base}/back.png';
  final down = '${_base}/down.png';
  final right = '${_base}/right.png';
  final dropdown_blue = '${_base}/dropdown_blue.png';
  final dropdown_gray = '${_base}/dropdown_gray.png';
}

class _SammiImages {
  static const _base = 'image_assets/sammi_personality_assets';

  final cool = '${_base}/cool_sammi.png';
  final shocked = '${_base}/shocked_sammi.png';
  final wow = '${_base}/wow_sammi.png';
  final smile = '${_base}/smile_sammi.png';
}

class _RightNavImages {
  static const _base = 'image_assets/right_button_assets';

  final plus = '${_base}/plus.png';
  final info = '${_base}/info.png';
  final link = '${_base}/link.png';
  final magnifying_glass = '${_base}/magnifying_glass.png';
  final filter_bars = '${_base}/filter_bars.png';
  final add_class = '${_base}/add_class.png';
}

class _AssignmentInfoImages {
  static const _base = 'image_assets/assignment_info_assets';

  final notes = '${_base}/notes.png';
  final circle_x = '${_base}/circle_x.png';
  final comment = '${_base}/comment.png';
  final trash = '${_base}/trash.png';
  final updates_available = '${_base}/updates_available.png';
}

class _PeopleImages {
  static const _base = 'image_assets/people_assets';

  final person_light_gray = '${_base}/person_light_gray.png';
  final person_dark_gray = '${_base}/person_dark_gray.png';
  final person_white = '${_base}/person_white.png';
  final person_blue = '${_base}/person_blue.png';
  final person_edit = '${_base}/user_edit.png';
  final people_white = '${_base}/people_white.png';
  final people_gray = '${_base}/people_gray.png';
  final people_blue = '${_base}/people_blue.png';
  final static_profile = '${_base}/static_profile.png';
}

class _StatusImages {
  static const _base = 'image_assets/status_assets';

  final diy = '${_base}/diy.png';
  final clock = '${_base}/clock.png';
}

class NotificationChannels {
  static const toggleMenu = 'toggle-menu';
  static const presentViewOverTabBar = 'present-view-over-tab-bar';
  static const userChanged = 'user-changed';
  static const classChanged = 'class-changed';
  static const assignmentChanged = 'assignment-changed';
  static const modsChanged = 'mods-changed';
  static const appStateChanged = 'app-state-changed';
}
