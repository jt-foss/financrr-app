import 'dart:ui';

import 'package:financrr_frontend/utils/extensions.dart' hide ThemeExtension;
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';

import '../../../utils/json_utils.dart';

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

  const AppTheme(
      {required this.id,
        required this.logoPath,
        required this.translationKey,
        required this.previewColor,
        required this.themeMode,
        required this.themeData,});

  static AppTheme? tryFromJson(Map<String, dynamic> json) {
    final AppColor? previewColor = AppColor.tryFromJson(json['preview_color']);
    final ThemeMode? themeMode = JsonUtils.tryEnum(json['theme_mode'], ThemeMode.values);
    if (JsonUtils.isInvalidType(json, 'id', String) ||
        JsonUtils.isInvalidType(json, 'logo_path', String) ||
        JsonUtils.isInvalidType(json, 'translation_key', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'fallback_name', String, nullable: true) ||
        previewColor == null ||
        themeMode == null ||
        JsonUtils.isInvalidType(json, 'theme_data', Map)) {
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
        themeData: _buildThemeDataFromJson(json, json['theme_data']));
  }

  static ThemeData _buildThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic> json) {
    final Brightness? brightness = JsonUtils.tryEnum(json['brightness'], Brightness.values);
    final Color? primaryColor = AppColor.tryFromJson(json['primary_color'])?.toColor(fullJson);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    final AppColor? hintColor = AppColor.tryFromJson(json['hint_color']);
    final AppColor? cardColor = AppColor.tryFromJson(json['card_color']);
    final TextTheme textTheme = _buildTextTheme(primaryColor);
    final AppBarTheme? appBarTheme = _tryAppBarThemeFromJson(fullJson, json['app_bar_theme_data']);
    final NavigationBarThemeData? navigationBarTheme =
    _tryNavigationBarThemeDataFromJson(fullJson, json['navigation_bar_theme_data']);
    final NavigationRailThemeData? navigationRailTheme =
    _tryNavigationRailThemeDataFromJson(fullJson, json['navigation_rail_theme_data']);
    final ElevatedButtonThemeData? elevatedButtonTheme =
    _tryElevatedButtonThemeDataFromJson(fullJson, json['elevated_button_theme_data']);
    final TextButtonThemeData? textButtonTheme = _tryTextButtonThemeDataFromJson(fullJson, json['text_button_theme_data']);
    final TextSelectionThemeData? textSelectionTheme =
    _tryTextSelectionThemeDataFromJson(fullJson, json['text_selection_theme_data']);
    final SwitchThemeData? switchTheme = _trySwitchThemeDataFromJson(fullJson, json['switch_theme_data']);
    final SnackBarThemeData? snackBarTheme = _trySnackBarThemeDataFromJson(fullJson, json['snack_bar_theme_data']);
    final DrawerThemeData? drawerTheme = _tryDrawerThemeData(fullJson, json['drawer_theme_data']);

    FinancrrAppThemeExtension? themeExtension = FinancrrAppThemeExtension.tryFromJson(fullJson['colors']);
    if (themeExtension == null) {
      throw StateError('Theme extension must be set!');
    }
    AppTextTheme appTextTheme = AppTextTheme.fromJson(json['text_theme'], defaultColor: themeExtension.font, defaultFontFamily: fontFamily, defaultFontFamilyFallback: fontFamilyFallback);

    return ThemeData(
        extensions: [themeExtension],
        useMaterial3: true,
        brightness: brightness,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        primaryColor: themeExtension.primary.toColor(fullJson),
        scaffoldBackgroundColor: themeExtension.background.toColor(fullJson),
        textTheme: TextTheme(
          displayLarge: appTextTheme.displayLarge.toTextStyle(),
          displayMedium: appTextTheme.displayMedium.toTextStyle(),
          displaySmall: appTextTheme.displaySmall.toTextStyle(),
          headlineLarge: appTextTheme.headlineLarge.toTextStyle(),
          headlineMedium: appTextTheme.headlineMedium.toTextStyle(),
          headlineSmall: appTextTheme.headlineSmall.toTextStyle(),
          titleLarge: appTextTheme.titleLarge.toTextStyle(),
          titleMedium: appTextTheme.titleMedium.toTextStyle(),
          titleSmall: appTextTheme.titleSmall.toTextStyle(),
          labelLarge: appTextTheme.labelLarge.toTextStyle(),
          labelMedium: appTextTheme.labelMedium.toTextStyle(),
          labelSmall: appTextTheme.labelSmall.toTextStyle(),
          bodyLarge: appTextTheme.bodyLarge.toTextStyle(),
          bodyMedium: appTextTheme.bodyMedium.toTextStyle(),
          bodySmall: appTextTheme.bodySmall.toTextStyle(),
        ),

        // TODO: remove everything below
        hintColor: hintColor?.toColor(fullJson),
        cardColor: cardColor?.toColor(fullJson),
        popupMenuTheme: const PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: const DialogTheme(
          surfaceTintColor: Colors.transparent,
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide.none,
        ),
        sliderTheme: const SliderThemeData(
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
          trackHeight: 2.0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.w600),
          focusedBorder: OutlineInputBorder(
            borderSide: primaryColor == null ? BorderSide.none : BorderSide(color: primaryColor),
          ),
          border: const OutlineInputBorder(),
        ),
        expansionTileTheme: const ExpansionTileThemeData(shape: Border()),
        // theme data
        appBarTheme: appBarTheme,
        navigationBarTheme: navigationBarTheme,
        navigationRailTheme: navigationRailTheme,
        elevatedButtonTheme: elevatedButtonTheme,
        textButtonTheme: textButtonTheme,
        textSelectionTheme: textSelectionTheme,
        switchTheme: switchTheme,
        snackBarTheme: snackBarTheme,
        drawerTheme: drawerTheme);
  }

  static TextTheme _buildTextTheme(Color? primaryColor) {
    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      displayMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      displaySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      titleSmall: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: const TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: const TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  static AppBarTheme? _tryAppBarThemeFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? foregroundColor = AppColor.tryFromJson(json['foreground_color']);
    final AppColor? titleColor = AppColor.tryFromJson(json['title_color']);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    if (foregroundColor == null || titleColor == null || backgroundColor == null) {
      return null;
    }
    return AppBarTheme(
        foregroundColor: foregroundColor.toColor(fullJson),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: titleColor.toColor(fullJson),
        ),
        backgroundColor: backgroundColor.toColor(fullJson),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true);
  }

  static NavigationBarThemeData? _tryNavigationBarThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? indicatorColor = AppColor.tryFromJson(json['indicator_color']);
    final AppColor? iconColor = AppColor.tryFromJson(json['icon_color']);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    final AppColor? labelColor = AppColor.tryFromJson(json['label_color']);
    if (indicatorColor == null || iconColor == null || backgroundColor == null || labelColor == null) {
      return null;
    }
    return NavigationBarThemeData(
      indicatorColor: indicatorColor.toColor(fullJson),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: iconColor.toColor(fullJson))),
      backgroundColor: backgroundColor.toColor(fullJson),
      surfaceTintColor: Colors.transparent,
      labelTextStyle:
      WidgetStatePropertyAll(TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor.toColor(fullJson))),
    );
  }

  static NavigationRailThemeData? _tryNavigationRailThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? indicatorColor = AppColor.tryFromJson(json['indicator_color']);
    final AppColor? selectedIconColor = AppColor.tryFromJson(json['selected_icon_color']);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    final AppColor? selectedLabelColor = AppColor.tryFromJson(json['selected_label_color']);
    final AppColor? unselectedLabelColor = AppColor.tryFromJson(json['unselected_label_color']);
    if (indicatorColor == null ||
        selectedIconColor == null ||
        backgroundColor == null ||
        selectedLabelColor == null ||
        unselectedLabelColor == null) {
      return null;
    }
    return NavigationRailThemeData(
      indicatorColor: indicatorColor.toColor(fullJson),
      selectedIconTheme: IconThemeData(color: selectedIconColor.toColor(fullJson)),
      backgroundColor: backgroundColor.toColor(fullJson),
      selectedLabelTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selectedLabelColor.toColor(fullJson),
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: unselectedLabelColor.toColor(fullJson),
      ),
    );
  }

  static ElevatedButtonThemeData? _tryElevatedButtonThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? foregroundColor = AppColor.tryFromJson(json['foreground_color']);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    if (foregroundColor == null || backgroundColor == null) {
      return null;
    }
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor.toColor(fullJson),
        backgroundColor: backgroundColor.toColor(fullJson),
      ),
    );
  }

  static TextButtonThemeData? _tryTextButtonThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? foregroundColor = AppColor.tryFromJson(json['foreground_color']);
    if (foregroundColor == null) {
      return null;
    }
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor.toColor(fullJson),
      ),
    );
  }

  static TextSelectionThemeData? _tryTextSelectionThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? selectionColor = AppColor.tryFromJson(json['selection_color']);
    if (selectionColor == null) {
      return null;
    }
    return TextSelectionThemeData(
      selectionColor: selectionColor.toColor(fullJson),
    );
  }

  static SwitchThemeData? _trySwitchThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? thumbColor = AppColor.tryFromJson(json['thumb_color']);
    final AppColor? trackColor = AppColor.tryFromJson(json['track_color']);
    if (thumbColor == null || trackColor == null) {
      return null;
    }
    return SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(thumbColor.toColor(fullJson)),
      trackColor: WidgetStatePropertyAll(trackColor.toColor(fullJson)),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  static SnackBarThemeData? _trySnackBarThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? contentTextColor = AppColor.tryFromJson(json['content_text_color']);
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    if (contentTextColor == null || backgroundColor == null) {
      return null;
    }
    return SnackBarThemeData(
      contentTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: contentTextColor.toColor(fullJson),
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: backgroundColor.toColor(fullJson),
    );
  }

  static DrawerThemeData? _tryDrawerThemeData(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppColor? backgroundColor = AppColor.tryFromJson(json['background_color']);
    final AppColor? scrimColor = AppColor.tryFromJson(json['scrim_color']);
    if (backgroundColor == null || scrimColor == null) {
      return null;
    }
    return DrawerThemeData(
      backgroundColor: backgroundColor.toColor(fullJson),
      scrimColor: scrimColor.toColor(fullJson),
    );
  }
}

class FinancrrAppThemeExtension extends ThemeExtension<FinancrrAppThemeExtension> {
  final AppColor primary;
  final AppColor font;
  final AppColor background;
  final AppColor backgroundTone1;
  final AppColor backgroundTone2;
  final AppColor backgroundTone3;

  const FinancrrAppThemeExtension({required this.primary, required this.font, required this.background, required this.backgroundTone1, required this.backgroundTone2, required this.backgroundTone3});

  static FinancrrAppThemeExtension? tryFromJson(Map<String, dynamic> json) {
    final AppColor? primary = AppColor.tryFromJson(json['primary']);
    final AppColor? font = AppColor.tryFromJson(json['font']);
    final AppColor? background = AppColor.tryFromJson(json['background']);
    final AppColor? backgroundTone1 = AppColor.tryFromJson(json['background_tone1']);
    final AppColor? backgroundTone2 = AppColor.tryFromJson(json['background_tone2']);
    final AppColor? backgroundTone3 = AppColor.tryFromJson(json['background_tone3']);
    if (primary == null || font == null || background == null || backgroundTone1 == null || backgroundTone2 == null || backgroundTone3 == null) {
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

  static AppTextTheme fromJson(Map<String, dynamic>? json, {AppColor? defaultColor, String? defaultFontFamily, List<String>? defaultFontFamilyFallback}) {
    AppText fromJson(String key, AppText fallback) {
      if (json == null) {
        return fallback;
      }
      return AppText.tryFromJson(json[key], defaultColor: defaultColor, defaultFontFamily: defaultFontFamily, defaultFontFamilyFallback: defaultFontFamilyFallback) ?? fallback;
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

class AppText {
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? fontSize;
  final FontWeight fontWeight;
  final AppColor? color;

  const AppText({this.fontFamily, this.fontFamilyFallback, this.fontSize, this.fontWeight = FontWeight.normal, this.color});

  static AppText? tryFromJson(Map<String, dynamic> json,
      {AppColor? defaultColor, String? defaultFontFamily, List<String>? defaultFontFamilyFallback}) {
    final String? fontFamily = json['font_family'] ?? defaultFontFamily;
    final List<String>? fontFamilyFallback = json['font_family_fallback'] ?? defaultFontFamilyFallback;
    final FontWeight fontWeight = FontWeight.values.firstWhere((element) => element.toString().endsWith(json['font_weight']));
    return AppText(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: json['font_size'],
      fontWeight: fontWeight,
      color: AppColor.tryFromJson(json['color']) ?? defaultColor,
    );
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color?.toColor({}),
    );
  }
}

class AppColor {
  final String? value;
  final AppColorOptions? options;

  const AppColor({this.value, this.options});

  static AppColor? tryFromJson(dynamic json) {
    if (json is String) {
      return AppColor(value: json);
    }
    final AppColorOptions? options = AppColorOptions.tryFromJson(json);
    if (options == null) {
      return null;
    }
    if ((options.hex == null && options.copyFromPath == null) || (options.hex != null && options.copyFromPath != null)) {
      throw StateError('Either hex or copy_from_path must be set!');
    }
    return AppColor(options: options);
  }

  Color toColor(Map<String, dynamic> json) {
    if (value != null) {
      return _parseColor(value!);
    }
    if (options != null) {
      final AppColorOptions colorOptions = options!;
      final double opacity = colorOptions.opacity ?? 1;
      if (colorOptions.hex != null) {
        return _parseColor(colorOptions.hex!).withOpacity(opacity);
      }
      if (colorOptions.copyFromPath != null) {
        final String path = colorOptions.copyFromPath!;
        Color? color;
        Map<String, dynamic> current = json;
        for (String split in path.split('/')) {
          if (current[split] is Map) {
            final Map<String, dynamic> newMap = current[split];
            final AppColor? color = AppColor.tryFromJson(current[split]);
            if (color == null) {
              current = newMap;
            } else {
              return color.toColor(json);
            }
          }
          if (current[split] is String) {
            color = _parseColor(current[split] as String);
          }
        }
        if (color == null) {
          throw StateError('Color not found at path: $path');
        }
        return color.withOpacity(opacity);
      }
    }
    throw StateError('Either value or options must be set!');
  }

  AppColor lerp(covariant AppColor other, double t) {
    return AppColor(
      value: value == null || other.value == null ? null : Color.lerp(_parseColor(value!), _parseColor(other.value!), t)?.toHex(),
      options: options == null || options?.hex == null || other.options == null || other.options?.hex == null
          ? null
          : AppColorOptions(
        hex: Color.lerp(_parseColor(options!.hex!), _parseColor(other.options!.hex!), t)?.toHex(),
        opacity: options!.opacity == null || other.options!.opacity == null
            ? null
            : lerpDouble(options!.opacity!, other.options!.opacity!, t),
      )
    );
  }

  Color _parseColor(String rawHex) {
    String hex = rawHex;
    if (hex.length == 8) {
      hex = 'FF${hex.substring(2)}';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class AppColorOptions {
  final String? hex;
  final String? copyFromPath;
  final double? opacity;

  const AppColorOptions({this.hex, this.copyFromPath, this.opacity});

  static AppColorOptions? tryFromJson(Map<String, dynamic> json) {
    if (JsonUtils.isInvalidType(json, 'hex', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'copy_from_path', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'opacity', double, nullable: true)) {
      return null;
    }
    if ((json['hex'] == null && json['copy_from_path'] == null) || (json['hex'] != null && json['copy_from_path'] != null)) {
      return null;
    }
    return AppColorOptions(hex: json['hex'], copyFromPath: json['copy_from_path'], opacity: json['opacity']);
  }
}