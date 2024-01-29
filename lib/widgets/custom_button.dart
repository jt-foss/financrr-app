import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:flutter/material.dart';

import '../util/text_utils.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final double? width;
  final IconData? prefixIcon;
  final bool secondary;
  final Function()? onPressed;

  const CustomButton({super.key, required this.text, this.width, this.prefixIcon, this.secondary = false, this.onPressed});

  @override
  State<StatefulWidget> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late final FinancrrTheme _financrrTheme = context.financrrTheme;
  late final AppTextStyles _textStyles = AppTextStyles.of(context);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
            color: widget.secondary ? _financrrTheme.primaryBackgroundColor : _financrrTheme.primaryAccentColor,
            borderRadius: BorderRadius.circular(15),
            border: widget.secondary ? Border.all(color: _financrrTheme.primaryAccentColor, width: 3) : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.prefixIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Icon(widget.prefixIcon, size: 20,
                    color: widget.secondary ? _financrrTheme.primaryAccentColor : _financrrTheme.primaryBackgroundColor),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: _textStyles.bodyMedium.text(widget.text,
                  color: widget.secondary ? _financrrTheme.primaryAccentColor : _financrrTheme.primaryBackgroundColor,
                  fontWeightOverride: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
