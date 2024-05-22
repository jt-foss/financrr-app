import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_radio_button.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../models/themes/app_theme.model.dart';
import '../models/themes/theme_loader.dart';
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
      return FinancrrCard(
          padding: const EdgeInsets.all(10),
          onTap: () {
            if (appTheme.themeMode == ThemeMode.light) {
              ref.read(themeProvider.notifier).setLightTheme(appTheme);
            } else {
              ref.read(themeProvider.notifier).setDarkTheme(appTheme);
            }
            ref.read(themeProvider.notifier).setMode(appTheme.themeMode);
          },
          child: Row(
            children: [
              CircleAvatar(
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
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appTheme.translationKey.toText(),
                  if (activeLight || activeDark)
                    (activeLight ? L10nKey.appearanceCurrentLightTheme : L10nKey.appearanceCurrentDarkTheme).toText()
                ],
              )),
              if (currentTheme) Icon(Icons.check, color: theme.financrrExtension.primary)
            ],
          ));
    }

    buildVerticalLayout(Size size) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          L10nKey.appearanceUseDeviceTheme.toText(),
                          L10nKey.appearanceCurrentDeviceTheme.toText(
                              namedArgs: {'deviceTheme': WidgetsBinding.instance.platformDispatcher.platformBrightness.name})
                        ],
                      ),
                    ),
                    FinancrrRadioButton(
                      value: theme.mode == ThemeMode.system,
                      onChanged: (value) =>
                          ref.read(themeProvider.notifier).setMode(value ? ThemeMode.system : theme.getCurrent().themeMode),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (AppTheme theme in AppThemeLoader.themes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: buildThemePreview(theme),
                  )
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
