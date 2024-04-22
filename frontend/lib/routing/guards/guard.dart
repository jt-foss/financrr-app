import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../page_path.dart';

class Guards {
  final List<Guard> _guards;

  const Guards(this._guards);

  PagePathBuilder? redirect(ProviderRef<Object?> ref, GoRouterState state) {
    for (final Guard guard in _guards) {
      final PagePathBuilder? path = guard.redirect(ref, state);
      if (path != null) {
        return path;
      }
    }
    return null;
  }

  String? redirectPath(ProviderRef<Object?> ref, GoRouterState state) => redirect(ref, state)?.path;
}

abstract class Guard {
  PagePathBuilder? redirect(ProviderRef<Object?> ref, GoRouterState state);
  String? redirectPath(ProviderRef<Object?> ref, GoRouterState state) => redirect(ref, state)?.path;
}
