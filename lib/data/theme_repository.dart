import 'package:financrr_frontend/data/repositories.dart';
import 'package:flutter/material.dart';

import '../themes.dart';

class ThemePreferences {
  final ThemeMode themeMode;
  final int currentLightThemeId;
  final int currentDarkThemeId;

  const ThemePreferences(
      {this.themeMode = ThemeMode.system, this.currentLightThemeId = 1, this.currentDarkThemeId = 2});

  ThemePreferences copyWith({
    ThemeMode? themeMode,
    int? currentLightThemeId,
    int? currentDarkThemeId,
  }) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      currentLightThemeId: currentLightThemeId ?? this.currentLightThemeId,
      currentDarkThemeId: currentDarkThemeId ?? this.currentDarkThemeId,
    );
  }
}

class ThemeRepository extends Repository<ThemePreferences> {
  ThemeRepository({required super.preferences});

  @override
  String get prefix => 'theme_prefs';

  @override
  List<String> get keys => ['mode', 'current_light_id', 'current_dark_id'];

  @override
  List<RepositoryItem<ThemePreferences>> fromData() {
    return [
      RepositoryItem(key: keys[0], applyFunction: (d) => d.themeMode),
      RepositoryItem(key: keys[1], applyFunction: (d) => d.currentLightThemeId),
      RepositoryItem(key: keys[2], applyFunction: (d) => d.currentDarkThemeId),
    ];
  }

  @override
  ThemePreferences toData(Map<String, Object?> items) {
    return ThemePreferences(
        themeMode: ThemeMode.values.where((t) => t.name == (items[keys[0]] ?? 'system')).first,
        currentLightThemeId: (items[keys[1]] ?? 1) as int,
        currentDarkThemeId: (items[keys[2]] ?? 2) as int);
  }
}

class EffectiveThemePreferences {
  final ThemeMode themeMode;
  final AppTheme currentLightTheme;
  final AppTheme currentDarkTheme;

  const EffectiveThemePreferences(
      {required this.themeMode, required this.currentLightTheme, required this.currentDarkTheme});
}

class ThemeService {
  const ThemeService._();

  static ThemePreferences get() => Repositories.themeRepository.read();

  static Future<EffectiveThemePreferences> getOrInsertEffective() async {
    final ThemePreferences preferences = get();
    return EffectiveThemePreferences(
        themeMode: preferences.themeMode,
        currentLightTheme: AppThemes.themes.where((t) => t.id == preferences.currentLightThemeId).first,
        currentDarkTheme: AppThemes.themes.where((t) => t.id == preferences.currentDarkThemeId).first);
  }

  static Future<ThemePreferences> setThemePreferences(
      AppTheme lightTheme, AppTheme darkTheme, ThemeMode themeMode) async {
    final ThemePreferences preferences =
        ThemePreferences(themeMode: themeMode, currentLightThemeId: lightTheme.id, currentDarkThemeId: darkTheme.id);
    await Repositories.themeRepository.save(preferences);
    return preferences;
  }
}
