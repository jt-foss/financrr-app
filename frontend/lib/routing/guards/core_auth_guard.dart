import 'dart:async';

import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../pages/authentication/state/authentication_provider.dart';
import '../page_path.dart';
import 'guard.dart';

class CoreAuthGuard extends Guard {
  static final _log = Logger('AuthGuard');

  @override
  FutureOr<PagePathBuilder?> redirect(ProviderRef<Object?> ref, GoRouterState state) async {
    if (!(await ref.read(authProvider.notifier).attemptRecovery()).isAuthenticated) {
      _log.info('AuthGuard: User is not authenticated (anymore?), redirecting to ServerConfigPage');
      return ServerConfigPage.pagePath;
    }
    return null;
  }
}
