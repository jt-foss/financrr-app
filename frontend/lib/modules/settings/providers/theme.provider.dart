import 'package:financrr_frontend/modules/settings/models/theme.model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/models/store.dart';
import '../models/theme.state.dart';

final StateNotifierProvider<ThemeNotifier, ThemeState> themeProvider = StateNotifierProvider((_) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial());

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
