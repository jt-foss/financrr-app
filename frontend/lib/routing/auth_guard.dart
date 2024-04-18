import 'package:auto_route/auto_route.dart';
import 'package:financrr_frontend/routing/app_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../pages/authentication/state/authentication_provider.dart';

class AuthGuard extends AutoRouteGuard {
  final ProviderRef<Object?> ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (ref.watch(authProvider).isAuthenticated) {
      resolver.next(true);
    } else {
      router.replaceAll([ServerInfoRoute()]);
    }
  }
}
