import 'package:flutter/material.dart';

class ColorUtils {
  static Color parseColor(String hexStr) {
    if (hexStr.length == 6) {
      hexStr = "FF$hexStr";
    }
    return Color(int.parse(hexStr, radix: 16));
  }
}
