import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../settings_page.dart';

class ThemeSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'themes');

  const ThemeSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late AppTheme _selectedTheme = context.appTheme;
  late bool _useSystemTheme = FinancrrApp.of(context).themeMode == ThemeMode.system;

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
          child: ListView(
            children: [
              Card.outlined(
                child: ListTile(
                    title: const Text('Use System Theme'),
                    trailing: Switch(
                      value: _useSystemTheme,
                      onChanged: (value) {
                        FinancrrApp.of(context).changeAppTheme(theme: _selectedTheme, system: value);
                        setState(() => _useSystemTheme = value);
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [for (AppTheme theme in AppTheme.themes) _buildThemePreview(theme)],
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
          FinancrrApp.of(context).changeAppTheme(theme: theme);
          setState(() {
            _selectedTheme = theme;
            _useSystemTheme = false;
          });
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: theme.previewColor, shape: BoxShape.circle, border: Border.all(color: Colors.grey[400]!)),
              child: theme.id == _selectedTheme.id
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
