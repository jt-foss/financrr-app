import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/routing/router.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../pages/authentication/state/authentication_provider.dart';
import 'guard.dart';

class AuthGuard extends Guard {
  @override
  PagePathBuilder? redirect(ProviderRef<Object?> ref, GoRouterState state) {
    if (!ref.read(authProvider).isAuthenticated) {
      return ServerConfigPage.pagePath;
    }
    return DashboardPage.pagePath;
  }
}
