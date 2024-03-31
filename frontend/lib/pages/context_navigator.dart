import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/pages/login/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../layout/adaptive_scaffold.dart';
import '../router.dart';
import 'login/server_info_page.dart';

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
    context.read<AuthenticationBloc>().add(const AuthenticationRecoveryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthenticationStatus.authenticated:
            context.goPath(DashboardPage.pagePath.build());
          default:
            context.goPath(ServerInfoPage.pagePath.build());
        }
      },
      child: AdaptiveScaffold(verticalBuilder: (_, __, size) => const Center(child: CircularProgressIndicator())),
    );
  }
}
