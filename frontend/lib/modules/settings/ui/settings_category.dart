import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/l10n_utils.dart';

class SettingsItem {
  final L10nKey title;
  final IconData? iconData;
  final Function()? onTap;

  const SettingsItem({required this.title, this.iconData, this.onTap});
}

class SettingsCategory extends ConsumerWidget {
  final L10nKey? title;
  final List<SettingsItem> items;

  const SettingsCategory({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeData = theme.getCurrent().themeData;
    final textTheme = themeData.textTheme;

    buildSettingsItem(SettingsItem item) {
      return GestureDetector(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (item.iconData != null) ...[
                Icon(item.iconData),
                const SizedBox(width: 10),
              ],
              Expanded(child: item.title.toText()),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(

        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              child: title!.toText(style: textTheme.titleMedium),
            ),
          ],
          for (SettingsItem item in items) buildSettingsItem(item)
        ],
      ),
    );
  }
}