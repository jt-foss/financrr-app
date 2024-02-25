import 'dart:math';

import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../adaptive_scaffold.dart';

class AuthPageTemplate extends StatefulWidget {
  final Widget child;

  const AuthPageTemplate({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => AuthPageTemplateState();
}

class AuthPageTemplateState extends State<AuthPageTemplate> {
  late final AppLocalizations _locale = context.locale;

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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      tooltip: 'Toggle theme',
                      onPressed: () => FinancrrApp.of(context)
                          .changeAppTheme(theme: context.lightMode ? AppThemes.dark() : AppThemes.light()),
                      icon: Icon(context.lightMode ? Icons.nightlight_round : Icons.wb_sunny, color: Colors.grey[400])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SvgPicture.asset(context.appTheme.logoPath, width: 100, color: context.theme.primaryColor),
            ),
            Text(
                style: context.textTheme.titleLarge?.copyWith(color: context.theme.primaryColor),
                switch (_random) {
                  1 => _locale.signInMessage1,
                  2 => _locale.signInMessage2,
                  3 => _locale.signInMessage3,
                  4 => _locale.signInMessage4,
                  _ => _locale.signInMessage5,
                }),
            widget.child
          ]),
        )));
  }
}
