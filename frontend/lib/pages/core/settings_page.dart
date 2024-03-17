import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/data/session_repository.dart';
import 'package:financrr_frontend/pages/core/settings/currency_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/theme_settings_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class SettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings');

  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Restrr _api = context.api!;

  late final List<Card> _cards = [
    Card(
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: context.theme.primaryColor.withOpacity(.5), shape: BoxShape.circle),
          child: Center(child: Text(_api.selfUser.effectiveDisplayName.substring(0, 2))),
        ),
        title: Text(_api.selfUser.effectiveDisplayName),
        subtitle: const Text('placeholder@financrr.app'),
      ),
    ),
    Card(
      child: ListTile(
        onTap: () => context.goPath(CurrencySettingsPage.pagePath.build()),
        leading: const Icon(Icons.currency_exchange),
        title: const Text('Currency'),
      ),
    ),
    Card(
      child: ListTile(
        onTap: () => context.goPath(ThemeSettingsPage.pagePath.build()),
        leading: const Icon(Icons.brightness_4_outlined),
        title: const Text('Theme'),
      ),
    ),
    const Card(
      child: ListTile(
        leading: Icon(Icons.language),
        title: Text('Language'),
      ),
    ),
    const Card(
      child: ListTile(
        leading: Icon(Icons.format_align_left),
        title: Text('Logs'),
      ),
    ),
    Card(
      child: ListTile(
        onTap: () async {
          final bool success = await SessionService.logout(context, _api);
          // this should never happen
          if (!success && mounted) {
            context.showSnackBar('Could not log out!');
          }
        },
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: Scaffold(
              body: ListView.separated(
            itemCount: _cards.length,
            itemBuilder: (_, index) => _cards[index],
            separatorBuilder: (_, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 5)
            ),
          )),
        ),
      ),
    );
  }
}
