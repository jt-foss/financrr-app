import 'package:financrr_frontend/pages/authentication/login_page.dart';
import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:financrr_frontend/pages/core/settings/dev/local_storage_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/dev/log_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/l10n/l10n_settings_page.dart';
import 'package:financrr_frontend/pages/splash_page.dart';
import 'package:financrr_frontend/pages/core/accounts/account_page.dart';
import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_create_page.dart';
import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_edit_page.dart';
import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_page.dart';
import 'package:financrr_frontend/pages/core/accounts/accounts_overview_page.dart';
import 'package:financrr_frontend/pages/core/accounts/account_create_page.dart';
import 'package:financrr_frontend/pages/core/accounts/account_edit_page.dart';
import 'package:financrr_frontend/pages/core/settings/currency/currency_create_page.dart';
import 'package:financrr_frontend/pages/core/settings/currency/currency_edit_page.dart';
import 'package:financrr_frontend/pages/core/settings/currency/currency_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/session/session_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/theme_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings_page.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/pages/core/dummy_page.dart';
import 'package:financrr_frontend/routing/guards/guard.dart';
import 'package:financrr_frontend/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'guards/core_auth_guard.dart';
import 'guards/login_auth_guard.dart';
import 'navbar_shell.dart';

final Provider<AppRouter> appRouterProvider = Provider((ref) => AppRouter(ref));

class AppRouter {
  final ProviderRef<Object?> ref;

  final LoginAuthGuard _loginAuthGuard = LoginAuthGuard();
  final CoreAuthGuard _coreAuthGuard = CoreAuthGuard();

  AppRouter(this.ref);

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(debugLabel: 'shell');

  late GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      GoRoute(path: '/@me', redirect: (_, __) => '/@me/dashboard'),
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
        pageBuilder: (context, state) => _buildDefaultPageTransition(context, state, const SplashPage()),
        redirect: guards([_loginAuthGuard]),
      ),
      GoRoute(
          path: ServerConfigPage.pagePath.path,
          pageBuilder: (context, state) =>
              _buildDefaultPageTransition(context, state, ServerConfigPage(key: GlobalKeys.loginPage))),
      GoRoute(
          path: LoginPage.pagePath.path,
          pageBuilder: (context, state) => _buildDefaultPageTransition(context, state, LoginPage(hostUri: state.extra as Uri)))
    ];
  }

  static List<GoRoute> _shellRoutes() {
    return [];
  }

  String? Function(BuildContext, GoRouterState) guards(List<Guard> guards) => (_, state) => Guards(guards).redirectPath(ref, state);

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

class PagePathBuilder {
  final String path;
  final PagePathBuilder? parent;

  const PagePathBuilder(this.path) : parent = null;

  const PagePathBuilder.child({required this.parent, required this.path});

  PagePath build({Map<String, String>? params, Map<String, dynamic>? queryParams}) {
    String compiled = parent == null ? path : '${parent!.build().fullPath}/$path';
    if (params == null && queryParams == null) {
      return PagePath._(compiled);
    }
    final String initialPath = compiled;
    if (params != null && params.isNotEmpty) {
      for (MapEntry<String, String> entry in params.entries) {
        if (!initialPath.contains(':${entry.key}')) {
          throw StateError('Path does not contain pathParam :${entry.key}!');
        }
        compiled = compiled.replaceAll(':${entry.key}', entry.value.toString());
      }
    }
    if (queryParams != null && queryParams.isNotEmpty) {
      bool first = true;
      for (MapEntry<String, dynamic> entry in queryParams.entries) {
        compiled += '${first ? '?' : '&'}${entry.key}=${entry.value}';
        first = false;
      }
    }
    return PagePath._(compiled);
  }
}

class PagePath {
  final String fullPath;

  const PagePath._(this.fullPath);
}

extension BuildContextExtension on BuildContext {
  void goPath(PagePath path, {Object? extra}) {
    go(path.fullPath, extra: extra);
  }

  Future<T?> pushPath<T extends Object?>(PagePath path, {Object? extra}) {
    return push(path.fullPath, extra: extra);
  }

  void replacePath(PagePath path, {Object? extra}) {
    replace(path.fullPath, extra: extra);
  }
}
