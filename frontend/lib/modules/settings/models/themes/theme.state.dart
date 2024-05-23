import 'package:financrr_frontend/modules/settings/models/themes/app_theme.model.dart';
import 'package:financrr_frontend/modules/settings/models/themes/app_theme_extension.model.dart';
import 'package:financrr_frontend/modules/settings/models/themes/theme_loader.dart';
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

  ThemeData get themeData => getCurrent().themeData;
  TextTheme get textTheme => themeData.textTheme;
  ColorScheme get colorScheme => themeData.colorScheme;
  FinancrrAppThemeExtension get financrrExtension => getCurrent().financrrExtension;

  AppTheme getCurrent() {
    return switch (mode) {
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light ? lightTheme : darkTheme
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
