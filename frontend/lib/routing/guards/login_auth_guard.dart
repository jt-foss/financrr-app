import 'dart:async';

import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../pages/authentication/state/authentication_provider.dart';
import '../page_path.dart';
import 'guard.dart';

class LoginAuthGuard extends Guard {
  @override
  FutureOr<PagePathBuilder?> redirect(ProviderRef<Object?> ref, GoRouterState state) async {
    if (!(await ref.read(authProvider.notifier).attemptRecovery()).isAuthenticated) {
      return ServerConfigPage.pagePath;
    }
    return DashboardPage.pagePath;
  }
}
