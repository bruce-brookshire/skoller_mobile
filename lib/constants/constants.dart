library constants;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

part 'skoller_widgets.dart';
part 'utilities.dart';

class SKColors {
  static final dark_gray = Color(0xFF4A4A4A);
  static final skoller_blue = Color(0xFF57B9E4);
  static final success = Color(0xFF4ADD58);
  static final background_gray = Color(0xFFF5F7F9);
  static final border_gray = Color(0xFFEDEDED);
  static final selected_gray = Color(0xFFF8F8F8);
  static final light_gray = Color(0xFFAAAAAA);
  static final alert_orange = Color(0xFFFF6D00);
  static final text_light_gray = Color(0xFFC7C7CD);
  static final inactive_gray = Color(0xFFEEEEEE);
}
//     ERASERPINK: '#FDBA22',
//     IOSLIGHTGRAY: 'rgb(170,170,170)',
//     INACTIVEGRAY: '#EEEEEE',
//     WARNINGRED: '#FF4159',

class UIAssets {
  static BoxShadow boxShadow = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 1.75),
    blurRadius: 3.5,
  );
  static CupertinoTabBar tabBar;
}

class ClassStatuses {
  static final needs_setup = 1100;
  static final syllabus_submitted = 1200;
  static final needs_student_input = 1300;
  static final class_setup = 1400;
  static final class_issue = 1500;
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
}

class _ActivityImages {
  final add_gray = 'image_assets/activity_assets/add_gray.png';
  final add_white = 'image_assets/activity_assets/add_white.png';
  final weight_gray = 'image_assets/activity_assets/weight_gray.png';
  final weight_white = 'image_assets/activity_assets/weight_white.png';
  final due_gray = 'image_assets/activity_assets/due_gray.png';
  final due_white = 'image_assets/activity_assets/due_white.png';
  final delete_gray = 'image_assets/activity_assets/delete_gray.png';
  final delete_white = 'image_assets/activity_assets/delete_white.png';
  final chat_white = 'image_assets/activity_assets/chat_white.png';
}

class _SignUpImages {
  final happy_classmates = 'image_assets/sign_up_assets/happy_classmates.png';
  final logo_wide_blue = 'image_assets/sign_up_assets/logo_wide_blue.png';
}

class _NavigationArrowImages {
  final left = 'image_assets/navigation_arrow_assets/back.png';
  final right = 'image_assets/navigation_arrow_assets/right.png';
}

class _RightNavImages {
  final plus = 'image_assets/right_button_assets/plus.png';
  final info = 'image_assets/right_button_assets/info.png';
  final link = 'image_assets/right_button_assets/link.png';
}

class _AssignmentInfoImages {
  final notes = 'image_assets/assignment_info_assets/notes.png';
  final circle_x = 'image_assets/assignment_info_assets/circle_x.png';
}

class _PeopleImages {
  final person_light_gray = 'image_assets/people_assets/person_light_gray.png';
  final person_dark_gray = 'image_assets/people_assets/person_dark_gray.png';
  final person_blue = 'image_assets/people_assets/person_blue.png';
  final person_edit = 'image_assets/people_assets/user_edit.png';
  final people_gray = 'image_assets/people_assets/people_gray.png';
  final people_blue = 'image_assets/people_assets/people_blue.png';
  final people_white = 'image_assets/people_assets/people_white.png';
}

class _StatusImages {
  final diy = 'image_assets/status_assets/diy.png';
  final clock = 'image_assets/status_assets/clock.png';
}
