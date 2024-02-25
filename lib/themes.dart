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
        primaryHighlightColor: Color(0xFF2C03E6),
        primaryTextColor: Color(0xFF000000),
        secondaryTextColor: Color(0xFF1C1B1F),
        primaryBackgroundColor: Color(0xFFFFFFFF),
        secondaryBackgroundColor: Color(0xFFEBEBEB),
        primaryButtonColor: Color(0xFF2C03E6),
        primaryButtonTextColor: Color(0xFFFFFFFF));
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
        primaryAccentColor: Color(0xFF578BFA),
        primaryHighlightColor: Color(0xFFFFFFFF),
        primaryTextColor: Color(0xFFFFFFFF),
        secondaryTextColor: Color(0xFFA1B1D1),
        primaryBackgroundColor: Color(0xFF132852),
        secondaryBackgroundColor: Color(0xFF3A5384),
        primaryButtonColor: Color(0xFFFFFFFF),
        primaryButtonTextColor: Color(0xFF000000));
    return AppTheme(
        id: 2,
        name: (_) => 'Dark',
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
  final Color primaryHighlightColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color primaryButtonColor;
  final Color primaryButtonTextColor;

  const FinancrrTheme(
      {required this.logoPath,
      required this.primaryAccentColor,
      required this.primaryHighlightColor,
      required this.primaryTextColor,
      required this.secondaryTextColor,
      required this.primaryBackgroundColor,
      required this.secondaryBackgroundColor,
      required this.primaryButtonColor,
      required this.primaryButtonTextColor});

  @override
  ThemeExtension<FinancrrTheme> copyWith(
      {String? logoPath,
      Color? primaryAccentColor,
      Color? primaryHighlightColor,
      Color? primaryTextColor,
      Color? secondaryTextColor,
      Color? primaryBackgroundColor,
      Color? secondaryBackgroundColor,
      Color? primaryButtonColor,
      Color? primaryButtonTextColor}) {
    return FinancrrTheme(
        logoPath: logoPath ?? this.logoPath,
        primaryAccentColor: primaryAccentColor ?? this.primaryAccentColor,
        primaryHighlightColor: primaryHighlightColor ?? this.primaryHighlightColor,
        primaryTextColor: primaryTextColor ?? this.primaryTextColor,
        secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
        primaryBackgroundColor: primaryBackgroundColor ?? this.primaryBackgroundColor,
        secondaryBackgroundColor: secondaryBackgroundColor ?? this.secondaryBackgroundColor,
        primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
        primaryButtonTextColor: primaryButtonTextColor ?? this.primaryButtonTextColor);
  }

  @override
  ThemeExtension<FinancrrTheme> lerp(covariant ThemeExtension<FinancrrTheme>? other, double t) {
    if (other is! FinancrrTheme) {
      return this;
    }
    return FinancrrTheme(
        logoPath: logoPath,
        primaryAccentColor: Color.lerp(primaryAccentColor, other.primaryAccentColor, t)!,
        primaryHighlightColor: Color.lerp(primaryHighlightColor, other.primaryHighlightColor, t)!,
        primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
        secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
        primaryBackgroundColor: Color.lerp(primaryBackgroundColor, other.primaryBackgroundColor, t)!,
        secondaryBackgroundColor: Color.lerp(secondaryBackgroundColor, other.secondaryBackgroundColor, t)!,
        primaryButtonColor: Color.lerp(primaryButtonColor, other.primaryButtonColor, t)!,
        primaryButtonTextColor: Color.lerp(primaryButtonTextColor, other.primaryButtonTextColor, t)!);
  }
}
