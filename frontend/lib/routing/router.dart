import 'dart:async';

import 'package:financrr_frontend/modules/settings/views/local_storage_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/l10n_settings_page.dart';
import 'package:financrr_frontend/shared/views/splash_page.dart';
import 'package:financrr_frontend/modules/accounts/views/account_create_page.dart';
import 'package:financrr_frontend/modules/settings/views/currency_create_page.dart';
import 'package:financrr_frontend/modules/settings/views/session_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/theme_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/settings_page.dart';
import 'package:financrr_frontend/modules/dashboard/views/dashboard_page.dart';
import 'package:financrr_frontend/shared/views/dummy_page.dart';
import 'package:financrr_frontend/routing/guards/guard.dart';
import 'package:financrr_frontend/routing/guards/login_auth_guard.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../modules/accounts/views/account_edit_page.dart';
import '../modules/accounts/views/account_page.dart';
import '../modules/accounts/views/accounts_overview_page.dart';
import '../modules/auth/pages/login_page.dart';
import '../modules/auth/pages/server_config_page.dart';
import '../modules/settings/views/currency_edit_page.dart';
import '../modules/settings/views/currency_settings_page.dart';
import '../modules/settings/views/log_settings_page.dart';
import '../modules/transactions/views/transaction_create_page.dart';
import '../modules/transactions/views/transaction_edit_page.dart';
import '../modules/transactions/views/transaction_page.dart';
import '../utils/constants.dart';
import 'guards/core_auth_guard.dart';
import 'guards/extra_guard.dart';
import 'navbar_shell.dart';

final Provider<AppRouter> appRouterProvider = Provider((ref) => AppRouter(ref));

class AppRouter {
  final ProviderRef<Object?> ref;

  final CoreAuthGuard _coreAuthGuard = CoreAuthGuard();
  final LoginAuthGuard _loginAuthGuard = LoginAuthGuard();

  AppRouter(this.ref);

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(debugLabel: 'shell');

  late GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      GoRoute(path: '/@me', redirect: (_, __) => DashboardPage.pagePath.path),
      StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ScaffoldNavBarShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(navigatorKey: shellNavigatorKey, routes: [
              GoRoute(
                  path: DashboardPage.pagePath.path,
                  pageBuilder: _defaultBranchPageBuilder(const DashboardPage()),
                  redirect: guards([_coreAuthGuard])),
              ..._shellRoutes(),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AccountsOverviewPage.pagePath.path,
                  pageBuilder: _defaultBranchPageBuilder(const AccountsOverviewPage()),
                  redirect: guards([_coreAuthGuard]),
                  routes: [
                    GoRoute(
                        path: AccountCreatePage.pagePath.path,
                        pageBuilder: _defaultPageBuilder(const AccountCreatePage()),
                        redirect: guards([_coreAuthGuard])),
                    GoRoute(
                        path: AccountPage.pagePath.path,
                        pageBuilder: (context, state) => _buildDefaultPageTransition(
                            context, state, AccountPage(accountId: state.pathParameters['accountId'])),
                        redirect: guards([_coreAuthGuard]),
                        routes: [
                          GoRoute(
                              path: AccountEditPage.pagePath.path,
                              pageBuilder: (context, state) => _buildDefaultPageTransition(
                                  context, state, AccountEditPage(accountId: state.pathParameters['accountId'])),
                              redirect: guards([_coreAuthGuard])),
                          GoRoute(
                              path: TransactionCreatePage.pagePath.path,
                              pageBuilder: (context, state) => _buildDefaultPageTransition(
                                  context, state, TransactionCreatePage(accountId: state.pathParameters['accountId'])),
                              redirect: guards([_coreAuthGuard])),
                          GoRoute(
                              path: TransactionPage.pagePath.path,
                              pageBuilder: (context, state) => _buildDefaultPageTransition(
                                  context,
                                  state,
                                  TransactionPage(
                                      accountId: state.pathParameters['accountId'],
                                      transactionId: state.pathParameters['transactionId'])),
                              redirect: guards([_coreAuthGuard]),
                              routes: [
                                GoRoute(
                                    path: TransactionEditPage.pagePath.path,
                                    pageBuilder: (context, state) => _buildDefaultPageTransition(
                                        context,
                                        state,
                                        TransactionEditPage(
                                            accountId: state.pathParameters['accountId'],
                                            transactionId: state.pathParameters['transactionId'])),
                                    redirect: guards([_coreAuthGuard]))
                              ]),
                        ])
                  ]),
              ..._shellRoutes(),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/@me/statistics',
                  pageBuilder: _defaultBranchPageBuilder(const DummyPage(text: 'coming soon!')),
                  redirect: guards([_coreAuthGuard])),
              ..._shellRoutes(),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: SettingsPage.pagePath.path,
                  pageBuilder: _defaultBranchPageBuilder(const SettingsPage()),
                  redirect: guards([_coreAuthGuard]),
                  routes: [
                    GoRoute(
                        path: ThemeSettingsPage.pagePath.path,
                        pageBuilder: _defaultPageBuilder(const ThemeSettingsPage()),
                        redirect: guards([_coreAuthGuard])),
                    GoRoute(
                        path: CurrencySettingsPage.pagePath.path,
                        pageBuilder: _defaultPageBuilder(const CurrencySettingsPage()),
                        redirect: guards([_coreAuthGuard]),
                        routes: [
                          GoRoute(
                              path: CurrencyCreatePage.pagePath.path,
                              pageBuilder: _defaultPageBuilder(const CurrencyCreatePage()),
                              redirect: guards([_coreAuthGuard])),
                          GoRoute(
                              path: CurrencyEditPage.pagePath.path,
                              pageBuilder: (context, state) => _buildDefaultPageTransition(
                                  context, state, CurrencyEditPage(currencyId: state.pathParameters['currencyId'])),
                              redirect: guards([_coreAuthGuard]))
                        ]),
                    GoRoute(
                      path: LocalStorageSettingsPage.pagePath.path,
                      pageBuilder: _defaultPageBuilder(const LocalStorageSettingsPage()),
                      redirect: guards([_coreAuthGuard]),
                    ),
                    GoRoute(
                      path: LogSettingsPage.pagePath.path,
                      pageBuilder: _defaultPageBuilder(const LogSettingsPage()),
                      redirect: guards([_coreAuthGuard]),
                    ),
                    GoRoute(
                      path: L10nSettingsPage.pagePath.path,
                      pageBuilder: _defaultPageBuilder(const L10nSettingsPage()),
                      redirect: guards([_coreAuthGuard]),
                    ),
                    GoRoute(
                        path: SessionSettingsPage.pagePath.path,
                        pageBuilder: _defaultPageBuilder(const SessionSettingsPage()),
                        redirect: guards([_coreAuthGuard])),
                  ]),
              ..._shellRoutes(),
            ]),
          ]),
    ],
  );

  List<GoRoute> _noShellRoutes() {
    return [
      GoRoute(
          path: SplashPage.pagePath.path,
          pageBuilder: (context, state) => _buildDefaultPageTransition(context, state, const SplashPage())),
      GoRoute(
          path: ServerConfigPage.pagePath.path,
          pageBuilder: (context, state) =>
              _buildDefaultPageTransition(context, state, ServerConfigPage(key: GlobalKeys.loginPage)),
          redirect: guards([_loginAuthGuard])),
      GoRoute(
          path: LoginPage.pagePath.path,
          pageBuilder: (context, state) =>
              _buildDefaultPageTransition(context, state, LoginPage(hostUri: state.extra as Uri)),
          redirect: guards([ExtraGuard(ServerConfigPage.pagePath)]))
    ];
  }

  static List<GoRoute> _shellRoutes() {
    return [];
  }

  FutureOr<String?> Function(BuildContext, GoRouterState) guards(List<Guard> guards) =>
      (_, state) => Guards(guards).redirectPath(ref, state);

  static Page<T> _buildDefaultPageTransition<T>(BuildContext context, GoRouterState state, Widget child) {
    return CupertinoPage(child: child);
  }

  static Page<T> Function(BuildContext, GoRouterState) _defaultPageBuilder<T>(Widget child) {
    return (context, state) => _buildDefaultPageTransition(context, state, child);
  }

  static Page<T> Function(BuildContext, GoRouterState) _defaultBranchPageBuilder<T>(Widget child) {
    return (context, state) => CustomTransitionPage(
        child: child,
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        });
  }
}
