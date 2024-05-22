import 'package:flutter/cupertino.dart';
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(

          // TODO: add primary contrast color
          // TODO: fix radio button radius
          // TODO: fix text size

          shape: BoxShape.circle,
          color: value ? theme.financrrExtension.primary : theme.financrrExtension.backgroundTone1,
          border: Border.all(
            color: theme.financrrExtension.backgroundTone2,
            width: 3,
          ),
        ),
        duration: const Duration(milliseconds: 200),
        child: value ? Icon(Icons.check, color: theme.financrrExtension.font) : null,
      ),
    );
  }
}