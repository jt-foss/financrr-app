import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension ThemeExtension on BuildContext {
  AppTheme get appTheme => FinancrrApp.of(this).getAppTheme();

  ThemeData get theme => appTheme.themeData;

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  bool get lightMode => Theme.of(this).brightness == Brightness.light;

  bool get darkMode => Theme.of(this).brightness == Brightness.dark;

  SystemUiOverlayStyle get effectiveSystemUiOverlayStyle =>
      lightMode ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;
}

extension SnackBarExtension on BuildContext {
  void showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), action: action));
  }
}
