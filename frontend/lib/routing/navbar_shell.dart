import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldNavBarShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldNavBarShell({super.key, required this.navigationShell});

  static ScaffoldNavBarShellState? maybeOf(BuildContext context) => context.findAncestorStateOfType<ScaffoldNavBarShellState>();

  @override
  State<StatefulWidget> createState() => ScaffoldNavBarShellState();
}

class ScaffoldNavBarShellState extends State<ScaffoldNavBarShell> {
  static final List<NavigationDestination> _navBarDestinations = [
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
      label: L10nKey.navigationStatistics.toString()
    ),
    NavigationDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings_rounded),
      label: L10nKey.navigationSettings.toString()
    ),
  ];

  static final List<NavigationRailDestination> _navRailDestinations = [
    NavigationRailDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard_rounded),
      label: L10nKey.navigationDashboard.toText(),
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
                          destinations: _navRailDestinations,
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
          child: L10nKey.brandName.toText(),
        ),
        centerTitle: isMobile,
        leading: canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              onDestinationSelected: (index) => goToBranch(index),
              selectedIndex: widget.navigationShell.currentIndex,
              destinations: _navBarDestinations)
          : null,
    );
  }

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
