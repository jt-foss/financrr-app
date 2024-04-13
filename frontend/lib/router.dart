import 'package:financrr_frontend/layout/scaffold_navbar_shell.dart';
import 'package:financrr_frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:financrr_frontend/pages/authentication/login_page.dart';
import 'package:financrr_frontend/pages/core/settings/dev/local_storage_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/dev/log_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/l10n/l10n_settings_page.dart';
import 'package:financrr_frontend/pages/splash_page.dart';
import 'package:financrr_frontend/pages/authentication/server_info_page.dart';
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
import 'package:financrr_frontend/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(debugLabel: 'shell');

  static final GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      GoRoute(path: '/@me', redirect: (_, __) => '/@me/dashboard'),
      StatefulShellRoute
          .indexedStack(builder: (context, state, shell) => ScaffoldNavBarShell(navigationShell: shell), branches: [
        StatefulShellBranch(navigatorKey: shellNavigatorKey, routes: [
          GoRoute(
              path: DashboardPage.pagePath.path,
              pageBuilder: _defaultBranchPageBuilder(const DashboardPage()),
              redirect: coreAuthGuard),
          ..._shellRoutes(),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: AccountsOverviewPage.pagePath.path,
              pageBuilder: _defaultBranchPageBuilder(const AccountsOverviewPage()),
              redirect: coreAuthGuard,
              routes: [
                GoRoute(
                    path: AccountCreatePage.pagePath.path,
                    pageBuilder: _defaultPageBuilder(const AccountCreatePage()),
                    redirect: coreAuthGuard),
                GoRoute(
                    path: AccountPage.pagePath.path,
                    pageBuilder: (context, state) =>
                        _buildDefaultPageTransition(context, state, AccountPage(accountId: state.pathParameters['accountId'])),
                    redirect: coreAuthGuard,
                    routes: [
                      GoRoute(
                          path: AccountEditPage.pagePath.path,
                          pageBuilder: (context, state) => _buildDefaultPageTransition(
                              context, state, AccountEditPage(accountId: state.pathParameters['accountId'])),
                          redirect: coreAuthGuard),
                      GoRoute(
                          path: TransactionCreatePage.pagePath.path,
                          pageBuilder: (context, state) => _buildDefaultPageTransition(
                              context, state, TransactionCreatePage(accountId: state.pathParameters['accountId'])),
                          redirect: coreAuthGuard),
                      GoRoute(
                          path: TransactionPage.pagePath.path,
                          pageBuilder: (context, state) => _buildDefaultPageTransition(
                              context,
                              state,
                              TransactionPage(
                                  accountId: state.pathParameters['accountId'],
                                  transactionId: state.pathParameters['transactionId'])),
                          redirect: coreAuthGuard,
                          routes: [
                            GoRoute(
                                path: TransactionEditPage.pagePath.path,
                                pageBuilder: (context, state) => _buildDefaultPageTransition(
                                    context,
                                    state,
                                    TransactionEditPage(
                                        accountId: state.pathParameters['accountId'],
                                        transactionId: state.pathParameters['transactionId'])),
                                redirect: coreAuthGuard)
                          ]),
                    ])
              ]),
          ..._shellRoutes(),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/@me/statistics',
              pageBuilder: _defaultBranchPageBuilder(const DummyPage(text: 'coming soon!')),
              redirect: coreAuthGuard),
          ..._shellRoutes(),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: SettingsPage.pagePath.path,
              pageBuilder: _defaultBranchPageBuilder(const SettingsPage()),
              redirect: coreAuthGuard,
              routes: [
                GoRoute(
                    path: ThemeSettingsPage.pagePath.path,
                    pageBuilder: _defaultPageBuilder(const ThemeSettingsPage()),
                    redirect: coreAuthGuard),
                GoRoute(
                    path: CurrencySettingsPage.pagePath.path,
                    pageBuilder: _defaultPageBuilder(const CurrencySettingsPage()),
                    redirect: coreAuthGuard,
                    routes: [
                      GoRoute(
                          path: CurrencyCreatePage.pagePath.path,
                          pageBuilder: _defaultPageBuilder(const CurrencyCreatePage()),
                          redirect: coreAuthGuard),
                      GoRoute(
                          path: CurrencyEditPage.pagePath.path,
                          pageBuilder: (context, state) => _buildDefaultPageTransition(
                              context, state, CurrencyEditPage(currencyId: state.pathParameters['currencyId'])),
                          redirect: coreAuthGuard)
                    ]),
                GoRoute(
                  path: LocalStorageSettingsPage.pagePath.path,
                  pageBuilder: _defaultPageBuilder(const LocalStorageSettingsPage()),
                  redirect: coreAuthGuard,
                ),
                GoRoute(
                  path: LogSettingsPage.pagePath.path,
                  pageBuilder: _defaultPageBuilder(const LogSettingsPage()),
                  redirect: coreAuthGuard,
                ),
                GoRoute(
                  path: L10nSettingsPage.pagePath.path,
                  pageBuilder: _defaultPageBuilder(const L10nSettingsPage()),
                  redirect: coreAuthGuard,
                ),
                GoRoute(
                    path: SessionSettingsPage.pagePath.path,
                    pageBuilder: _defaultPageBuilder(const SessionSettingsPage()),
                    redirect: coreAuthGuard),
              ]),
          ..._shellRoutes(),
        ]),
      ]),
    ],
    redirect: (context, state) {
      final AuthenticationBloc authBloc = context.read<AuthenticationBloc>();
      if (authBloc.state.status == AuthenticationStatus.authenticated) {
        return null;
      }
      return switch (authBloc.state.status) {
        AuthenticationStatus.unknown => SplashPage.pagePath.build().fullPath,
        _ => ServerInfoPage.pagePath.build().fullPath,
      };
    },
  );

  static List<GoRoute> _noShellRoutes() {
    return [
      GoRoute(
        path: SplashPage.pagePath.path,
        pageBuilder: (context, state) => _buildDefaultPageTransition(context, state, const SplashPage()),
        redirect: authGuard,
      ),
      GoRoute(
          path: ServerInfoPage.pagePath.path,
          pageBuilder: (context, state) =>
              _buildDefaultPageTransition(context, state, ServerInfoPage(key: GlobalKeys.loginPage)),
          redirect: authGuard),
    ];
  }

  static List<GoRoute> _shellRoutes() {
    return [];
  }

  /// Checks whether the current user is authenticated. If so, this will redirect to the [ContextNavigatorPage]
  static String? authGuard(BuildContext context, GoRouterState state) {
    return context.read<AuthenticationBloc>().state.status == AuthenticationStatus.authenticated
        ? DashboardPage.pagePath.build().fullPath
        : null;
  }

  /// Checks whether the current user is authenticated. If not, this will redirect to the [LoginPage], including
  /// the `redirectTo` queryParam for the page the user was initially going to visit
  static String? coreAuthGuard(BuildContext context, GoRouterState state) {
    return context.read<AuthenticationBloc>().state.status != AuthenticationStatus.authenticated
        ? ServerInfoPage.pagePath.build().fullPath
        : null;
  }

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

  PagePath build({Map<String, String>? pathParams, Map<String, dynamic>? queryParams}) {
    String compiled = parent == null ? path : '${parent!.build().fullPath}/$path';
    if (pathParams == null && queryParams == null) {
      return PagePath._(compiled);
    }
    final String initialPath = compiled;
    if (pathParams != null && pathParams.isNotEmpty) {
      for (MapEntry<String, String> entry in pathParams.entries) {
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
}
