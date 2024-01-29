import 'dart:async';

import 'package:financrr_frontend/data/theme_repository.dart';
import 'package:financrr_frontend/pages/auth/login_page.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/adaptive_scaffold.dart';
import '../main.dart';
import '../router.dart';

class ContextNavigatorPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  final String? redirectTo;

  const ContextNavigatorPage({super.key, this.redirectTo});

  static PageRoute<T> pageRoute<T>({String? redirectTo}) {
    return MaterialPageRoute(builder: (_) => ContextNavigatorPage(redirectTo: redirectTo));
  }

  @override
  State<StatefulWidget> createState() => ContextNavigatorPageState();
}

class ContextNavigatorPageState extends State<ContextNavigatorPage> {
  Color? _backgroundColor;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future _navigate() async {
    // TODO: impl navigation
    FinancrrApp.of(context).changeAppTheme(theme: AppThemes.light());
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.goPath(LoginPage.pagePath.build());
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
        backgroundColor: _backgroundColor, verticalBuilder: (_, __, size) => const Center(child: CircularProgressIndicator()));
  }
}
