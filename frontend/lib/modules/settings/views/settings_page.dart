import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/modules/settings/views/local_storage_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/l10n_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/session_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/theme_settings_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/text_circle_avatar.dart';
import '../../../utils/common_actions.dart';
import '../models/theme.state.dart';
import 'currency_settings_page.dart';
import 'log_settings_page.dart';

class SettingsItemGroup {
  final L10nKey? title;
  final List<SettingsItem> items;
  final bool groupInCard;

  const SettingsItemGroup({this.title, required this.items, this.groupInCard = true});
}

class SettingsItem {
  final bool showCategory;
  final Widget? child;
  final L10nKey? title;
  final IconData? iconData;
  final PagePathBuilder? destination;
  final Function()? onTap;

  const SettingsItem({this.showCategory = true, required this.title, required this.iconData, this.destination, this.onTap})
      : child = null;

  const SettingsItem.fromChild({this.showCategory = true, required this.child})
      : title = null,
        iconData = null,
        destination = null,
        onTap = null;

  Widget build(BuildContext context) {
    if (child != null) {
      return child!;
    }
    return ListTile(
      onTap: () => destination == null ? onTap?.call() : context.goPath(destination!.build()),
      leading: Icon(iconData),
      title: title!.toText(),
    );
  }
}

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final Restrr _api = api;

  List<SettingsItemGroup> _buildItems(ThemeState theme) {
    return [
    SettingsItemGroup(items: [
      SettingsItem.fromChild(
        showCategory: false,
        child: ListTile(
          leading: TextCircleAvatar(text: _api.selfUser.effectiveDisplayName, radius: 25),
          title: Text(_api.selfUser.effectiveDisplayName, style: theme.textTheme.titleSmall),
          subtitle: const Text('placeholder@financrr.app'),
        ),
      ),
    ]),
    const SettingsItemGroup(title: L10nKey.settingsCategoryAccount, items: [
      SettingsItem(
        title: L10nKey.settingsItemCurrencies,
        iconData: Icons.currency_exchange_rounded,
        destination: CurrencySettingsPage.pagePath,
      ),
      SettingsItem(
        title: L10nKey.settingsItemSessions,
        iconData: Icons.devices_rounded,
        destination: SessionSettingsPage.pagePath,
      ),
    ]),
    const SettingsItemGroup(title: L10nKey.settingsCategoryApp, items: [
      SettingsItem(
        title: L10nKey.settingsItemAppearance,
        iconData: Icons.palette_outlined,
        destination: ThemeSettingsPage.pagePath,
      ),
      SettingsItem(
        title: L10nKey.settingsItemLanguage,
        iconData: Icons.language_rounded,
        destination: L10nSettingsPage.pagePath,
      ),
    ]),
    const SettingsItemGroup(title: L10nKey.settingsCategoryDeveloper, items: [
      SettingsItem(
        title: L10nKey.settingsItemLocalStorage,
        iconData: Icons.sd_storage_outlined,
        destination: LocalStorageSettingsPage.pagePath,
      ),
      SettingsItem(
        title: L10nKey.settingsItemLogs,
        iconData: Icons.format_align_left_rounded,
        destination: LogSettingsPage.pagePath,
      ),
    ]),
    SettingsItemGroup(items: [
      SettingsItem(
        showCategory: false,
        title: L10nKey.commonLogout,
        iconData: Icons.logout,
        onTap: () => CommonActions.logOut(this, ref),
      ),
    ]),
    SettingsItemGroup(groupInCard: false, items: [
      SettingsItem.fromChild(
          showCategory: false,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final PackageInfo info = snapshot.data!;
              return SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    L10nKey.settingsFooter.toText(),
                    L10nKey.commonVersion.toText(namedArgs: {'version': '${info.version}+${info.buildNumber}'})
                  ],
                ),
              );
            },
          )),
    ])
  ];
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    buildVerticalLayout(Size size) {
      final List<SettingsItemGroup> items = _buildItems(theme);
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: Scaffold(
                body: ListView.separated(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final SettingsItemGroup group = items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (group.title != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: group.title!.toText(style: theme.textTheme.titleSmall),
                          ),
                          const Divider()
                        ],
                        if (group.groupInCard)
                          Card.outlined(child: Column(children: group.items.map((item) => item.build(context)).toList()))
                        else
                          Column(children: group.items.map((item) => item.build(context)).toList()),
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
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: buildVerticalLayout(size)),
    );
  }
}
