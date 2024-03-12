import 'package:financrr_frontend/layout/scaffold_navbar_shell.dart';
import 'package:financrr_frontend/pages/auth/login_page.dart';
import 'package:financrr_frontend/pages/auth/server_info_page.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/pages/core/dummy_page.dart';
import 'package:financrr_frontend/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restrr/restrr.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey(debugLabel: 'shell');

  static final goRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      ..._noShellRoutes(),
      GoRoute(path: '/', redirect: (_, __) => '/@me/dashboard'),
      GoRoute(path: '/@me', redirect: (_, __) => '/@me/dashboard'),
      StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ScaffoldNavBarShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(navigatorKey: shellNavigatorKey, routes: [
              GoRoute(
                  path: DashboardPage.pagePath.path,
                  pageBuilder: _defaultBranchPageBuilder(const DashboardPage()),
                  redirect: coreAuthGuard),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/@me/a',
                  pageBuilder: _defaultBranchPageBuilder(const DummyPage(text: 'A')),
                  redirect: coreAuthGuard),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/@me/b',
                  pageBuilder: _defaultBranchPageBuilder(const DummyPage(text: 'B')),
                  redirect: coreAuthGuard),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/@me/c',
                  pageBuilder: _defaultBranchPageBuilder(const DummyPage(text: 'C')),
                  redirect: coreAuthGuard),
            ]),
          ]),
    ],
  );

  static List<GoRoute> _noShellRoutes() {
    return [
      GoRoute(
          name: 'financrr — Login',
          path: ServerInfoPage.pagePath.path,
          pageBuilder: (context, state) =>
              _buildDefaultPageTransition(context, state, ServerInfoPage(key: GlobalKeys.loginPage)),
          redirect: authGuard),
    ];
  }

  /// Checks whether the current user is authenticated. If so, this will redirect to the [ContextNavigatorPage]
  static String? authGuard(BuildContext context, GoRouterState state) {
    return !context.authNotifier.isAuthenticated ? null : DashboardPage.pagePath.build().fullPath;
  }

  /// Checks whether the current user is authenticated. If not, this will redirect to the [LoginPage], including
  /// the `redirectTo` queryParam for the page the user was initially going to visit
  static String? coreAuthGuard(BuildContext context, GoRouterState state) {
    return context.authNotifier.isAuthenticated ? null : ServerInfoPage.pagePath.build().fullPath;
  }

  static Page<T> _buildDefaultPageTransition<T>(BuildContext context, GoRouterState state, Widget child) {
    return CupertinoPage(child: child);
  }

  static Page<T> Function(BuildContext, GoRouterState) _defaultBranchPageBuilder<T>(Widget child) =>
      (context, state) => CustomTransitionPage(
          child: child,
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          });
}

class PagePathBuilder {
  final String path;
  final PagePathBuilder? parent;

  const PagePathBuilder(this.path) : parent = null;

  const PagePathBuilder.child({required this.parent, required this.path});

  PagePath build({Map<String, String>? pathParams, Map<String, dynamic>? queryParams}) {
    String compiled = parent == null ? path : '${parent!.build(queryParams: queryParams).fullPath}/$path';
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

class AuthenticationNotifier extends ChangeNotifier {
  Restrr? _api;

  bool get isAuthenticated => _api != null;

  Restrr? get api => _api;

  void setApi(Restrr? api) {
    _api = api;
    notifyListeners();
  }
}

extension BuildContextExtension on BuildContext {
  /// Provides the [AuthenticationNotifier] using [BuildContext.read].
  AuthenticationNotifier get authNotifier => read<AuthenticationNotifier>();

  /// Provides a nullable instance of [DURA], being only null if the user __is not__ logged in.
  Restrr? get api => authNotifier.api;

  void goPath(PagePath path, {Object? extra}) {
    //if (_isCurrentPath(path)) {
    // TODO: Reimplement this
    //  GlobalKeys.navBarKey.currentState?.shake();
    //  return;
    //}
    go(path.fullPath, extra: extra);
  }

  Future<T?> pushPath<T extends Object?>(PagePath path, {Object? extra}) {
    //if (_isCurrentPath(path)) {
    // TODO: Reimplement this
    //  GlobalKeys.navBarKey.currentState?.shake();
    //  return Future.value(null);
    //}
    return push(path.fullPath, extra: extra);
  }

// bool _isCurrentPath(PagePath path) => GoRouterState.of(this).location == path.fullPath;
}
