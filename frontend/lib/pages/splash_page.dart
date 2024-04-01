import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../router.dart';

class SplashPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/');

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _fadeTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(_controller);

  @override
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
