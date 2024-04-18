import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class DuplicateGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final bool sameRoute = resolver.route.name == router.current.name;
    if (sameRoute) {
      debugPrint('Prevented duplicate route navigation! (${resolver.route.name} -> ${router.current.name})');
    }
    resolver.next(!sameRoute);
  }
}
