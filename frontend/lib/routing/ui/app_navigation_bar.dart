import 'package:financrr_frontend/routing/ui/app_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/settings/providers/theme.provider.dart';

class FinancrrNavigationBar extends ConsumerWidget {
  final List<NavDestination> destinations;
  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  const FinancrrNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);

    buildNavBarItem(NavDestination destination, int index) {
      final bool isSelected = index == selectedIndex;
      return GestureDetector(
        onTap: () => onDestinationSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 3, color: isSelected ? theme.financrrExtension.primary : Colors.transparent),
                color: isSelected ? null : theme.financrrExtension.surfaceVariant1,
              ),
              child: Icon(isSelected
                  ? destination.selectedIconData ?? destination.iconData
                  : destination.iconData,
                  color: isSelected ? theme.financrrExtension.primary : theme.financrrExtension.surfaceVariant3),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: destination.label.toText(
                  style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.financrrExtension.primary : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              )),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(.1)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, top: 10, left: 10, right: 10),
        child: Row(
          children: [
            for (NavDestination destination in destinations)
              Expanded(child: buildNavBarItem(destination, destinations.indexOf(destination)))
          ],
        ),
      ),
    );
  }
}
