import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DuplicateGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Duplicate navigation
    if (resolver.route.name == router.current.name) {
      debugPrint(
        'DuplicateGuard: Preventing duplicate route navigation for ${resolver.route.name}',
      );
      resolver.next(false);
    } else {
      resolver.next(true);
    }
  }
}
