import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrTextButton extends StatefulHookConsumerWidget {
  final Widget label;
  final Widget? icon;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const FinancrrTextButton({super.key, required this.label, this.icon, this.borderColor, this.onPressed});

  @override
  ConsumerState<FinancrrTextButton> createState() => _FinancrrTextButtonState();
}

class _FinancrrTextButtonState extends ConsumerState<FinancrrTextButton> {
  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    style(Widget child) {
      if (child is Text) {
        return Text(child.data ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.financrrExtension.primary));
      }
      if (child is Icon) {
        return Icon(child.icon, color: theme.financrrExtension.primary, size: child.size);
      }
      return child;
    }

    return FinancrrCard(
      onTap: widget.onPressed,
      borderColor: widget.borderColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            style(widget.icon!),
            const SizedBox(width: 5),
          ],
          style(widget.label),
        ],
      ),
    );
  }
}
