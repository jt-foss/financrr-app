import 'package:flutter/material.dart';

import 'app_color.model.dart';

class AppText {
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const AppText({this.fontFamily, this.fontFamilyFallback, this.fontSize, this.fontWeight = FontWeight.normal, this.color});

  static AppText? tryFromJson(Map<String, dynamic> json,
      {Color? defaultColor, String? defaultFontFamily, List<String>? defaultFontFamilyFallback}) {
    final String? fontFamily = json['font_family'] ?? defaultFontFamily;
    final List<String>? fontFamilyFallback = json['font_family_fallback'] ?? defaultFontFamilyFallback;
    final FontWeight fontWeight = FontWeight.values.firstWhere((element) => element.toString().endsWith(json['font_weight']));
    return AppText(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: json['font_size'],
      fontWeight: fontWeight,
      color: AppColor.tryFromJson(json['color'])?.toColor(json) ?? defaultColor,
    );
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
