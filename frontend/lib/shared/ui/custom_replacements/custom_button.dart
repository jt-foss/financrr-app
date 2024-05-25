import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrButton extends StatefulHookConsumerWidget {
  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const FinancrrButton({super.key, required this.text, this.icon, this.onPressed, this.isLoading = false});

  @override
  ConsumerState<FinancrrButton> createState() => _FinancrrTextButtonState();
}

class _FinancrrTextButtonState extends ConsumerState<FinancrrButton> {
  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    return FinancrrCard(
      onTap: widget.onPressed,
      filled: true,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.isLoading
            ? [CircularProgressIndicator(color: theme.financrrExtension.onPrimary)]
            : [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 5),
                ],
                Text(widget.text,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold, color: theme.financrrExtension.onPrimary)),
              ],
      ),
    );
  }
}
