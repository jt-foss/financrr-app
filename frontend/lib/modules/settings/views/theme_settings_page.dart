import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../models/theme.model.dart';
import '../models/theme.state.dart';
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

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size, theme)),
    );
  }

  Widget _buildVerticalLayout(Size size, ThemeState themeState) {
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
                    value: themeState.mode == ThemeMode.system,
                    onChanged: (value) =>
                        ref.read(themeProvider.notifier).setMode(value ? ThemeMode.system : ref.currentTheme.themeMode),
                  ),
                  subtitle: L10nKey.appearanceCurrentDeviceTheme
                      .toText(namedArgs: {'deviceTheme': WidgetsBinding.instance.platformDispatcher.platformBrightness.name})),
              const Divider(),
              for (AppTheme theme in AppThemeLoader.themes) _buildThemePreview(theme, themeState)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(AppTheme theme, ThemeState themeState) {
    final bool currentTheme = ref.currentTheme.id == theme.id;
    final bool activeLight = themeState.lightTheme.id == theme.id;
    final bool activeDark = themeState.darkTheme.id == theme.id;
    return Card.outlined(
      child: ListTile(
        onTap: () {
          if (theme.themeMode == ThemeMode.light) {
            ref.read(themeProvider.notifier).setLightTheme(theme);
          } else {
            ref.read(themeProvider.notifier).setDarkTheme(theme);
          }
          ref.read(themeProvider.notifier).setMode(theme.themeMode);
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        title: Text(theme.effectiveName),
        leading: CircleAvatar(
          backgroundColor: theme.previewColor,
          child: Icon(
              activeLight
                  ? Icons.wb_sunny
                  : activeDark
                      ? Icons.nightlight_round
                      : null,
              size: 17,
              color: theme.themeMode == ThemeMode.light ? Colors.black : Colors.white),
        ),
        subtitle: activeLight || activeDark
            ? (activeLight ? L10nKey.appearanceCurrentLightTheme : L10nKey.appearanceCurrentDarkTheme).toText()
            : null,
        trailing: currentTheme ? const Icon(Icons.check) : null,
      ),
    );
  }
}
