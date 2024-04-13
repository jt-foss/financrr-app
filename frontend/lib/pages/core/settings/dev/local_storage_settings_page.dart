import 'package:flutter/material.dart';
import '../../../../data/repositories.dart';
import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../settings_page.dart';

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
              for (final key in RepositoryKey.values)
                Card.outlined(
                  child: ListTile(
                    title: Text(key.readSyncAsString() ?? '<null>'),
                    subtitle: Text(key.key),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
