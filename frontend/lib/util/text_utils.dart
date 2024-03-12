import 'package:flutter/material.dart';

class AppTextStyles {
  final AppTextStyle displayLarge;
  final AppTextStyle displayMedium;
  final AppTextStyle displaySmall;

  final AppTextStyle headlineLarge;
  final AppTextStyle headlineMedium;
  final AppTextStyle headlineSmall;

  final AppTextStyle titleLarge;
  final AppTextStyle titleMedium;
  final AppTextStyle titleSmall;

  final AppTextStyle labelLarge;
  final AppTextStyle labelMedium;
  final AppTextStyle labelSmall;

  final AppTextStyle bodyLarge;
  final AppTextStyle bodyMedium;
  final AppTextStyle bodySmall;

  final ThemeData themeData;
  final TextTheme textTheme;

  AppTextStyles._(this.themeData, this.textTheme)
      : displayLarge = AppTextStyle._('displayLarge', themeData, textTheme.displayLarge!),
        displayMedium = AppTextStyle._('displayMedium', themeData, textTheme.displayMedium!),
        displaySmall = AppTextStyle._('displaySmall', themeData, textTheme.displaySmall!),
        headlineLarge = AppTextStyle._('headlineLarge', themeData, textTheme.headlineLarge!),
        headlineMedium = AppTextStyle._('headlineMedium', themeData, textTheme.headlineMedium!),
        headlineSmall = AppTextStyle._('headlineSmall', themeData, textTheme.headlineSmall!),
        titleLarge = AppTextStyle._('titleLarge', themeData, textTheme.titleLarge!),
        titleMedium = AppTextStyle._('titleMedium', themeData, textTheme.titleMedium!),
        titleSmall = AppTextStyle._('titleSmall', themeData, textTheme.titleSmall!),
        labelLarge = AppTextStyle._('labelLarge', themeData, textTheme.labelLarge!),
        labelMedium = AppTextStyle._('labelMedium', themeData, textTheme.labelMedium!),
        labelSmall = AppTextStyle._('labelSmall', themeData, textTheme.labelSmall!),
        bodyLarge = AppTextStyle._('bodyLarge', themeData, textTheme.bodyLarge!),
        bodyMedium = AppTextStyle._('bodyMedium', themeData, textTheme.bodyMedium!),
        bodySmall = AppTextStyle._('bodySmall', themeData, textTheme.bodySmall!);

  static AppTextStyles of(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return AppTextStyles._(themeData, themeData.textTheme);
  }
}

class AppTextStyle {
  final String name;
  final ThemeData themeData;
  final TextStyle textStyle;

  const AppTextStyle._(this.name, this.themeData, this.textStyle);

  TextStyle style(
      {Color? color, FontStyle? fontStyle, FontWeight? fontWeightOverride, double? fontSizeOverride, double? height}) {
    return textStyle.copyWith(
        color: color, fontWeight: fontWeightOverride, fontSize: fontSizeOverride, fontStyle: fontStyle, height: height);
  }

  Widget text(String text,
      {Color? color,
      TextAlign? textAlign,
      TextOverflow? overflow,
      FontStyle? fontStyle,
      FontWeight? fontWeightOverride,
      double? fontSizeOverride,
      double? height}) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      overflow: overflow,
      style: style(
          color: color,
          fontStyle: fontStyle,
          fontWeightOverride: fontWeightOverride,
          fontSizeOverride: fontSizeOverride,
          height: height),
    );
  }

  Widget editableText(TextEditingController controller, FocusNode focusNode,
      {Color? color,
      TextAlign? textAlign,
      FontStyle? fontStyle,
      FontWeight? fontWeightOverride,
      double? fontSizeOverride,
      double? height}) {
    return EditableText(
      controller: controller,
      focusNode: focusNode,
      cursorColor: color ?? textStyle.color!,
      backgroundCursorColor: color ?? textStyle.color!,
      textAlign: textAlign ?? TextAlign.left,
      style: style(
          color: color,
          fontStyle: fontStyle,
          fontWeightOverride: fontWeightOverride,
          fontSizeOverride: fontSizeOverride,
          height: height),
    );
  }
}
