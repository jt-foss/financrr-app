// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$FinancrrAppRouter extends RootStackRouter {
  // ignore: unused_element
  _$FinancrrAppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AccountCreateRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccountCreatePage(),
      );
    },
    AccountEditRoute.name: (routeData) {
      final args = routeData.argsAs<AccountEditRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AccountEditPage(
          key: args.key,
          accountId: args.accountId,
        ),
      );
    },
    AccountRoute.name: (routeData) {
      final args = routeData.argsAs<AccountRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AccountPage(
          key: args.key,
          accountId: args.accountId,
        ),
      );
    },
    AccountsOverviewRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccountsOverviewPage(),
      );
    },
    CurrencyCreateRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CurrencyCreatePage(),
      );
    },
    CurrencyEditRoute.name: (routeData) {
      final args = routeData.argsAs<CurrencyEditRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CurrencyEditPage(
          key: args.key,
          currencyId: args.currencyId,
        ),
      );
    },
    CurrencySettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CurrencySettingsPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardPage(),
      );
    },
    L10nSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const L10nSettingsPage(),
      );
    },
    LocalStorageSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LocalStorageSettingsPage(),
      );
    },
    LogSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LogSettingsPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginPage(
          key: args.key,
          hostUri: args.hostUri,
        ),
      );
    },
    ServerConfigRoute.name: (routeData) {
      final args = routeData.argsAs<ServerConfigRouteArgs>(
          orElse: () => const ServerConfigRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ServerConfigPage(
          key: args.key,
          redirectTo: args.redirectTo,
        ),
      );
    },
    SessionSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SessionSettingsPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashPage(),
      );
    },
    TabControllerRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabControllerPage(),
      );
    },
    ThemeSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ThemeSettingsPage(),
      );
    },
    TransactionCreateRoute.name: (routeData) {
      final args = routeData.argsAs<TransactionCreateRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TransactionCreatePage(
          key: args.key,
          accountId: args.accountId,
        ),
      );
    },
    TransactionEditRoute.name: (routeData) {
      final args = routeData.argsAs<TransactionEditRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TransactionEditPage(
          key: args.key,
          accountId: args.accountId,
          transactionId: args.transactionId,
        ),
      );
    },
    TransactionRoute.name: (routeData) {
      final args = routeData.argsAs<TransactionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TransactionPage(
          key: args.key,
          accountId: args.accountId,
          transactionId: args.transactionId,
        ),
      );
    },
  };
}

/// generated route for
/// [AccountCreatePage]
class AccountCreateRoute extends PageRouteInfo<void> {
  const AccountCreateRoute({List<PageRouteInfo>? children})
      : super(
          AccountCreateRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountCreateRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AccountEditPage]
class AccountEditRoute extends PageRouteInfo<AccountEditRouteArgs> {
  AccountEditRoute({
    Key? key,
    required String? accountId,
    List<PageRouteInfo>? children,
  }) : super(
          AccountEditRoute.name,
          args: AccountEditRouteArgs(
            key: key,
            accountId: accountId,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountEditRoute';

  static const PageInfo<AccountEditRouteArgs> page =
      PageInfo<AccountEditRouteArgs>(name);
}

class AccountEditRouteArgs {
  const AccountEditRouteArgs({
    this.key,
    required this.accountId,
  });

  final Key? key;

  final String? accountId;

  @override
  String toString() {
    return 'AccountEditRouteArgs{key: $key, accountId: $accountId}';
  }
}

/// generated route for
/// [AccountPage]
class AccountRoute extends PageRouteInfo<AccountRouteArgs> {
  AccountRoute({
    Key? key,
    required String? accountId,
    List<PageRouteInfo>? children,
  }) : super(
          AccountRoute.name,
          args: AccountRouteArgs(
            key: key,
            accountId: accountId,
          ),
          initialChildren: children,
        );

  static const String name = 'AccountRoute';

  static const PageInfo<AccountRouteArgs> page =
      PageInfo<AccountRouteArgs>(name);
}

class AccountRouteArgs {
  const AccountRouteArgs({
    this.key,
    required this.accountId,
  });

  final Key? key;

  final String? accountId;

  @override
  String toString() {
    return 'AccountRouteArgs{key: $key, accountId: $accountId}';
  }
}

/// generated route for
/// [AccountsOverviewPage]
class AccountsOverviewRoute extends PageRouteInfo<void> {
  const AccountsOverviewRoute({List<PageRouteInfo>? children})
      : super(
          AccountsOverviewRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountsOverviewRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CurrencyCreatePage]
class CurrencyCreateRoute extends PageRouteInfo<void> {
  const CurrencyCreateRoute({List<PageRouteInfo>? children})
      : super(
          CurrencyCreateRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencyCreateRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CurrencyEditPage]
class CurrencyEditRoute extends PageRouteInfo<CurrencyEditRouteArgs> {
  CurrencyEditRoute({
    Key? key,
    required String? currencyId,
    List<PageRouteInfo>? children,
  }) : super(
          CurrencyEditRoute.name,
          args: CurrencyEditRouteArgs(
            key: key,
            currencyId: currencyId,
          ),
          initialChildren: children,
        );

  static const String name = 'CurrencyEditRoute';

  static const PageInfo<CurrencyEditRouteArgs> page =
      PageInfo<CurrencyEditRouteArgs>(name);
}

class CurrencyEditRouteArgs {
  const CurrencyEditRouteArgs({
    this.key,
    required this.currencyId,
  });

  final Key? key;

  final String? currencyId;

  @override
  String toString() {
    return 'CurrencyEditRouteArgs{key: $key, currencyId: $currencyId}';
  }
}

/// generated route for
/// [CurrencySettingsPage]
class CurrencySettingsRoute extends PageRouteInfo<void> {
  const CurrencySettingsRoute({List<PageRouteInfo>? children})
      : super(
          CurrencySettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrencySettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [L10nSettingsPage]
class L10nSettingsRoute extends PageRouteInfo<void> {
  const L10nSettingsRoute({List<PageRouteInfo>? children})
      : super(
          L10nSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'L10nSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LocalStorageSettingsPage]
class LocalStorageSettingsRoute extends PageRouteInfo<void> {
  const LocalStorageSettingsRoute({List<PageRouteInfo>? children})
      : super(
          LocalStorageSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'LocalStorageSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LogSettingsPage]
class LogSettingsRoute extends PageRouteInfo<void> {
  const LogSettingsRoute({List<PageRouteInfo>? children})
      : super(
          LogSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'LogSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    required Uri hostUri,
    List<PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(
            key: key,
            hostUri: hostUri,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<LoginRouteArgs> page = PageInfo<LoginRouteArgs>(name);
}

class LoginRouteArgs {
  const LoginRouteArgs({
    this.key,
    required this.hostUri,
  });

  final Key? key;

  final Uri hostUri;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, hostUri: $hostUri}';
  }
}

/// generated route for
/// [ServerConfigPage]
class ServerConfigRoute extends PageRouteInfo<ServerConfigRouteArgs> {
  ServerConfigRoute({
    Key? key,
    String? redirectTo,
    List<PageRouteInfo>? children,
  }) : super(
          ServerConfigRoute.name,
          args: ServerConfigRouteArgs(
            key: key,
            redirectTo: redirectTo,
          ),
          initialChildren: children,
        );

  static const String name = 'ServerConfigRoute';

  static const PageInfo<ServerConfigRouteArgs> page =
      PageInfo<ServerConfigRouteArgs>(name);
}

class ServerConfigRouteArgs {
  const ServerConfigRouteArgs({
    this.key,
    this.redirectTo,
  });

  final Key? key;

  final String? redirectTo;

  @override
  String toString() {
    return 'ServerConfigRouteArgs{key: $key, redirectTo: $redirectTo}';
  }
}

/// generated route for
/// [SessionSettingsPage]
class SessionSettingsRoute extends PageRouteInfo<void> {
  const SessionSettingsRoute({List<PageRouteInfo>? children})
      : super(
          SessionSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SessionSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TabControllerPage]
class TabControllerRoute extends PageRouteInfo<void> {
  const TabControllerRoute({List<PageRouteInfo>? children})
      : super(
          TabControllerRoute.name,
          initialChildren: children,
        );

  static const String name = 'TabControllerRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ThemeSettingsPage]
class ThemeSettingsRoute extends PageRouteInfo<void> {
  const ThemeSettingsRoute({List<PageRouteInfo>? children})
      : super(
          ThemeSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ThemeSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TransactionCreatePage]
class TransactionCreateRoute extends PageRouteInfo<TransactionCreateRouteArgs> {
  TransactionCreateRoute({
    Key? key,
    required String? accountId,
    List<PageRouteInfo>? children,
  }) : super(
          TransactionCreateRoute.name,
          args: TransactionCreateRouteArgs(
            key: key,
            accountId: accountId,
          ),
          initialChildren: children,
        );

  static const String name = 'TransactionCreateRoute';

  static const PageInfo<TransactionCreateRouteArgs> page =
      PageInfo<TransactionCreateRouteArgs>(name);
}

class TransactionCreateRouteArgs {
  const TransactionCreateRouteArgs({
    this.key,
    required this.accountId,
  });

  final Key? key;

  final String? accountId;

  @override
  String toString() {
    return 'TransactionCreateRouteArgs{key: $key, accountId: $accountId}';
  }
}

/// generated route for
/// [TransactionEditPage]
class TransactionEditRoute extends PageRouteInfo<TransactionEditRouteArgs> {
  TransactionEditRoute({
    Key? key,
    required String? accountId,
    required String? transactionId,
    List<PageRouteInfo>? children,
  }) : super(
          TransactionEditRoute.name,
          args: TransactionEditRouteArgs(
            key: key,
            accountId: accountId,
            transactionId: transactionId,
          ),
          initialChildren: children,
        );

  static const String name = 'TransactionEditRoute';

  static const PageInfo<TransactionEditRouteArgs> page =
      PageInfo<TransactionEditRouteArgs>(name);
}

class TransactionEditRouteArgs {
  const TransactionEditRouteArgs({
    this.key,
    required this.accountId,
    required this.transactionId,
  });

  final Key? key;

  final String? accountId;

  final String? transactionId;

  @override
  String toString() {
    return 'TransactionEditRouteArgs{key: $key, accountId: $accountId, transactionId: $transactionId}';
  }
}

/// generated route for
/// [TransactionPage]
class TransactionRoute extends PageRouteInfo<TransactionRouteArgs> {
  TransactionRoute({
    Key? key,
    required String? accountId,
    required String? transactionId,
    List<PageRouteInfo>? children,
  }) : super(
          TransactionRoute.name,
          args: TransactionRouteArgs(
            key: key,
            accountId: accountId,
            transactionId: transactionId,
          ),
          initialChildren: children,
        );

  static const String name = 'TransactionRoute';

  static const PageInfo<TransactionRouteArgs> page =
      PageInfo<TransactionRouteArgs>(name);
}

class TransactionRouteArgs {
  const TransactionRouteArgs({
    this.key,
    required this.accountId,
    required this.transactionId,
  });

  final Key? key;

  final String? accountId;

  final String? transactionId;

  @override
  String toString() {
    return 'TransactionRouteArgs{key: $key, accountId: $accountId, transactionId: $transactionId}';
  }
}
