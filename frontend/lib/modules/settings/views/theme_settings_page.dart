import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../models/theme.model.dart';
import '../models/theme_loader.dart';
import 'settings_page.dart';

class ThemeSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'themes');

  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    buildThemePreview(AppTheme appTheme) {
      final bool currentTheme = theme.getCurrent().id == appTheme.id;
      final bool activeLight = theme.lightTheme.id == appTheme.id;
      final bool activeDark = theme.darkTheme.id == appTheme.id;
      return Card.outlined(
        child: ListTile(
          onTap: () {
            if (appTheme.themeMode == ThemeMode.light) {
              ref.read(themeProvider.notifier).setLightTheme(appTheme);
            } else {
              ref.read(themeProvider.notifier).setDarkTheme(appTheme);
            }
            ref.read(themeProvider.notifier).setMode(appTheme.themeMode);
          },
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          title: Text(appTheme.effectiveName),
          leading: CircleAvatar(
            backgroundColor: appTheme.previewColor,
            child: Icon(
                activeLight
                    ? Icons.wb_sunny
                    : activeDark
                        ? Icons.nightlight_round
                        : null,
                size: 17,
                color: appTheme.themeMode == ThemeMode.light ? Colors.black : Colors.white),
          ),
          subtitle: activeLight || activeDark
              ? (activeLight ? L10nKey.appearanceCurrentLightTheme : L10nKey.appearanceCurrentDarkTheme).toText()
              : null,
          trailing: currentTheme ? const Icon(Icons.check) : null,
        ),
      );
    }

    buildVerticalLayout(Size size) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: ListView(
              children: [
                ListTile(
                    title: L10nKey.appearanceUseDeviceTheme.toText(),
                    trailing: Switch(
                      value: theme.mode == ThemeMode.system,
                      onChanged: (value) =>
                          ref.read(themeProvider.notifier).setMode(value ? ThemeMode.system : theme.getCurrent().themeMode),
                    ),
                    subtitle: L10nKey.appearanceCurrentDeviceTheme.toText(
                        namedArgs: {'deviceTheme': WidgetsBinding.instance.platformDispatcher.platformBrightness.name})),
                const Divider(),
                for (AppTheme theme in AppThemeLoader.themes) buildThemePreview(theme)
              ],
            ),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => buildVerticalLayout(size),
    );
  }
}
