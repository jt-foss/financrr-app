import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrRadioButton extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const FinancrrRadioButton({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? theme.financrrExtension.primary : theme.financrrExtension.backgroundTone1,
          border: Border.all(
            color: !value ? theme.financrrExtension.backgroundTone2 : theme.financrrExtension.primary,
            width: 3,
          ),
        ),
        duration: const Duration(milliseconds: 200),
        child: Icon(Icons.check, color: value ? theme.financrrExtension.primaryContrast : Colors.transparent, size: 20),
      ),
    );
  }
}