import 'package:financrr_frontend/pages/authentication/server_config_page.dart';
import 'package:financrr_frontend/pages/authentication/state/authentication_provider.dart';
import 'package:financrr_frontend/pages/authentication/state/authentication_state.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../routing/page_path.dart';

class SplashPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  static final _log = Logger('SplashPage');

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _fadeTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(_controller);

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() async {
    _log.info('Attempting to recover session...');
    final AuthenticationState state = await ref.read(authProvider.notifier).attemptRecovery();
    if (!mounted) return;
    switch (state.status) {
      case AuthenticationStatus.authenticated:
        _log.info('Session recovered, redirecting to DashboardPage');
        context.goPath(DashboardPage.pagePath.build());
        break;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.unknown:
        _log.info('Session recovery failed, redirecting to ServerConfigPage');
        context.goPath(ServerConfigPage.pagePath.build());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeTransition,
          child: SvgPicture.asset(context.appTheme.logoPath,
              width: 100, height: 100, colorFilter: ColorFilter.mode(context.theme.primaryColor, BlendMode.srcIn)),
        ),
      ),
    );
  }
}
