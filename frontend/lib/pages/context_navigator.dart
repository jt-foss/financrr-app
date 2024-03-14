import 'dart:async';

import 'package:financrr_frontend/data/session_repository.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:flutter/material.dart';

import '../layout/adaptive_scaffold.dart';
import '../router.dart';
import 'auth/server_info_page.dart';

class ContextNavigatorPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const ContextNavigatorPage({super.key});

  static PageRoute<T> pageRoute<T>() {
    return MaterialPageRoute(builder: (_) => const ContextNavigatorPage());
  }

  @override
  State<StatefulWidget> createState() => ContextNavigatorPageState();
}

class ContextNavigatorPageState extends State<ContextNavigatorPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  /// Navigates the user to the correct route, based on whether the user
  /// already finished the intro sequence and if they're currently logged in.
  Future _navigate() async {
    final bool success = await SessionService.attemptRecovery(context);
    if (!mounted) return;
    context.pushPath((success ? DashboardPage.pagePath : ServerInfoPage.pagePath).build());
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(verticalBuilder: (_, __, size) => const Center(child: CircularProgressIndicator()));
  }
}
