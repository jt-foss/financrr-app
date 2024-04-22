import 'dart:async';

import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../pages/authentication/state/authentication_provider.dart';
import '../page_path.dart';
import 'guard.dart';

/// A guard that checks whether extra data ([GoRouterState.extra]) is provided.
/// If no extra data is provided, the user is redirected to the specified page.
class ExtraGuard extends Guard {
  static final _log = Logger('ExtraGuard');

  /// The page to redirect to if no extra data is provided.
  final PagePathBuilder redirectTo;

  ExtraGuard(this.redirectTo);

  @override
  FutureOr<PagePathBuilder?> redirect(ProviderRef<Object?> ref, GoRouterState state) {
    if (state.extra == null) {
      _log.info('ExtraGuard: No extra data provided! Redirecting to ${redirectTo.path}');
      return redirectTo;
    }
    return null;
  }
}
