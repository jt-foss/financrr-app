import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../utils/common_actions.dart';
import 'settings_page.dart';

class LocalStorageSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'local-storage');

  const LocalStorageSettingsPage({super.key});

  @override
  ConsumerState<LocalStorageSettingsPage> createState() => _LocalStorageSettingsPageState();
}

class _LocalStorageSettingsPageState extends ConsumerState<LocalStorageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);

    buildTableCell(String text) {
      return GestureDetector(
        onTap: () => CommonActions.copyToClipboard(this, text),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(text),
        ),
      );
    }

    buildVerticalLayout(Size size) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: ListView(
              children: [
                Table(
                  border: TableBorder.all(color: theme.themeData.dividerColor),
                  children: [
                    for (StoreKey key in StoreKey.values)
                      TableRow(
                        children: [
                          buildTableCell(key.key),
                          buildTableCell(_readKey(key)),
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

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: buildVerticalLayout(size)),
    );
  }

  String _readKey<T>(StoreKey<T> key) {
    try {
      return key.readAsStringSync() ?? '<null>';
    } catch (e) {
      return e.toString();
    }
  }
}
