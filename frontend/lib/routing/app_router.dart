import 'package:auto_route/auto_route.dart';
import 'package:financrr_frontend/layout/tab_controller_page.dart';
import 'package:financrr_frontend/routing/auth_guard.dart';
import 'package:financrr_frontend/routing/duplicate_guard.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../pages/authentication/login_page.dart';
import '../pages/authentication/server_config_page.dart';
import '../pages/core/accounts/account_create_page.dart';
import '../pages/core/accounts/account_edit_page.dart';
import '../pages/core/accounts/account_page.dart';
import '../pages/core/accounts/accounts_overview_page.dart';
import '../pages/core/accounts/transactions/transaction_create_page.dart';
import '../pages/core/accounts/transactions/transaction_edit_page.dart';
import '../pages/core/accounts/transactions/transaction_page.dart';
import '../pages/core/dashboard_page.dart';
import '../pages/core/settings/currency/currency_create_page.dart';
import '../pages/core/settings/currency/currency_edit_page.dart';
import '../pages/core/settings/currency/currency_settings_page.dart';
import '../pages/core/settings/dev/local_storage_settings_page.dart';
import '../pages/core/settings/dev/log_settings_page.dart';
import '../pages/core/settings/l10n/l10n_settings_page.dart';
import '../pages/core/settings/session/session_settings_page.dart';
import '../pages/core/settings/theme_settings_page.dart';
import '../pages/core/settings_page.dart';
import '../pages/splash_page.dart';

part 'app_router.gr.dart';

final appRouterProvider = Provider((ref) => FinancrrAppRouter(ref));

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class FinancrrAppRouter extends _$FinancrrAppRouter {
  late final AuthGuard _authGuard;
  final DuplicateGuard _duplicateGuard = DuplicateGuard();

  FinancrrAppRouter(ProviderRef<Object?> ref) : _authGuard = AuthGuard(ref);

  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: SplashRoute.page, initial: true),
        ..._noNavBarRoutes(),
        AutoRoute(path: '/@me', page: TabControllerRoute.page, guards: [
          _authGuard,
          _duplicateGuard
        ], children: [
          AutoRoute(
              path: 'dashboard',
              page: DashboardRoute.page,
              guards: [_authGuard, _duplicateGuard],
              children: _navBarRoutes()),
          AutoRoute(
              path: 'accounts',
              page: AccountsOverviewRoute.page,
              guards: [_authGuard, _duplicateGuard],
              children: _navBarRoutes()),
          AutoRoute(
              path: 'settings',
              page: SettingsRoute.page,
              guards: [_authGuard, _duplicateGuard],
              children: _navBarRoutes()),
        ]),
      ];

  List<AutoRoute> _noNavBarRoutes() {
    return [
      AutoRoute(path: '/server-config', page: ServerConfigRoute.page, guards: [_duplicateGuard]),
      AutoRoute(path: '/login', page: LoginRoute.page, guards: [_duplicateGuard]),
    ];
  }

  List<AutoRoute> _navBarRoutes() {
    return [
      AutoRoute(page: AccountRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: AccountCreateRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: AccountEditRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: TransactionRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: TransactionCreateRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: TransactionEditRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: CurrencySettingsRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: CurrencyCreateRoute.page, guards: [_authGuard, _duplicateGuard]),
      AutoRoute(page: CurrencyEditRoute.page, guards: [_authGuard, _duplicateGuard]),
    ];
  }
}
