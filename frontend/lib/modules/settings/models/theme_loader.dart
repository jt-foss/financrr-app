import 'dart:convert';

import 'package:financrr_frontend/modules/settings/models/theme.model.dart';
import 'package:flutter/services.dart';

class AppThemeLoader {
  static final Map<String, AppTheme> _themes = {};

  static AppTheme? getById(String id) => _themes[id];
  static Iterable<AppTheme> get themes => _themes.values;

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
        AppThemeLoader._themes[theme.id] = theme;
      } else {
        throw StateError('Could not load theme: $path');
      }
    }
  }
}
