import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrCircleAvatar extends ConsumerWidget {
  final Widget? child;
  final String? text;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const FinancrrCircleAvatar({
    super.key,
    required this.child,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  }) : text = null;

  const FinancrrCircleAvatar.text({
    super.key,
    required this.text,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  }) : child = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);

    buildText(String text) {
      return Text(
        text.isEmpty ? '' : text.substring(0, min(text.length, 3)).toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
            color: textColor ?? theme.financrrExtension.primary, fontWeight: FontWeight.bold, fontSize: radius / 1.75),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.financrrExtension.surface,
        border: Border.all(width: 3, color: borderColor ?? theme.financrrExtension.surfaceVariant1),
      ),
      child: Center(
        child: child ?? buildText(text ?? ''),
      ),
    );
  }
}
