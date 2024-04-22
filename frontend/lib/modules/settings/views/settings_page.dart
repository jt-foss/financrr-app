import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/views/local_storage_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/l10n_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/session_settings_page.dart';
import 'package:financrr_frontend/modules/settings/views/theme_settings_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/text_circle_avatar.dart';
import '../../../utils/common_actions.dart';
import 'currency_settings_page.dart';
import 'log_settings_page.dart';

class SettingsItemGroup {
  final String? title;
  final List<SettingsItem> items;
  final bool groupInCard;

  const SettingsItemGroup({this.title, required this.items, this.groupInCard = true});
}

class SettingsItem {
  final bool showCategory;
  final Widget child;

  const SettingsItem({this.showCategory = true, required this.child});
}

class SettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings');

  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final Restrr _api = api;

  late final List<SettingsItemGroup> _items = [
    SettingsItemGroup(items: [
      SettingsItem(
        showCategory: false,
        child: ListTile(
          leading: TextCircleAvatar(text: _api.selfUser.effectiveDisplayName, radius: 25),
          title: Text(_api.selfUser.effectiveDisplayName, style: context.textTheme.titleSmall),
          subtitle: const Text('placeholder@financrr.app'),
        ),
      ),
    ]),
    SettingsItemGroup(title: 'Account', items: [
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(CurrencySettingsPage.pagePath.build()),
          leading: const Icon(Icons.currency_exchange_rounded),
          title: const Text('Currencies'),
        ),
      ),
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(SessionSettingsPage.pagePath.build()),
          leading: const Icon(Icons.devices_rounded),
          title: const Text('Sessions'),
        ),
      ),
    ]),
    SettingsItemGroup(title: 'App', items: [
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(ThemeSettingsPage.pagePath.build()),
          leading: const Icon(Icons.brightness_4_outlined),
          title: const Text('Themes'),
        ),
      ),
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(L10nSettingsPage.pagePath.build()),
          leading: const Icon(Icons.language_rounded),
          title: const Text('Language'),
        ),
      ),
    ]),
    SettingsItemGroup(title: 'Developer', items: [
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(LocalStorageSettingsPage.pagePath.build()),
          leading: const Icon(Icons.sd_storage_outlined),
          title: const Text('Local Storage'),
        ),
      ),
      SettingsItem(
        child: ListTile(
          onTap: () => context.goPath(LogSettingsPage.pagePath.build()),
          leading: const Icon(Icons.format_align_left_rounded),
          title: const Text('Logs'),
        ),
      ),
    ]),
    SettingsItemGroup(items: [
      SettingsItem(
        showCategory: false,
        child: ListTile(
          onTap: () => CommonActions.logOut(this, ref),
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
        ),
      ),
    ]),
    SettingsItemGroup(groupInCard: false, items: [
      SettingsItem(
          showCategory: false,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final PackageInfo info = snapshot.data!;
              return Align(
                child: Text('made with ❤️\nv${info.version}+${info.buildNumber}', textAlign: TextAlign.center),
              );
            },
          )),
    ])
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
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final SettingsItemGroup group = _items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (group.title != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(group.title!, style: context.textTheme.titleSmall),
                    ),
                    const Divider()
                  ],
                  if (group.groupInCard)
                    Card.outlined(child: Column(children: group.items.map((item) => item.child).toList()))
                  else
                    Column(children: group.items.map((item) => item.child).toList()),
                ],
              );
            },
            separatorBuilder: (_, index) => const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          )),
        ),
      ),
    );
  }
}
