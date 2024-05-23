import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../modules/settings/providers/theme.provider.dart';

class FinancrrCard extends StatefulHookConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? borderRadius;
  final bool hoverable;
  final bool filled;
  final Function()? onTap;

  const FinancrrCard({super.key, required this.child, this.padding, this.borderColor, this.borderRadius, this.hoverable = true, this.filled = false, this.onTap});

  @override
  ConsumerState<FinancrrCard> createState() => _OutlineCardState();
}

class _OutlineCardState extends ConsumerState<FinancrrCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    getCardColor() {
      if (widget.filled) {
        return theme.financrrExtension.primary.withOpacity(_hovered ? .8 : 1);
      }
      if (_hovered) {
        return theme.financrrExtension.surfaceVariant1.withOpacity(.5);
      }
      return null;
    }

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
        onLongPress: () => setState(() => _hovered = true),
        onLongPressEnd: (_) {
          setState(() => _hovered = false);
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: getCardColor(),
            border: Border.all(color: widget.borderColor ?? theme.financrrExtension.surfaceVariant1, width: 3),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
