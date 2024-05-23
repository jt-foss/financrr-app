import 'dart:async';

import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_navigation_bar.dart';
import 'app_navigation_rail.dart';

class ScaffoldNavBarShell extends StatefulHookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldNavBarShell({super.key, required this.navigationShell});

  static ScaffoldNavBarShellState? maybeOf(BuildContext context) => context.findAncestorStateOfType<ScaffoldNavBarShellState>();

  @override
  ConsumerState<ScaffoldNavBarShell> createState() => ScaffoldNavBarShellState();
}

class ScaffoldNavBarShellState extends ConsumerState<ScaffoldNavBarShell> {
  bool _isHovered = false;
  Timer? _hoverTimer;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

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
                      onEnter: (event) =>
                          _hoverTimer = Timer(const Duration(milliseconds: 1000), () => setState(() => _isHovered = true)),
                      onExit: (event) {
                        _hoverTimer?.cancel();
                        setState(() => _isHovered = false);
                      },
                      child: FinancrrNavigationRail(
                          destinations: _getDestinations(),
                          extended: context.isWidescreen || _isHovered,
                          onDestinationSelected: (index) => goToBranch(index),
                          selectedIndex: widget.navigationShell.currentIndex),
                    );
                  }),
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: theme.financrrExtension.surfaceVariant1, width: 3),
                          ),
                        ),
                        child: shell),
                  )
                ],
              ),
      ),
      appBar: AppBar(
        backgroundColor: theme.financrrExtension.surface,
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
              destinations: _getDestinations())
          : null,
    );
  }

  List<NavDestination> _getDestinations() => const [
        NavDestination(
            iconData: Icons.dashboard_outlined, selectedIconData: Icons.dashboard_rounded, label: L10nKey.navigationDashboard),
        NavDestination(
            iconData: Icons.account_balance_wallet_outlined,
            selectedIconData: Icons.account_balance_wallet_rounded,
            label: L10nKey.navigationAccounts),
        NavDestination(
            iconData: Icons.leaderboard_outlined,
            selectedIconData: Icons.leaderboard_rounded,
            label: L10nKey.navigationStatistics),
        NavDestination(
            iconData: Icons.settings_outlined, selectedIconData: Icons.settings_rounded, label: L10nKey.navigationSettings),
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
