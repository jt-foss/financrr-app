import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../page_path.dart';

class Guards {
  final List<Guard> _guards;

  const Guards(this._guards);

  FutureOr<PagePathBuilder?> redirect(ProviderRef<Object?> ref, GoRouterState state) {
    for (final Guard guard in _guards) {
      final FutureOr<PagePathBuilder?> path = guard.redirect(ref, state);
      if (path != null) {
        return path;
      }
    }
    return null;
  }

  FutureOr<String?> redirectPath(ProviderRef<Object?> ref, GoRouterState state) async =>
      (await redirect(ref, state))?.path;
}

abstract class Guard {
  FutureOr<PagePathBuilder?> redirect(ProviderRef<Object?> ref, GoRouterState state);
  FutureOr<String?> redirectPath(ProviderRef<Object?> ref, GoRouterState state) async =>
      (await redirect(ref, state))?.path;
}
