import 'package:financrr_frontend/modules/dashboard/views/dashboard_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../routing/page_path.dart';

class SplashPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
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
    // Attempt to go to the dashboard page
    // The AuthGuard will try to recover the session and redirect to the ServerConfigPage if the session
    // is not recoverable
    context.goPath(DashboardPage.pagePath.build());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
