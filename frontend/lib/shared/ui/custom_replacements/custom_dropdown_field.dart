import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/l10n_utils.dart';

class FinancrrDropdownItem<T> {
  final String label;
  final T value;

  const FinancrrDropdownItem({
    required this.label,
    required this.value,
  });
}

class FinancrrDropdownField<T> extends StatefulHookConsumerWidget {
  final L10nKey label;
  final L10nKey? hint;
  final String? Function(String?)? validator;
  final T? value;
  final List<FinancrrDropdownItem<T>>? items;
  final Widget? prefixIcon;
  final void Function(T?)? onChanged;
  final bool required;

  const FinancrrDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.validator,
    this.value,
    this.items,
    this.prefixIcon,
    this.onChanged,
    this.required = false,
  });

  @override
  ConsumerState<FinancrrDropdownField<T>> createState() => _FinancrrDropdownFieldState<T>();
}

class _FinancrrDropdownFieldState<T> extends ConsumerState<FinancrrDropdownField<T>> {
  late final TextEditingController _controller = TextEditingController(text: widget.value?.toString());
  String? _error;

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    final TextStyle? labelStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    showBottomSheet(List<FinancrrDropdownItem<T>> items) async {
      return await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.financrrExtension.surfaceVariant2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final FinancrrDropdownItem<T> item = items[index];
                      return FinancrrCard(
                        onTap: () => Navigator.pop(context, item),
                        padding: const EdgeInsets.all(10),
                        child: Text(item.label, style: theme.textTheme.bodyLarge),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: widget.label.toText(style: labelStyle)),
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
            controller: _controller,
            onTap: () async {
              if (widget.items == null || widget.items!.isEmpty) return;
              FinancrrDropdownItem<T>? result = await showBottomSheet(widget.items!);
              if (result != null) {
                _controller.text = result.label;
                _error = widget.validator?.call(result.label);
                widget.onChanged?.call(result.value);
                setState(() {});
              }
            },
            validator: (value) {
              if (widget.validator == null) return null;
              final String? error = widget.validator!.call(value);
              setState(() => _error = error);
              // return empty string to hide error message
              return error != null ? '' : null;
            },
            decoration: InputDecoration(
                prefixIcon: widget.prefixIcon,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                hintText: widget.hint?.toString(),
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500, color: theme.financrrExtension.surfaceVariant2),
                errorStyle: const TextStyle(height: 0),
                border: InputBorder.none),
            readOnly: true,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 5),
          Text(_error!, style: labelStyle?.copyWith(color: theme.financrrExtension.error))
        ],
      ],
    );
  }
}
