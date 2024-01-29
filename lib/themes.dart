import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppTheme {
  final int id;
  final String Function(AppLocalizations) name;
  final Color previewColor;
  final ThemeMode themeMode;
  final ThemeData themeData;

  const AppTheme(
      {required this.id, required this.name, required this.previewColor, required this.themeMode, required this.themeData});
}

class AppThemes {
  static final List<AppTheme> themes = [light(), dark()];
  static const TextStyle _defaultStyle = TextStyle(fontFamily: 'Montserrat', fontFamilyFallback: ['Arial']);

  const AppThemes._();

  static AppTheme light() {
    const FinancrrTheme financrrTheme = FinancrrTheme(
        logoPath: 'logo/logo_blue.svg',
        primaryAccentColor: Color(0xFF2C03E6),
        primaryTextColor: Color(0xFF000000),
        secondaryTextColor: Color(0xFF1C1B1F),
        primaryBackgroundColor: Color(0xFFFFFFFF),
        secondaryBackgroundColor: Color(0xFFEBEBEB));
    return AppTheme(
        id: 1,
        name: (_) => 'Light',
        previewColor: Colors.white,
        themeMode: ThemeMode.light,
        themeData: _buildThemeData(financrrTheme, Brightness.light));
  }

  // TODO: implement actual dark theme colors
  static AppTheme dark() {
    const FinancrrTheme financrrTheme = FinancrrTheme(
        logoPath: 'logo/logo_light.svg',
        primaryAccentColor: Color(0xFF407BF8),
        primaryTextColor: Color(0xFFFFFFFF),
        secondaryTextColor: Color(0xFFBFBFBF),
        primaryBackgroundColor: Color(0xFF2B2D31),
        secondaryBackgroundColor: Color(0xFF1F2124));
    return AppTheme(
        id: 2,
        name: (_) => 'Dunkel',
        previewColor: const Color(0xFF2B2D31),
        themeMode: ThemeMode.dark,
        themeData: _buildThemeData(financrrTheme, Brightness.dark));
  }

  static ThemeData _buildThemeData(FinancrrTheme financrrTheme, Brightness brightness) {
    final TextStyle defaultStyle = _defaultStyle.copyWith(color: financrrTheme.primaryTextColor);
    return ThemeData(
        extensions: [financrrTheme],
        scaffoldBackgroundColor: financrrTheme.primaryBackgroundColor,
        brightness: brightness,
        colorScheme: ThemeData().colorScheme.copyWith(
            primary: financrrTheme.primaryAccentColor, secondary: financrrTheme.primaryAccentColor, brightness: brightness),
        textTheme: ThemeData().textTheme.copyWith(
              displayLarge: defaultStyle.copyWith(fontSize: 57, fontWeight: FontWeight.w400),
              displayMedium: defaultStyle.copyWith(fontSize: 45, fontWeight: FontWeight.w400),
              displaySmall: defaultStyle.copyWith(fontSize: 36, fontWeight: FontWeight.w400),
              headlineLarge: defaultStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w400),
              headlineMedium: defaultStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w400),
              headlineSmall: defaultStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w400),
              titleLarge: defaultStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
              titleMedium: defaultStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              titleSmall: defaultStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: defaultStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
              bodyMedium: defaultStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
              bodySmall: defaultStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
              labelLarge: defaultStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              labelMedium: defaultStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              labelSmall: defaultStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
            ),
        drawerTheme: ThemeData().drawerTheme.copyWith(backgroundColor: financrrTheme.primaryBackgroundColor));
  }
}

@immutable
class FinancrrTheme extends ThemeExtension<FinancrrTheme> {
  /// The path for this themes' logo (variation).
  final String? logoPath;

  final Color primaryAccentColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;

  const FinancrrTheme(
      {required this.logoPath,
      required this.primaryAccentColor,
      required this.primaryTextColor,
      required this.secondaryTextColor,
      required this.primaryBackgroundColor,
      required this.secondaryBackgroundColor});

  @override
  ThemeExtension<FinancrrTheme> copyWith(
      {String? logoPath,
      Color? primaryAccentColor,
      Color? primaryTextColor,
      Color? secondaryTextColor,
      Color? primaryBackgroundColor,
      Color? secondaryBackgroundColor}) {
    return FinancrrTheme(
        logoPath: logoPath ?? this.logoPath,
        primaryAccentColor: primaryAccentColor ?? this.primaryAccentColor,
        primaryTextColor: primaryTextColor ?? this.primaryTextColor,
        secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
        primaryBackgroundColor: primaryBackgroundColor ?? this.primaryBackgroundColor,
        secondaryBackgroundColor: secondaryBackgroundColor ?? this.secondaryBackgroundColor);
  }

  @override
  ThemeExtension<FinancrrTheme> lerp(covariant ThemeExtension<FinancrrTheme>? other, double t) {
    if (other is! FinancrrTheme) {
      return this;
    }
    return FinancrrTheme(
        logoPath: logoPath,
        primaryAccentColor: Color.lerp(primaryAccentColor, other.primaryAccentColor, t)!,
        primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
        secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
        primaryBackgroundColor: Color.lerp(primaryBackgroundColor, other.primaryBackgroundColor, t)!,
        secondaryBackgroundColor: Color.lerp(secondaryBackgroundColor, other.secondaryBackgroundColor, t)!);
  }
}
