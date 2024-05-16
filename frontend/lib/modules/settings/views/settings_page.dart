import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/modules/settings/ui/settings_category.dart';
import 'package:financrr_frontend/modules/settings/views/local_storage_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/l10n_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/session_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/theme_settings_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../utils/common_actions.dart';
import '../models/theme.state.dart';
import 'currency_settings_page.dart';
import 'log_settings_page.dart';

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  List<SettingsCategory> _buildItems(ThemeState theme) {
    return [
      SettingsCategory(title: L10nKey.settingsCategoryAccount, items: [
        SettingsItem(
          title: L10nKey.settingsItemCurrencies,
          iconData: Icons.currency_exchange_rounded,
          onTap: () => context.goPath(CurrencySettingsPage.pagePath.build()),
        ),
        SettingsItem(
          title: L10nKey.settingsItemSessions,
          iconData: Icons.devices_rounded,
          onTap: () => context.goPath(SessionSettingsPage.pagePath.build()),
        ),
      ]),
      SettingsCategory(title: L10nKey.settingsCategoryApp, items: [
        SettingsItem(
          title: L10nKey.settingsItemAppearance,
          iconData: Icons.palette_outlined,
          onTap: () => context.goPath(ThemeSettingsPage.pagePath.build()),
        ),
        SettingsItem(
          title: L10nKey.settingsItemLanguage,
          iconData: Icons.language_rounded,
          onTap: () => context.goPath(L10nSettingsPage.pagePath.build()),
        ),
      ]),
      SettingsCategory(title: L10nKey.settingsCategoryDeveloper, items: [
        SettingsItem(
          title: L10nKey.settingsItemLocalStorage,
          iconData: Icons.sd_storage_outlined,
          onTap: () => context.goPath(LocalStorageSettingsPage.pagePath.build()),
        ),
        SettingsItem(
          title: L10nKey.settingsItemLogs,
          iconData: Icons.format_align_left_rounded,
          onTap: () => context.goPath(LogSettingsPage.pagePath.build()),
        ),
      ]),
      SettingsCategory(items: [
        SettingsItem(
          title: L10nKey.commonLogout,
          iconData: Icons.logout,
          onTap: () => CommonActions.logOut(this, ref),
        ),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    buildVerticalLayout(Size size) {
      final List<SettingsCategory> items = _buildItems(theme);
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: Scaffold(
                body: ListView.separated(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final SettingsCategory category = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    category
                  ],
                );
              },
              separatorBuilder: (_, index) => const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            )),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      verticalBuilder: (_, __, size) => buildVerticalLayout(size),
    );
  }
}
