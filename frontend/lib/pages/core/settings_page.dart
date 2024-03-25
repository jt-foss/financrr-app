import 'package:financrr_frontend/data/session_repository.dart';
import 'package:financrr_frontend/pages/core/settings/currency_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/session_settings_page.dart';
import 'package:financrr_frontend/pages/core/settings/theme_settings_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class SettingsItemGroup {
  final String? title;
  final List<SettingsItem> items;

  const SettingsItemGroup({this.title, required this.items});
}

class SettingsItem {
  final bool showCategory;
  final Widget child;

  const SettingsItem({this.showCategory = true, required this.child});
}

class SettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings');

  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Restrr _api = context.api!;

  late final List<SettingsItemGroup> _items = [
    SettingsItemGroup(
      items: [
        SettingsItem(
          showCategory: false,
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
      ]
    ),
    SettingsItemGroup(
      title: 'Account',
      items: [
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
      ]
    ),
    SettingsItemGroup(
      title: 'App',
      items: [
        SettingsItem(
          child: ListTile(
            onTap: () => context.goPath(ThemeSettingsPage.pagePath.build()),
            leading: const Icon(Icons.brightness_4_rounded),
            title: const Text('Themes'),
          ),
        ),
        const SettingsItem(
          child: ListTile(
            leading: Icon(Icons.language_rounded),
            title: Text('Language'),
          ),
        ),
        const SettingsItem(
          child: ListTile(
            leading: Icon(Icons.format_align_left_rounded),
            title: Text('Logs'),
          ),
        ),
      ]
    ),
    SettingsItemGroup(
      items: [
        SettingsItem(
          showCategory: false,
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
      ]
    )
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
                  Card(
                    child: Column(
                      children: group.items.map((item) => item.child).toList()
                    )
                  )
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
