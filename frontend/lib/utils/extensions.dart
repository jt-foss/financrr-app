import 'dart:async';

import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/shared/models/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restrr/restrr.dart';

extension LayoutExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 550;
  bool get isWidescreen => MediaQuery.of(this).size.width >= 1100;
}

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

extension StreamControllerExtension<T> on StreamController<T> {
  Future<T?> fetchData(String? id, Future<T?> Function(Id) dataFunction) async {
    if (id == null) {
      sink.addError('Encountered null id!');
      return null;
    }
    return _checkData(await dataFunction.call(int.tryParse(id) ?? 0));
  }

  Future<T?> _checkData(T? data) async {
    if (data == null) {
      sink.addError('Could not retrieve Data');
      return null;
    }
    sink.add(data);
    return data;
  }
}
