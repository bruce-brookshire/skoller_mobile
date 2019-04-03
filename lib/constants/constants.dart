library constants;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'skoller_widgets.dart';
part 'utilities.dart';

class SKColors {
  static Color dark_gray = Color(0xFF4A4A4A);
  static Color skoller_blue = Color(0xFF57B9E4);
  static Color success = Color(0xFF4ADD58);
  static Color background_gray = Color(0xFFF5F7F9);
  static Color border_gray = Color(0xFFEDEDED);
  static Color selected_gray = Color(0xFFF8F8F8);
}
//     ERASERPINK: '#FDBA22',
//     IOSLIGHTGRAY: 'rgb(170,170,170)',
//     INACTIVEGRAY: '#EEEEEE',
//     WARNINGRED: '#FF4159',
//     TEXTLIGHTGRAY: '#C7C7CD'

class UIAssets {
  static BoxShadow boxShadow = BoxShadow(
    color: Color(0x1C000000),
    offset: Offset(0, 2),
    blurRadius: 3.5,
  );
}

/// Image paths within the image_assets/ folder
class ImageNames {
  static _SignUpImages signUpImages = _SignUpImages();
  static _RightNavImages rightNavImages = _RightNavImages();
  static _NavigationArrowImages navArrowImages = _NavigationArrowImages();
}

class _SignUpImages {
  String happy_classmates = 'image_assets/sign_up_assets/happy_classmates.png';
  String logo_wide_blue = 'image_assets/sign_up_assets/logo_wide_blue.png';
}

class _NavigationArrowImages {

}

class _RightNavImages{
  String plus = 'image_assets/right_button_assets/plus.png';
}
