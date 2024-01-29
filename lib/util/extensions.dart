import 'package:financrr_frontend/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get locale => AppLocalizations.of(this)!;
}

extension ThemeExtension on BuildContext {
  bool get lightMode => Theme.of(this).brightness == Brightness.light;

  bool get darkMode => Theme.of(this).brightness == Brightness.dark;

  SystemUiOverlayStyle get effectiveSystemUiOverlayStyle => lightMode ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

  FinancrrTheme get financrrTheme => Theme.of(this).extension<FinancrrTheme>()!;
}
