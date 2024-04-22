import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/extensions.dart';
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
              Card.outlined(
                child: ListTile(
                    title: const Text('Use System Theme'),
                    trailing: Switch(
                      value: themeState.mode == ThemeMode.system,
                      onChanged: (value) {
                        ref.themeNotifier.setMode(value ? ThemeMode.system : ref.currentTheme.themeMode);
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [for (AppTheme theme in AppThemeLoader.themes) _buildThemePreview(theme)],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(AppTheme theme) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (theme.themeMode == ThemeMode.light) {
            ref.themeNotifier.setLightTheme(theme);
          } else if (theme.themeMode == ThemeMode.dark) {
            ref.themeNotifier.setDarkTheme(theme);
          }
          ref.themeNotifier.setMode(theme.themeMode);
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: theme.previewColor, shape: BoxShape.circle, border: Border.all(color: Colors.grey[400]!)),
              child: theme.id == ref.currentTheme.id
                  ? Center(child: Icon(Icons.check, color: context.lightMode ? Colors.black : Colors.white))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(theme.effectiveName, textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }
}
