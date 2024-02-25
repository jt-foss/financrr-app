import 'dart:async';
import 'dart:math';

import 'package:financrr_frontend/data/host_repository.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/modal_sheet_utils.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:financrr_frontend/widgets/animations/zoom_tap_animation.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:financrr_frontend/widgets/custom_button.dart';
import 'package:financrr_frontend/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class LoginPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/login');

  final String? redirectTo;

  const LoginPage({super.key, this.redirectTo});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final StreamController<RestResponse<HealthResponse>?> _hostStream = StreamController.broadcast();

  late final AppLocalizations _locale = context.locale;
  late final AppTextStyles _textStyles = AppTextStyles.of(context);
  late final FinancrrTheme _financrrTheme = context.financrrTheme;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final int _random = Random().nextInt(4) + 1;

  @override
  void initState() {
    super.initState();
    checkHostUrl(HostService.get());
  }

  @override
  void dispose() {
    _hostStream.close();
    super.dispose();
  }

  /// Checks whether the specified [HostPreferences] are valid.
  Future checkHostUrl(HostPreferences preferences) async {
    _hostStream.sink.add(null);
    final String hostUrl = preferences.hostUrl;
    if (hostUrl.isEmpty || Uri.tryParse(hostUrl) == null) {
      return;
    }
    final RestResponse<HealthResponse> response = await Restrr.checkUri(Uri.parse(hostUrl));
    if (response.hasData) {
      _hostStream.sink.add(response);
    } else {
      _hostStream.sink.addError(response);
    }
  }

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
                children: [
                  const Spacer(),
                  StreamWrapper(
                      stream: _hostStream.stream,
                      onSuccess: (context, snap) => _buildHostSection(response: snap.data),
                      onError: (context, snap) => _buildHostSection(response: snap.error as RestResponse<HealthResponse>?),
                      onLoading: (context, snap) => _buildHostSection()),
                  const Spacer(),
                  ZoomTapAnimation(child: Icon(Icons.person_add, color: _financrrTheme.primaryHighlightColor)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SvgPicture.asset(_financrrTheme.logoPath!, width: 100),
            ),
            _textStyles.headlineSmall.text(_getRandomSignInMessage(),
                color: _financrrTheme.primaryHighlightColor, fontWeightOverride: FontWeight.w700),
            Form(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextUtils.paddedTitle(context, title: _locale.genericEmail),
                CustomTextField(controller: _emailController, prefixIcon: Icons.email, hintText: _locale.genericEmailEnter),
                TextUtils.paddedTitle(context, title: _locale.genericPassword),
                CustomTextField(
                    controller: _passwordController,
                    prefixIcon: Icons.key,
                    hintText: _locale.genericPasswordEnter,
                    hideable: true)
              ],
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
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
              ),
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
              child: CustomButton.primary(text: _locale.signInButton),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: CustomButton.secondary(
                text: _locale.signInButtonFaceID,
                prefixIcon: Icons.add_reaction_outlined,
              ),
            )
          ]),
        )));
  }

  Widget _buildHostSection({RestResponse<HealthResponse>? response}) {
    final HostPreferences preferences = HostService.get();
    final String statusText = response == null
        ? 'Checking /api/status/health...'
        : response.hasData
            ? response.data!.healthy
                ? 'Healthy, API v${response.data!.apiVersion}'
                : response.data!.details ?? 'Unhealthy, check server logs'
            : 'Could not reach host';
    final Color statusColor = response == null || response.hasData
        ? _financrrTheme.primaryHighlightColor
        : const Color(0xFFFF6666); // TODO: add to theme
    final IconData statusIcon = response == null
        ? Icons.access_time_outlined
        : response.hasData && response.data!.healthy
            ? Icons.check
            : Icons.warning_amber;
    return Column(
      children: [
        ZoomTapAnimation(
          onTap: () => Modals.hostSelectModal().show(context),
          child: _textStyles.bodyMedium.text(preferences.hostUrl.isEmpty ? 'Click to select Host' : preferences.hostUrl,
              color: statusColor, fontWeightOverride: FontWeight.w700),
        ),
        if (preferences.hostUrl.isNotEmpty)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(statusIcon, size: 15, color: statusColor),
              ),
              _textStyles.labelSmall.text(statusText, color: statusColor),
            ],
          ),
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
