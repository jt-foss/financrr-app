import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrTextField extends StatefulHookConsumerWidget {
  final L10nKey label;
  final TextEditingController? controller;
  final L10nKey? hint;
  final String? status;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final bool required;
  final String? initialValue;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const FinancrrTextField(
      {super.key,
      required this.label,
      this.controller,
      this.hint,
      this.status,
      this.prefixIcon,
      this.suffixIcon,
      this.obscureText = false,
      this.readOnly = false,
      this.required = false,
      this.initialValue,
      this.onTap,
      this.autofillHints,
      this.validator,
      this.onChanged,
      this.inputFormatters,
      this.keyboardType});

  @override
  ConsumerState<FinancrrTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends ConsumerState<FinancrrTextField> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    final TextStyle? labelStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: widget.label.toText(baseStyle: labelStyle)),
            if (widget.required)
              Text(' *', style: labelStyle?.copyWith(fontWeight: FontWeight.w600, color: theme.financrrExtension.error)),
          ],
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: _error != null ? theme.financrrExtension.error : theme.financrrExtension.surfaceVariant1, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: widget.controller,
            autofillHints: widget.autofillHints,
            validator: (value) {
              if (widget.validator == null) return null;
              final String? error = widget.validator!.call(value);
              setState(() => _error = error);
              // return empty string to hide error message
              return error != null ? '' : null;
            },
            decoration: InputDecoration(
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                hintText: widget.hint?.toString(),
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500, color: theme.financrrExtension.surfaceVariant2),
                errorStyle: const TextStyle(height: 0),
                border: InputBorder.none),
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            initialValue: widget.initialValue,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 5),
          Text(_error!, style: labelStyle?.copyWith(color: theme.financrrExtension.error))
        ],
        if (widget.status != null && _error == null) ...[
          const SizedBox(height: 5),
          Text(widget.status!, style: labelStyle?.copyWith(color: theme.financrrExtension.primary)),
        ]
      ],
    );
  }
}
