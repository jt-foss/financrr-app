import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../routing/app_router.dart';

@RoutePage()
class TabControllerPage extends StatefulWidget {
  const TabControllerPage({super.key});

  static TabControllerPageState? maybeOf(BuildContext context) => context.findAncestorStateOfType<TabControllerPageState>();

  @override
  State<StatefulWidget> createState() => TabControllerPageState();
}

class TabControllerPageState extends State<TabControllerPage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
        routes: const [
          DashboardRoute(),
          AccountsOverviewRoute(),
          SettingsRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return PopScope(
            canPop: tabsRouter.activeIndex == 0,
            onPopInvoked: (didPop) => !didPop ? tabsRouter.setActiveIndex(0) : null,
            child: LayoutBuilder(
              builder: (builder, constraints) {
                // TODO: !!!
                const medium = 600;
                final Widget? bottom;
                final Widget body;
                if (constraints.maxWidth < medium) {
                  // Normal phone width
                  bottom = _buildNavigationBar(tabsRouter);
                  body = child;
                } else {
                  // Medium tablet width
                  bottom = null;
                  body = Row(
                    children: [
                      _buildNavigationRail(tabsRouter),
                      Expanded(child: child),
                    ],
                  );
                }
                return Scaffold(
                  body: HeroControllerScope(
                    controller: HeroController(),
                    child: body,
                  ),
                  bottomNavigationBar: bottom,
                );
              },
            ),
          );
        });
  }

  NavigationBar _buildNavigationBar(TabsRouter router) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Accounts',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard_outlined),
          selectedIcon: Icon(Icons.leaderboard_rounded),
          label: 'Statistics',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
      selectedIndex: router.activeIndex,
      onDestinationSelected: (index) => router.setActiveIndex(index),
    );
  }

  NavigationRail _buildNavigationRail(TabsRouter router) {
    return NavigationRail(
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded),
          label: Text('Accounts'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.leaderboard_outlined),
          selectedIcon: Icon(Icons.leaderboard_rounded),
          label: Text('Statistics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
      ],
      selectedIndex: router.activeIndex,
      onDestinationSelected: (index) => router.setActiveIndex(index),
    );
  }
}
