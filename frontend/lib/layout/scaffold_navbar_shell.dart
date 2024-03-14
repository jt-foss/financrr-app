import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldNavBarShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldNavBarShell({super.key, required this.navigationShell});

  static ScaffoldNavBarShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<ScaffoldNavBarShellState>();

  @override
  State<StatefulWidget> createState() => ScaffoldNavBarShellState();
}

class ScaffoldNavBarShellState extends State<ScaffoldNavBarShell> {
  static const List<NavigationDestination> _navBarDestinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Transactions',
    ),
    NavigationDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard),
      label: 'Statistics',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  static const List<NavigationRailDestination> _navRailDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: Text('Transactions'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard),
      label: Text('Statistics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: isMobile
            ? widget.navigationShell
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
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: widget.navigationShell,
                    ),
                  )
                ],
              ),
      ),
      appBar: AppBar(),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              onDestinationSelected: (index) => goToBranch(index),
              selectedIndex: widget.navigationShell.currentIndex,
              destinations: _navBarDestinations)
          : null,
    );
  }

  // Resets the current branch. Useful for popping an unknown amount of pages.
  void resetLocation() {
    widget.navigationShell.goBranch(widget.navigationShell.currentIndex, initialLocation: true);
  }

  /// Jumps to the corresponding [StatefulShellBranch], based on the specified index.
  void goToBranch(int index) {
    widget.navigationShell.goBranch(index, initialLocation: index != widget.navigationShell.currentIndex);
  }
}
