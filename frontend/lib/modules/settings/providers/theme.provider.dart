import 'package:financrr_frontend/modules/settings/models/theme.model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/models/store.dart';
import '../models/theme.state.dart';

final StateNotifierProvider<ThemeNotifier, ThemeState> themeProvider = StateNotifierProvider((_) => ThemeNotifier());

extension ConsumerStateThemeExtension on WidgetRef {
  ThemeState get themeState => read(themeProvider);
  ThemeNotifier get themeNotifier => read(themeProvider.notifier);

  AppTheme get currentTheme => themeNotifier.getCurrent();

  ThemeData get themeData => currentTheme.themeData;
  TextTheme get textTheme => themeData.textTheme;
  ColorScheme get colorScheme => themeData.colorScheme;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial());

  AppTheme getCurrent() {
    return switch (state.mode) {
      ThemeMode.light => state.lightTheme,
      ThemeMode.dark => state.darkTheme,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light ? state.lightTheme : state.darkTheme
    };
  }

  void setLightTheme(AppTheme theme) {
    if (theme.themeMode != ThemeMode.light) {
      throw ArgumentError('Theme is not a light theme!');
    }
    StoreKey.currentLightThemeId.write(theme.id);
    state = state.copyWith(lightTheme: theme);
  }
  void setDarkTheme(AppTheme theme) {
    if (theme.themeMode != ThemeMode.dark) {
      throw ArgumentError('Theme is not a dark theme!');
    }
    StoreKey.currentDarkThemeId.write(theme.id);
    state = state.copyWith(darkTheme: theme);
  }

  void setMode(ThemeMode mode) {
    StoreKey.themeMode.write(mode);
    state = state.copyWith(mode: mode);
  }
}
