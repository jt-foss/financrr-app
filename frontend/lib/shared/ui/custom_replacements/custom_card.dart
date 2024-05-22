import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrCard extends StatefulHookConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final bool hoverable;
  final Function()? onTap;

  const FinancrrCard({super.key, required this.child, this.padding, this.borderColor, this.hoverable = true, this.onTap});

  @override
  ConsumerState<FinancrrCard> createState() => _OutlineCardState();
}

class _OutlineCardState extends ConsumerState<FinancrrCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return MouseRegion(
      onHover: (_) {
        if (!widget.hoverable) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!widget.hoverable) return;
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? theme.financrrExtension.surfaceVariant1.withOpacity(.5) : null,
            border: Border.all(color: widget.borderColor ?? theme.financrrExtension.surfaceVariant1, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
