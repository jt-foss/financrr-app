import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScaffoldNavBarShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldNavBarShell({super.key, required this.navigationShell});

  static ScaffoldNavBarShellState? maybeOf(BuildContext context) => context.findAncestorStateOfType<ScaffoldNavBarShellState>();

  @override
  State<StatefulWidget> createState() => ScaffoldNavBarShellState();
}

class ScaffoldNavBarShellState extends State<ScaffoldNavBarShell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final Widget shell = kIsWeb ? SelectionArea(child: widget.navigationShell) : widget.navigationShell;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: isMobile
            ? shell
            : Row(
                children: [
                  StatefulBuilder(builder: (context, setState) {
                    return MouseRegion(
                      onEnter: (event) => setState(() => _isHovered = true),
                      onExit: (event) => setState(() => _isHovered = false),
                      child: NavigationRail(
                          destinations: _buildNavRailDestinations(),
                          extended: context.isWidescreen || _isHovered,
                          onDestinationSelected: (index) => goToBranch(index),
                          selectedIndex: widget.navigationShell.currentIndex),
                    );
                  }),
                  Expanded(
                    child: shell,
                  )
                ],
              ),
      ),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => resetLocation(index: 0),
          child: const Text('financrr'),
        ),
        centerTitle: isMobile,
        leading: canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      extendBody: true,
      bottomNavigationBar: isMobile
          ? FinancrrNavigationBar(
              onDestinationSelected: (index) => goToBranch(index),
              selectedIndex: widget.navigationShell.currentIndex,
              destinations: _buildNavBarDestinations())
          : null,
    );
  }

  List<NavigationDestination> _buildNavBarDestinations() => [
    NavigationDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard_rounded),
      label: L10nKey.navigationDashboard.toString(),
    ),
    NavigationDestination(
      icon: const Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
      label: L10nKey.navigationAccounts.toString(),
    ),
    NavigationDestination(
      icon: const Icon(Icons.leaderboard_outlined),
      selectedIcon: const Icon(Icons.leaderboard_rounded),
      label: L10nKey.navigationStatistics.toString(),
    ),
    NavigationDestination(
      icon: const Icon(Icons.person_outline_rounded),
      selectedIcon: const Icon(Icons.person_rounded),
      label: L10nKey.navigationSettings.toString(),
    ),
  ];

  List<NavigationRailDestination> _buildNavRailDestinations() => [
    NavigationRailDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard_rounded),
      label: L10nKey.navigationDashboard.toText()
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
      label: L10nKey.navigationAccounts.toText(),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.leaderboard_outlined),
      selectedIcon: const Icon(Icons.leaderboard_rounded),
      label: L10nKey.navigationStatistics.toText(),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings_rounded),
      label: L10nKey.navigationSettings.toText(),
    ),
  ];

  void refresh() => setState(() {});

  bool canPop() {
    final GoRouterState state = GoRouterState.of(context);
    return (state.fullPath ?? state.matchedLocation).characters.where((p0) => p0 == '/').length >= 3;
  }

  // Resets the current branch. Useful for popping an unknown amount of pages.
  void resetLocation({int? index}) {
    widget.navigationShell.goBranch(index ?? widget.navigationShell.currentIndex, initialLocation: true);
  }

  /// Jumps to the corresponding [StatefulShellBranch], based on the specified index.
  void goToBranch(int index) {
    widget.navigationShell.goBranch(index, initialLocation: widget.navigationShell.currentIndex == index);
  }
}

class FinancrrNavigationBar extends ConsumerWidget {
  final List<NavigationDestination> destinations;
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

    Widget buildNavBarItem({required NavigationDestination destination, required int index, bool isSelected = false}) {
      final IconData iconData = (destination.icon as Icon).icon!;
      final IconData selectedIconData = (destination.selectedIcon as Icon).icon ?? iconData;
      return GestureDetector(
        onTap: () => onDestinationSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? null : theme.themeData.primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: isSelected ? theme.themeData.primaryColor : Colors.transparent,
                  width: 4,
                ),
              ),
              child: Icon(isSelected ? selectedIconData : iconData, color: isSelected ? theme.themeData.primaryColor : null),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(destination.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? theme.themeData.primaryColor : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.1)
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, top: 10, left: 10, right: 10),
        child: Row(
          children: [
            for (NavigationDestination destination in destinations)
              Expanded(
                child: buildNavBarItem(
                    destination: destination,
                    index: destinations.indexOf(destination),
                    isSelected: destinations.indexOf(destination) == selectedIndex),
              )
          ],
        ),
      ),
    );
  }
}
