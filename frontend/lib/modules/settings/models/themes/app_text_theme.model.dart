import 'dart:ui';

import 'app_text.model.dart';

class AppTextTheme {
  final AppText displayLarge;
  final AppText displayMedium;
  final AppText displaySmall;
  final AppText headlineLarge;
  final AppText headlineMedium;
  final AppText headlineSmall;
  final AppText titleLarge;
  final AppText titleMedium;
  final AppText titleSmall;
  final AppText labelLarge;
  final AppText labelMedium;
  final AppText labelSmall;
  final AppText bodyLarge;
  final AppText bodyMedium;
  final AppText bodySmall;

  const AppTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  static AppTextTheme fromJson(Map<String, dynamic>? json,
      {Color? defaultColor, String? defaultFontFamily, List<String>? defaultFontFamilyFallback}) {
    AppText fromJson(String key, AppText fallback) {
      if (json == null) {
        return fallback.copyWith(
          color: defaultColor,
          fontFamily: defaultFontFamily,
          fontFamilyFallback: defaultFontFamilyFallback,
        );
      }
      return AppText.tryFromJson(json[key],
              defaultColor: defaultColor,
              defaultFontFamily: defaultFontFamily,
              defaultFontFamilyFallback: defaultFontFamilyFallback) ??
          fallback;
    }

    return AppTextTheme(
      displayLarge: fromJson('display_large', const AppText(fontSize: 57, fontWeight: FontWeight.bold)),
      displayMedium: fromJson('display_medium', const AppText(fontSize: 45, fontWeight: FontWeight.bold)),
      displaySmall: fromJson('display_small', const AppText(fontSize: 36, fontWeight: FontWeight.bold)),
      headlineLarge: fromJson('headline_large', const AppText(fontSize: 32)),
      headlineMedium: fromJson('headline_medium', const AppText(fontSize: 28)),
      headlineSmall: fromJson('headline_small', const AppText(fontSize: 24)),
      titleLarge: fromJson('title_large', const AppText(fontSize: 22, fontWeight: FontWeight.bold)),
      titleMedium: fromJson('title_medium', const AppText(fontSize: 16, fontWeight: FontWeight.bold)),
      titleSmall: fromJson('title_small', const AppText(fontSize: 14, fontWeight: FontWeight.bold)),
      labelLarge: fromJson('label_large', const AppText(fontSize: 14, fontWeight: FontWeight.w500)),
      labelMedium: fromJson('label_medium', const AppText(fontSize: 12, fontWeight: FontWeight.w500)),
      labelSmall: fromJson('label_small', const AppText(fontSize: 11, fontWeight: FontWeight.w500)),
      bodyLarge: fromJson('body_large', const AppText(fontSize: 16)),
      bodyMedium: fromJson('body_medium', const AppText(fontSize: 14)),
      bodySmall: fromJson('body_small', const AppText(fontSize: 12)),
    );
  }
}
