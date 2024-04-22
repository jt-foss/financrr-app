import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../adaptive_scaffold.dart';

class AuthPageTemplate extends StatefulWidget {
  final bool showBackButton;
  final Widget child;

  const AuthPageTemplate({super.key, required this.child, this.showBackButton = false});

  @override
  State<StatefulWidget> createState() => AuthPageTemplateState();
}

class AuthPageTemplateState extends State<AuthPageTemplate> {
  final int _random = Random().nextInt(4) + 1;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.2,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: widget.showBackButton ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                children: [
                  if (widget.showBackButton)
                    IconButton(
                        tooltip: 'Change Server Configuration',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back, color: Colors.grey[400])),
                  IconButton(
                      tooltip: 'Toggle theme',
                      onPressed: () => FinancrrApp.of(context).changeAppTheme(
                          theme: context.lightMode ? AppTheme.getById('DARK')! : AppTheme.getById('LIGHT')!),
                      icon: Icon(context.lightMode ? Icons.nightlight_round : Icons.wb_sunny, color: Colors.grey[400])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(context.appTheme.logoPath,
                  width: 100, colorFilter: ColorFilter.mode(context.theme.primaryColor, BlendMode.srcIn)),
            ),
            Text('sign_in_message_$_random',
                    style: context.textTheme.titleLarge?.copyWith(color: context.theme.primaryColor))
                .tr(),
            widget.child
          ]),
        )));
  }
}
