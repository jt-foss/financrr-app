import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:flutter/material.dart';

import '../util/text_utils.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color Function(FinancrrTheme) buttonBackgroundColor;
  final Color Function(FinancrrTheme) buttonTextColor;
  final bool hasBorder;
  final Color Function(FinancrrTheme)? borderColor;
  final bool alignLeft;
  final String Function(BuildContext)? subText;
  final Function()? onPressed;

  CustomButton.primary({
    super.key,
    required this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
  })  : buttonBackgroundColor = ((theme) => theme.primaryButtonColor),
        buttonTextColor = ((theme) => theme.primaryButtonTextColor),
        hasBorder = false,
        borderColor = null,
        alignLeft = false,
        subText = null;

  CustomButton.secondary({
    super.key,
    required this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressed,
  })  : buttonBackgroundColor = ((theme) => theme.primaryBackgroundColor),
        buttonTextColor = ((theme) => theme.primaryButtonColor),
        hasBorder = true,
        borderColor = ((theme) => theme.primaryButtonColor),
        alignLeft = false,
        subText = null;

  CustomButton.tertiary({super.key, required this.text, this.prefixIcon, this.suffixIcon, this.onPressed, this.subText})
      : buttonBackgroundColor = ((theme) => theme.secondaryBackgroundColor),
        buttonTextColor = ((theme) => theme.primaryTextColor),
        hasBorder = false,
        borderColor = null,
        alignLeft = true;

  @override
  State<StatefulWidget> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late final FinancrrTheme _financrrTheme = context.financrrTheme;
  late final AppTextStyles _textStyles = AppTextStyles.of(context);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: widget.onPressed,
      child: Container(
          decoration: BoxDecoration(
              color: widget.buttonBackgroundColor(_financrrTheme),
              borderRadius: BorderRadius.circular(15),
              border: widget.hasBorder ? Border.all(color: widget.borderColor!(_financrrTheme), width: 3) : null),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: widget.alignLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(widget.prefixIcon, color: widget.buttonTextColor(_financrrTheme)),
                ),
              widget.alignLeft ? buildLeftAlignedLayout() : buildCenteredLayout(),
              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Icon(widget.suffixIcon, color: widget.buttonTextColor(_financrrTheme)),
                ),
            ],
          )),
    );
  }

  Widget buildCenteredLayout() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 17),
        child: _textStyles.bodyMedium
            .text(widget.text, color: widget.buttonTextColor(_financrrTheme), fontWeightOverride: FontWeight.w700),
      ),
    );
  }

  Widget buildLeftAlignedLayout() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textStyles.bodyMedium
                .text(widget.text, color: widget.buttonTextColor(_financrrTheme), fontWeightOverride: FontWeight.w700),
            if (widget.subText != null)
              _textStyles.labelSmall.text(widget.subText!(context),
                  color: widget.buttonTextColor(_financrrTheme), fontWeightOverride: FontWeight.w700),
          ],
        ),
      ),
    );
  }
}
