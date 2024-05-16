import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/settings/providers/theme.provider.dart';

class TextCircleAvatar extends ConsumerWidget {
  final String text;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const TextCircleAvatar({
    super.key,
    required this.text,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.financrrExtension.background,
        border: Border.all(width: 3, color: theme.financrrExtension.backgroundTone1),
      ),
      child: Center(
        child: Text(
          text.isEmpty ? '?' : text.substring(0, min(text.length, 3)).toUpperCase(),
          style: theme.textTheme.titleSmall?.copyWith(
              color: textColor ?? theme.financrrExtension.primary, fontWeight: FontWeight.bold, fontSize: radius / 1.75),
        ),
      ),
    );
  }
}
