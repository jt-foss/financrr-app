import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:flutter/material.dart';

import '../util/text_utils.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? hintText;
  final bool hideable;

  const CustomTextField({super.key, required this.controller, this.prefixIcon, this.hintText, this.hideable = false});

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focus = FocusNode();

  late final FinancrrTheme _financrrTheme = context.financrrTheme;
  late final AppTextStyles _textStyles = AppTextStyles.of(context);

  bool _selected = false;
  late bool _hidden = widget.hideable;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _selected = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      child: AnimatedContainer(
        decoration: BoxDecoration(
            color: _selected ? _financrrTheme.primaryBackgroundColor : _financrrTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: _selected ? _financrrTheme.primaryAccentColor : _financrrTheme.secondaryBackgroundColor, width: 3)),
        duration: const Duration(milliseconds: 100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: TextFormField(
            focusNode: _focus,
            controller: widget.controller,
            obscureText: _hidden,
            style: _textStyles.bodyMedium.style(
                color: !_selected ? null : _financrrTheme.primaryAccentColor,
                fontWeightOverride: _selected ? FontWeight.w700 : FontWeight.w600),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _selected ? null : widget.hintText,
                hintStyle: _textStyles.bodyMedium.style(fontWeightOverride: FontWeight.w600),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon,
                        color: !_selected ? _financrrTheme.primaryTextColor : _financrrTheme.primaryAccentColor)
                    : null,
                suffixIcon: !widget.hideable
                    ? null
                    : InkWell(
                        child: Icon(_hidden ? Icons.visibility : Icons.visibility_off,
                            color: !_selected ? _financrrTheme.primaryTextColor : _financrrTheme.primaryAccentColor),
                        onTap: () => setState(() => _hidden = !_hidden),
                      )),
          ),
        ),
      ),
    );
  }
}
