import 'package:financrr_frontend/modules/settings/models/themes/app_theme.model.dart';
import 'package:flutter/material.dart';

import 'app_color.model.dart';

extension AppThemeExtension on AppTheme {
  FinancrrAppThemeExtension get financrrExtension =>
      themeData.extensions[FinancrrAppThemeExtension] as FinancrrAppThemeExtension;
}

class FinancrrAppThemeExtension extends ThemeExtension<FinancrrAppThemeExtension> {
  final Color primary;
  final Color error;
  final Color surface;
  final Color surfaceVariant1;
  final Color surfaceVariant2;
  final Color surfaceVariant3;
  final Color onPrimary;
  final Color onError;
  final Color onSurface;

  const FinancrrAppThemeExtension(
      {required this.primary,
      required this.error,
      required this.surface,
      required this.surfaceVariant1,
      required this.surfaceVariant2,
      required this.surfaceVariant3,
      required this.onPrimary,
      required this.onError,
      required this.onSurface});

  static FinancrrAppThemeExtension? tryFromJson(Map<String, dynamic> json) {
    final AppColor? primary = AppColor.tryFromJson(json['primary']);
    final AppColor? error = AppColor.tryFromJson(json['error']);
    final AppColor? surface = AppColor.tryFromJson(json['surface']);
    final AppColor? surfaceVariant1 = AppColor.tryFromJson(json['surface_variant1']);
    final AppColor? surfaceVariant2 = AppColor.tryFromJson(json['surface_variant2']);
    final AppColor? surfaceVariant3 = AppColor.tryFromJson(json['surface_variant3']);
    final AppColor? onPrimary = AppColor.tryFromJson(json['on_primary']);
    final AppColor? onError = AppColor.tryFromJson(json['on_error']);
    final AppColor? onSurface = AppColor.tryFromJson(json['on_surface']);
    if (primary == null ||
        error == null ||
        surface == null ||
        surfaceVariant1 == null ||
        surfaceVariant2 == null ||
        surfaceVariant3 == null ||
        onPrimary == null ||
        onError == null ||
        onSurface == null) {
      throw StateError('All colors must be set!');
    }
    return FinancrrAppThemeExtension(
      primary: primary.toColor(json),
      error: error.toColor(json),
      surface: surface.toColor(json),
      surfaceVariant1: surfaceVariant1.toColor(json),
      surfaceVariant2: surfaceVariant2.toColor(json),
      surfaceVariant3: surfaceVariant3.toColor(json),
      onPrimary: onPrimary.toColor(json),
      onError: onError.toColor(json),
      onSurface: onSurface.toColor(json),
    );
  }

  @override
  ThemeExtension<FinancrrAppThemeExtension> copyWith(
      {Color? primary,
      Color? error,
      Color? surface,
      Color? surfaceVariant1,
      Color? surfaceVariant2,
      Color? surfaceVariant3,
      Color? onPrimary,
      Color? onError,
      Color? onSurface}
      ) {
    return FinancrrAppThemeExtension(
      primary: primary ?? this.primary,
      error: error ?? this.error,
      surface: surface ?? this.surface,
      surfaceVariant1: surfaceVariant1 ?? this.surfaceVariant1,
      surfaceVariant2: surfaceVariant2 ?? this.surfaceVariant2,
      surfaceVariant3: surfaceVariant3 ?? this.surfaceVariant3,
      onPrimary: onPrimary ?? this.onPrimary,
      onError: onError ?? this.onError,
      onSurface: onSurface ?? this.onSurface,
    );
  }

  @override
  ThemeExtension<FinancrrAppThemeExtension> lerp(covariant FinancrrAppThemeExtension? other, double t) {
    if (other == null) {
      return this;
    }
    return FinancrrAppThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      error: Color.lerp(error, other.error, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant1: Color.lerp(surfaceVariant1, other.surfaceVariant1, t)!,
      surfaceVariant2: Color.lerp(surfaceVariant2, other.surfaceVariant2, t)!,
      surfaceVariant3: Color.lerp(surfaceVariant3, other.surfaceVariant3, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
    );
  }
}
