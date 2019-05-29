library constants;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

part 'skoller_widgets.dart';
part 'utilities.dart';

class SKColors {
  static final dark_gray = Color(0xFF4A4A4A);
  static final background_gray = Color(0xFFF5F7F9);
  static final selected_gray = Color(0xFFF8F8F8);
  static final border_gray = Color(0xFFEDEDED);
  static final light_gray = Color(0xFFAAAAAA);
  static final text_light_gray = Color(0xFFC7C7CD);
  static final inactive_gray = Color(0xFFEEEEEE);

  static final skoller_blue = Color(0xFF57B9E4);
  static final menu_blue = Color(0xFFEDFAFF);
  static final success = Color(0xFF4ADD58);
  static final alert_orange = Color(0xFFFF6D00);
  static final warning_red = Color(0xFFFF4159);
}
//     ERASERPINK: '#FDBA22',

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
  static final chatImages = _ChatImages();
}

class _ChatImages {
  static final _base = 'image_assets/chat_assets';

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
  static final _base = 'image_assets/activity_assets';

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
  static final _base = 'image_assets/sign_up_assets';

  final happy_classmates = '${_base}/happy_classmates.png';
  final logo_wide_blue = '${_base}/logo_wide_blue.png';
}

class _NavigationArrowImages {
  static final _base = 'image_assets/navigation_arrow_assets';

  final left = '${_base}/back.png';
  final down = '${_base}/down.png';
  final right = '${_base}/right.png';
}

class _RightNavImages {
  static final _base = 'image_assets/right_button_assets';

  final plus = '${_base}/plus.png';
  final info = '${_base}/info.png';
  final link = '${_base}/link.png';
}

class _AssignmentInfoImages {
  static final _base = 'image_assets/assignment_info_assets';

  final notes = '${_base}/notes.png';
  final circle_x = '${_base}/circle_x.png';
  final comment = '${_base}/comment.png';
  final trash = '${_base}/trash.png';
  final updates_available = '${_base}/updates_available.png';
}

class _PeopleImages {
  static final _base = 'image_assets/people_assets';

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
  static final _base = 'image_assets/status_assets';

  final diy = '${_base}/diy.png';
  final clock = '${_base}/clock.png';
}
