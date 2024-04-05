import 'dart:math';

import 'package:flutter/material.dart';

class TextCircleAvatar extends StatelessWidget {
  final String text;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;

  const TextCircleAvatar({
    super.key,
    required this.text,
    this.radius,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        text.isEmpty ? '?' : text.substring(0, min(text.length, 2)).toUpperCase(),
        style: TextStyle(color: textColor),
      ),
    );
  }
}
