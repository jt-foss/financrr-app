import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../utils/common_actions.dart';
import 'settings_page.dart';

class LocalStorageSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'local-storage');

  const LocalStorageSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _LocalStorageSettingsPageState();
}

class _LocalStorageSettingsPageState extends State<LocalStorageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [
              Table(
                border: TableBorder.all(color: context.theme.dividerColor),
                children: [
                  for (StoreKey key in StoreKey.values)
                    TableRow(
                      children: [
                        _buildTableCell(key.key),
                        _buildTableCell(key.readAsStringSync() ?? '<null>'),
                      ],
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return GestureDetector(
      onTap: () => CommonActions.copyToClipboard(this, text),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(text),
      ),
    );
  }
}
