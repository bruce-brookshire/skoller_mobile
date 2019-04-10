library constants;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
  static final signUpImages = _SignUpImages();
  static final rightNavImages = _RightNavImages();
  static final navArrowImages = _NavigationArrowImages();
  static final assignmentInfoImages = _AssignmentInfoImages();
  static final peopleImages = _PeopleImages();
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
}

class _AssignmentInfoImages {
  final notes = 'image_assets/assignment_info_assets/notes.png';
}

class _PeopleImages {
  final person_light_gray = 'image_assets/people_assets/person_light_gray.png';
  final person_dark_gray = 'image_assets/people_assets/person_dark_gray.png';
  final person_blue = 'image_assets/people_assets/person_blue.png';
  final people_gray = 'image_assets/people_assets/people_gray.png';
  final people_blue = 'image_assets/people_assets/people_blue.png';
}
