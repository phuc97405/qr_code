import 'package:flutter/material.dart';

const kColorPrimary = Colors.green;

class PrimaryFont {
  static String fontFamily = '';
  static TextStyle think(double size) {
    return TextStyle(
        // fontFamily: fontFamily,
        fontWeight: FontWeight.w100,
        fontSize: size);
  }

  static TextStyle medium(double size) {
    return TextStyle(
        //  fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: size);
  }
}
