import 'package:financrr_frontend/modules/settings/models/theme.model.dart';
import 'package:financrr_frontend/modules/settings/models/theme_loader.dart';
import 'package:financrr_frontend/shared/models/store.dart';
import 'package:flutter/material.dart';

class ThemeState {
  final AppTheme lightTheme;
  final AppTheme darkTheme;
  final ThemeMode mode;

  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.mode,
  });

  ThemeState.initial()
      : lightTheme = AppThemeLoader.getById(StoreKey.currentLightThemeId.readSync() ?? 'LIGHT')!,
        darkTheme = AppThemeLoader.getById(StoreKey.currentDarkThemeId.readSync() ?? 'DARK')!,
        mode = StoreKey.themeMode.readSync() ?? ThemeMode.system;

  AppTheme getActive() {
    return switch (mode) {
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme,
      ThemeMode.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light
          ? lightTheme
          : darkTheme
    };
  }

  ThemeState copyWith({
    AppTheme? lightTheme,
    AppTheme? darkTheme,
    ThemeMode? mode,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      mode: mode ?? this.mode,
    );
  }
}
