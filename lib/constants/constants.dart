library constants;

import 'package:flutter/material.dart';

class SKColors {
  static Color dark_gray = Color(0xFF4A4A4A);
  static Color skoller_blue = Color(0xFF57B9E4);
  static Color success = Color(0xFF4ADD58);
  static Color background_gray = Color(0xFFF5F7F9);
}
//     ERASERPINK: '#FDBA22',
//     LIGHTGRAY: '#EDEDED',
//     IOSLIGHTGRAY: 'rgb(170,170,170)',
//     INACTIVEGRAY: '#EEEEEE',
//     HOMEGREY: '#F8F8F8',
//     WARNINGRED: '#FF4159',
//     BACKGROUNDGREY: '#',
//     TEXTLIGHTGRAY: '#C7C7CD'

class UIAssets {
  static BoxShadow boxShadow = BoxShadow(color: Colors.black);
}

/// Image paths within the image_assets/ folder
class ImageNames {
  static _SignUpImages signUpImages = _SignUpImages();
}

class _SignUpImages {
  String happy_classmates = 'image_assets/sign_up_assets/happy_classmates.png';
}
