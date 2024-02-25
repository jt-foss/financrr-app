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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: widget.navigationShell,
      ),
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
