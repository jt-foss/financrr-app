import 'dart:math';

import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:financrr_frontend/widgets/custom_button.dart';
import 'package:financrr_frontend/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class LoginPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/login');

  final String? redirectTo;

  const LoginPage({super.key, this.redirectTo});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AppLocalizations _locale = context.locale;
  late final AppTextStyles _textStyles = AppTextStyles.of(context);
  late final FinancrrTheme _financrrTheme = context.financrrTheme;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        child: Center(
            child: SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(children: [
        Padding(padding: const EdgeInsets.only(top: 20), child: _buildTopRow()),
        _textStyles.labelSmall.text('(Selfhosted, 1.0)', color: _financrrTheme.primaryAccentColor),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SvgPicture.asset(_financrrTheme.logoPath!, width: 100),
        ),
        _textStyles.headlineSmall
            .text(_getRandomSignInMessage(), color: _financrrTheme.primaryAccentColor, fontWeightOverride: FontWeight.w700),
        Form(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextUtils.paddedTitle(context, title: _locale.genericEmail),
            CustomTextField(controller: _emailController, prefixIcon: Icons.email, hintText: _locale.genericEmailEnter),
            TextUtils.paddedTitle(context, title: _locale.genericPassword),
            CustomTextField(
                controller: _passwordController, prefixIcon: Icons.key, hintText: _locale.genericPasswordEnter, hideable: true)
          ],
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _buildMethodDivider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildThirdPartySignInMethod(),
            _buildThirdPartySignInMethod(),
            _buildThirdPartySignInMethod(),
            _buildThirdPartySignInMethod()
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: CustomButton(text: _locale.signInButton, width: double.infinity),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CustomButton(
            text: _locale.signInButtonFaceID,
            width: double.infinity,
            prefixIcon: Icons.add_reaction_outlined,
            secondary: true,
          ),
        )
      ]),
    )));
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // TODO: fix this lmao
        Icon(Icons.person_add, color: _financrrTheme.primaryBackgroundColor),
        const Spacer(),
        ZoomTapAnimation(
          child: Row(
            children: [
               Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(Icons.settings, size: 15, color: _financrrTheme.primaryAccentColor),
              ),
              _textStyles.bodyMedium.text('financrr.jasonlessenich.dev',
                  color: _financrrTheme.primaryAccentColor, fontWeightOverride: FontWeight.w700),
            ],
          ),
        ),
        const Spacer(),
        ZoomTapAnimation(child: Icon(Icons.person_add, color: _financrrTheme.primaryAccentColor))
      ],
    );
  }

  Widget _buildMethodDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Divider(thickness: 3, color: _financrrTheme.secondaryBackgroundColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _textStyles.bodyMedium.text(_locale.signInMethodDivider,
              color: _financrrTheme.secondaryBackgroundColor, fontWeightOverride: FontWeight.w800),
        ),
        Expanded(child: Divider(thickness: 3, color: _financrrTheme.secondaryBackgroundColor))
      ],
    );
  }

  Widget _buildThirdPartySignInMethod() {
    return ZoomTapAnimation(
        child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _financrrTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
    ));
  }

  String _getRandomSignInMessage() {
    return switch (_random) {
      1 => _locale.signInMessage1,
      2 => _locale.signInMessage2,
      3 => _locale.signInMessage3,
      4 => _locale.signInMessage4,
      _ => _locale.signInMessage5,
    };
  }
}
