library constants;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'skoller_widgets.dart';
part 'utilities.dart';

class SKColors {
  static final Color dark_gray = Color(0xFF4A4A4A);
  static final Color skoller_blue = Color(0xFF57B9E4);
  static final Color success = Color(0xFF4ADD58);
  static final Color background_gray = Color(0xFFF5F7F9);
  static final Color border_gray = Color(0xFFEDEDED);
  static final Color selected_gray = Color(0xFFF8F8F8);
}
//     ERASERPINK: '#FDBA22',
//     IOSLIGHTGRAY: 'rgb(170,170,170)',
//     INACTIVEGRAY: '#EEEEEE',
//     WARNINGRED: '#FF4159',
//     TEXTLIGHTGRAY: '#C7C7CD'

class UIAssets {
  static BoxShadow boxShadow = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 1.75),
    blurRadius: 3.5,
  );
}

/// Image paths within the image_assets/ folder
class ImageNames {
  static final _SignUpImages signUpImages = _SignUpImages();
  static final _RightNavImages rightNavImages = _RightNavImages();
  static final _NavigationArrowImages navArrowImages = _NavigationArrowImages();
  static final _AssignmentInfoImages assignmentInfoImages =
      _AssignmentInfoImages();
}

class _SignUpImages {
  final String happy_classmates =
      'image_assets/sign_up_assets/happy_classmates.png';
  final String logo_wide_blue =
      'image_assets/sign_up_assets/logo_wide_blue.png';
}

class _NavigationArrowImages {
  final String left = 'image_assets/navigation_arrow_assets/back.png';
  final String right = 'image_assets/navigation_arrow_assets/right.png';
}

class _RightNavImages {
  final String plus = 'image_assets/right_button_assets/plus.png';
}

class _AssignmentInfoImages {
  final String notes = 'image_assets/assignment_info_assets/notes.png';
}
