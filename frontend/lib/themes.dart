import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/util/json_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppThemeLoader {
  static Future<void> init() async {
    final String manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestContent);
    final List<String> filtered = manifest.keys
        .where((path) => path.startsWith('assets/themes/') && path.endsWith('.financrr-theme.json'))
        .toList();
    for (String path in filtered) {
      final Map<String, dynamic> json = jsonDecode(await rootBundle.loadString(path));
      final AppTheme? theme = AppTheme.tryFromJson(json);
      if (theme != null) {
        AppTheme._themes[theme.id] = theme;
      } else {
        throw StateError('Could not load theme: $path');
      }
    }
  }
}

class AppTheme {
  static final Map<String, AppTheme> _themes = {};

  static const String fontFamily = 'Montserrat';
  static const List<String> fontFamilyFallback = ['Arial', 'sans-serif'];

  final String id;
  final String logoPath;
  final String? translationKey;
  final String? fallbackName;
  final Color previewColor;
  final ThemeMode themeMode;
  final ThemeData themeData;

  const AppTheme(
      {required this.id,
      required this.logoPath,
      this.translationKey,
      this.fallbackName,
      required this.previewColor,
      required this.themeMode,
      required this.themeData});

  String get effectiveName => translationKey?.tr() ?? fallbackName ?? id;

  static AppTheme? getById(String id) => _themes[id];
  static Iterable<AppTheme> get themes => _themes.values;

  static AppTheme? tryFromJson(Map<String, dynamic> json) {
    final AppThemeColor? previewColor = AppThemeColor.tryFromJson(json['preview_color']);
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
    if ((json['translation_key'] != null && json['fallback_name'] != null) ||
        json['translation_key'] == null && json['fallback_name'] == null) {
      throw StateError('Either translation_key or fallback_name must be set!');
    }
    return AppTheme(
        id: json['id'],
        logoPath: json['logo_path'],
        translationKey: json['translation_key'],
        fallbackName: json['fallback_name'],
        previewColor: previewColor.toColor(json),
        themeMode: themeMode,
        themeData: _buildThemeDataFromJson(json, json['theme_data']));
  }

  static ThemeData _buildThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic> json) {
    final Brightness? brightness = JsonUtils.tryEnum(json['brightness'], Brightness.values);
    final Color? primaryColor = AppThemeColor.tryFromJson(json['primary_color'])?.toColor(fullJson);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
    final AppThemeColor? hintColor = AppThemeColor.tryFromJson(json['hint_color']);
    final AppThemeColor? cardColor = AppThemeColor.tryFromJson(json['card_color']);
    final TextTheme textTheme = _buildTextTheme(primaryColor);
    final AppBarTheme? appBarTheme = _tryAppBarThemeFromJson(fullJson, json['app_bar_theme_data']);
    final NavigationBarThemeData? navigationBarTheme =
        _tryNavigationBarThemeDataFromJson(fullJson, json['navigation_bar_theme_data']);
    final NavigationRailThemeData? navigationRailTheme =
        _tryNavigationRailThemeDataFromJson(fullJson, json['navigation_rail_theme_data']);
    final ElevatedButtonThemeData? elevatedButtonTheme =
        _tryElevatedButtonThemeDataFromJson(fullJson, json['elevated_button_theme_data']);
    final TextButtonThemeData? textButtonTheme =
        _tryTextButtonThemeDataFromJson(fullJson, json['text_button_theme_data']);
    final TextSelectionThemeData? textSelectionTheme =
        _tryTextSelectionThemeDataFromJson(fullJson, json['text_selection_theme_data']);
    final SwitchThemeData? switchTheme = _trySwitchThemeDataFromJson(fullJson, json['switch_theme_data']);
    final SnackBarThemeData? snackBarTheme = _trySnackBarThemeDataFromJson(fullJson, json['snack_bar_theme_data']);
    final DrawerThemeData? drawerTheme = _tryDrawerThemeData(fullJson, json['drawer_theme_data']);
    return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor?.toColor(fullJson),
        hintColor: hintColor?.toColor(fullJson),
        cardColor: cardColor?.toColor(fullJson),
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        textTheme: textTheme,
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
    final AppThemeColor? foregroundColor = AppThemeColor.tryFromJson(json['foreground_color']);
    final AppThemeColor? titleColor = AppThemeColor.tryFromJson(json['title_color']);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
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

  static NavigationBarThemeData? _tryNavigationBarThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppThemeColor? indicatorColor = AppThemeColor.tryFromJson(json['indicator_color']);
    final AppThemeColor? iconColor = AppThemeColor.tryFromJson(json['icon_color']);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
    final AppThemeColor? labelColor = AppThemeColor.tryFromJson(json['label_color']);
    if (indicatorColor == null || iconColor == null || backgroundColor == null || labelColor == null) {
      return null;
    }
    return NavigationBarThemeData(
      indicatorColor: indicatorColor.toColor(fullJson),
      iconTheme: MaterialStatePropertyAll(IconThemeData(color: iconColor.toColor(fullJson))),
      backgroundColor: backgroundColor.toColor(fullJson),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor.toColor(fullJson))),
    );
  }

  static NavigationRailThemeData? _tryNavigationRailThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppThemeColor? indicatorColor = AppThemeColor.tryFromJson(json['indicator_color']);
    final AppThemeColor? selectedIconColor = AppThemeColor.tryFromJson(json['selected_icon_color']);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
    final AppThemeColor? selectedLabelColor = AppThemeColor.tryFromJson(json['selected_label_color']);
    final AppThemeColor? unselectedLabelColor = AppThemeColor.tryFromJson(json['unselected_label_color']);
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
    final AppThemeColor? foregroundColor = AppThemeColor.tryFromJson(json['foreground_color']);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
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

  static TextButtonThemeData? _tryTextButtonThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppThemeColor? foregroundColor = AppThemeColor.tryFromJson(json['foreground_color']);
    if (foregroundColor == null) {
      return null;
    }
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor.toColor(fullJson),
      ),
    );
  }

  static TextSelectionThemeData? _tryTextSelectionThemeDataFromJson(
      Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppThemeColor? selectionColor = AppThemeColor.tryFromJson(json['selection_color']);
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
    final AppThemeColor? thumbColor = AppThemeColor.tryFromJson(json['thumb_color']);
    final AppThemeColor? trackColor = AppThemeColor.tryFromJson(json['track_color']);
    if (thumbColor == null || trackColor == null) {
      return null;
    }
    return SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(thumbColor.toColor(fullJson)),
      trackColor: MaterialStatePropertyAll(trackColor.toColor(fullJson)),
      trackOutlineColor: const MaterialStatePropertyAll(Colors.transparent),
    );
  }

  static SnackBarThemeData? _trySnackBarThemeDataFromJson(Map<String, dynamic> fullJson, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final AppThemeColor? contentTextColor = AppThemeColor.tryFromJson(json['content_text_color']);
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
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
    final AppThemeColor? backgroundColor = AppThemeColor.tryFromJson(json['background_color']);
    final AppThemeColor? scrimColor = AppThemeColor.tryFromJson(json['scrim_color']);
    if (backgroundColor == null || scrimColor == null) {
      return null;
    }
    return DrawerThemeData(
      backgroundColor: backgroundColor.toColor(fullJson),
      scrimColor: scrimColor.toColor(fullJson),
    );
  }
}

class AppThemeColor {
  final String? value;
  final AppThemeColorOptions? options;

  const AppThemeColor({this.value, this.options});

  static AppThemeColor? tryFromJson(dynamic json) {
    if (json is String) {
      return AppThemeColor(value: json);
    }
    final AppThemeColorOptions? options = AppThemeColorOptions.tryFromJson(json);
    if (options == null) {
      return null;
    }
    if ((options.hex == null && options.copyFromPath == null) ||
        (options.hex != null && options.copyFromPath != null)) {
      throw StateError('Either hex or copy_from_path must be set!');
    }
    return AppThemeColor(options: options);
  }

  Color toColor(Map<String, dynamic> json) {
    if (value != null) {
      return _parseColor(value!);
    }
    if (options != null) {
      final AppThemeColorOptions colorOptions = options!;
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
            final AppThemeColor? color = AppThemeColor.tryFromJson(current[split]);
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

  Color _parseColor(String rawHex) {
    String hex = rawHex;
    if (hex.length == 8) {
      hex = 'FF${hex.substring(2)}';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class AppThemeColorOptions {
  final String? hex;
  final String? copyFromPath;
  final double? opacity;

  const AppThemeColorOptions({this.hex, this.copyFromPath, this.opacity});

  static AppThemeColorOptions? tryFromJson(Map<String, dynamic> json) {
    if (JsonUtils.isInvalidType(json, 'hex', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'copy_from_path', String, nullable: true) ||
        JsonUtils.isInvalidType(json, 'opacity', double, nullable: true)) {
      return null;
    }
    if ((json['hex'] == null && json['copy_from_path'] == null) ||
        (json['hex'] != null && json['copy_from_path'] != null)) {
      return null;
    }
    return AppThemeColorOptions(hex: json['hex'], copyFromPath: json['copy_from_path'], opacity: json['opacity']);
  }
}
