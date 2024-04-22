import 'dart:async';

import 'package:financrr_frontend/modules/dashboard/views/dashboard_page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/auth/pages/server_config_page.dart';
import '../../modules/auth/providers/authentication.provider.dart';
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
