import 'package:financrr_frontend/modules/settings/models/themes/app_theme.model.dart';
import 'package:flutter/material.dart';

import 'app_color.model.dart';

extension AppThemeExtension on AppTheme {
  FinancrrAppThemeExtension get financrrExtension =>
      themeData.extensions[FinancrrAppThemeExtension] as FinancrrAppThemeExtension;
}

class FinancrrAppThemeExtension extends ThemeExtension<FinancrrAppThemeExtension> {
  final Brightness brightness;
  final Color primary;
  final Color font;
  final Color background;
  final Color backgroundTone1;
  final Color backgroundTone2;
  final Color backgroundTone3;

  const FinancrrAppThemeExtension(
      {
        required this.brightness,
        required this.primary,
      required this.font,
      required this.background,
      required this.backgroundTone1,
      required this.backgroundTone2,
      required this.backgroundTone3});

  static FinancrrAppThemeExtension? tryFromJson(Map<String, dynamic> json, Brightness brightness) {
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
      brightness: brightness,
      primary: primary.toColor(json),
      font: font.toColor(json),
      background: background.toColor(json),
      backgroundTone1: backgroundTone1.toColor(json),
      backgroundTone2: backgroundTone2.toColor(json),
      backgroundTone3: backgroundTone3.toColor(json),
    );
  }

  Color get primaryContrast => brightness == Brightness.light ? background : font;

  @override
  ThemeExtension<FinancrrAppThemeExtension> copyWith({
    Brightness? brightness,
    Color? primary,
    Color? font,
    Color? background,
    Color? backgroundTone1,
    Color? backgroundTone2,
    Color? backgroundTone3,
  }) {
    return FinancrrAppThemeExtension(
      brightness: brightness ?? this.brightness,
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
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      font: Color.lerp(font, other.font, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundTone1: Color.lerp(backgroundTone1, other.backgroundTone1, t)!,
      backgroundTone2: Color.lerp(backgroundTone2, other.backgroundTone2, t)!,
      backgroundTone3: Color.lerp(backgroundTone3, other.backgroundTone3, t)!,
    );
  }
}
