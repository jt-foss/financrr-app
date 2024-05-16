import 'package:financrr_frontend/modules/settings/models/themes/app_theme.model.dart';
import 'package:flutter/material.dart';

import 'app_color.model.dart';

extension AppThemeExtension on AppTheme {
  FinancrrAppThemeExtension get financrrExtension => themeData.extensions[FinancrrAppThemeExtension] as FinancrrAppThemeExtension;
}

class FinancrrAppThemeExtension extends ThemeExtension<FinancrrAppThemeExtension> {
  final AppColor primary;
  final AppColor font;
  final AppColor background;
  final AppColor backgroundTone1;
  final AppColor backgroundTone2;
  final AppColor backgroundTone3;

  const FinancrrAppThemeExtension(
      {required this.primary,
        required this.font,
        required this.background,
        required this.backgroundTone1,
        required this.backgroundTone2,
        required this.backgroundTone3});

  static FinancrrAppThemeExtension? tryFromJson(Map<String, dynamic> json) {
    final AppColor? primary = AppColor.tryFromJson(json['primary']);
    final AppColor? font = AppColor.tryFromJson(json['font']);
    final AppColor? background = AppColor.tryFromJson(json['background']);
    final AppColor? backgroundTone1 = AppColor.tryFromJson(json['background_tone1']);
    final AppColor? backgroundTone2 = AppColor.tryFromJson(json['background_tone2']);
    final AppColor? backgroundTone3 = AppColor.tryFromJson(json['background_tone3']);
    if (primary == null ||
        font == null ||
        background == null ||
        backgroundTone1 == null ||
        backgroundTone2 == null ||
        backgroundTone3 == null) {
      return null;
    }
    return FinancrrAppThemeExtension(
      primary: primary,
      font: font,
      background: background,
      backgroundTone1: backgroundTone1,
      backgroundTone2: backgroundTone2,
      backgroundTone3: backgroundTone3,
    );
  }

  @override
  ThemeExtension<FinancrrAppThemeExtension> copyWith({
    AppColor? primary,
    AppColor? font,
    AppColor? background,
    AppColor? backgroundTone1,
    AppColor? backgroundTone2,
    AppColor? backgroundTone3,
  }) {
    return FinancrrAppThemeExtension(
      primary: primary ?? this.primary,
      font: font ?? this.font,
      background: background ?? this.background,
      backgroundTone1: backgroundTone1 ?? this.backgroundTone1,
      backgroundTone2: backgroundTone2 ?? this.backgroundTone2,
      backgroundTone3: backgroundTone3 ?? this.backgroundTone3,
    );
  }

  @override
  ThemeExtension<FinancrrAppThemeExtension> lerp(covariant FinancrrAppThemeExtension? other, double t) {
    if (other == null) {
      return this;
    }
    return FinancrrAppThemeExtension(
      primary: primary.lerp(other.primary, t),
      font: font.lerp(other.font, t),
      background: background.lerp(other.background, t),
      backgroundTone1: backgroundTone1.lerp(other.backgroundTone1, t),
      backgroundTone2: backgroundTone2.lerp(other.backgroundTone2, t),
      backgroundTone3: backgroundTone3.lerp(other.backgroundTone3, t),
    );
  }
}