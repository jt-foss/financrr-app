import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';

import '../../../../utils/json_utils.dart';
import 'app_color.model.dart';
import 'app_text_theme.model.dart';
import 'app_theme_extension.model.dart';

/// Represents a custom theme for the app.
/// This also allows for defining the actual themes in a separate JSON file,
/// making it easier to add and adjust themes - à la "If you can't make it perfect, make it adjustable."
class AppTheme {
  static const String fontFamily = 'Montserrat';
  static const List<String> fontFamilyFallback = ['Arial', 'sans-serif'];

  final String id;
  final String logoPath;
  final L10nKey translationKey;
  final Color previewColor;
  final ThemeMode themeMode;
  final ThemeData themeData;

  const AppTheme({
    required this.id,
    required this.logoPath,
    required this.translationKey,
    required this.previewColor,
    required this.themeMode,
    required this.themeData,
  });

  static AppTheme? tryFromJson(Map<String, dynamic> json) {
    final AppColor? previewColor = AppColor.tryFromJson(json['preview_color']);
    final ThemeMode? themeMode = JsonUtils.tryEnum(json['theme_mode'], ThemeMode.values);
    if (JsonUtils.isInvalidType(json, 'id', String) ||
        JsonUtils.isInvalidType(json, 'logo_path', String) ||
        JsonUtils.isInvalidType(json, 'translation_key', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'fallback_name', String, nullable: true) ||
        previewColor == null ||
        themeMode == null) {
      return null;
    }
    final L10nKey? translationKey = L10nKey.fromKey(json['translation_key']!);
    if (translationKey == null) {
      throw StateError('Either translation_key or fallback_name must be set!');
    }
    return AppTheme(
        id: json['id'],
        logoPath: json['logo_path'],
        translationKey: translationKey,
        previewColor: previewColor.toColor(json),
        themeMode: themeMode,
        themeData: _buildThemeDataFromJson(json));
  }

  static ThemeData _buildThemeDataFromJson(Map<String, dynamic> json) {
    final Brightness? brightness = JsonUtils.tryEnum(json['brightness'], Brightness.values);
    final FinancrrAppThemeExtension? themeExtension = FinancrrAppThemeExtension.tryFromJson(json['colors']);
    if (themeExtension == null) {
      throw StateError('Theme extension must be set!');
    }
    final AppTextTheme textTheme = AppTextTheme.fromJson(json['text_theme'],
        defaultColor: themeExtension.font, defaultFontFamily: fontFamily, defaultFontFamilyFallback: fontFamilyFallback);
    return ThemeData(
      extensions: [themeExtension],
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      primaryColor: themeExtension.primary,
      scaffoldBackgroundColor: themeExtension.background,
      appBarTheme: AppBarTheme(foregroundColor: themeExtension.font),
      iconTheme: IconThemeData(color: themeExtension.backgroundTone3),
      textTheme: TextTheme(
        displayLarge: textTheme.displayLarge.toTextStyle(),
        displayMedium: textTheme.displayMedium.toTextStyle(),
        displaySmall: textTheme.displaySmall.toTextStyle(),
        headlineLarge: textTheme.headlineLarge.toTextStyle(),
        headlineMedium: textTheme.headlineMedium.toTextStyle(),
        headlineSmall: textTheme.headlineSmall.toTextStyle(),
        titleLarge: textTheme.titleLarge.toTextStyle(),
        titleMedium: textTheme.titleMedium.toTextStyle(),
        titleSmall: textTheme.titleSmall.toTextStyle(),
        labelLarge: textTheme.labelLarge.toTextStyle(),
        labelMedium: textTheme.labelMedium.toTextStyle(),
        labelSmall: textTheme.labelSmall.toTextStyle(),
        bodyLarge: textTheme.bodyLarge.toTextStyle(),
        bodyMedium: textTheme.bodyMedium.toTextStyle(),
        bodySmall: textTheme.bodySmall.toTextStyle(),
      ),
    );
  }
}
