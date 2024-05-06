import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/log_entry.model.dart';
import '../models/log_store.dart';
import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../../routing/page_path.dart';
import '../../../../modules/settings/views/settings_page.dart';
import '../../../utils/common_actions.dart';

class LogSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'logs');

  const LogSettingsPage({super.key});

  @override
  ConsumerState<LogSettingsPage> createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends ConsumerState<LogSettingsPage> {
  bool _sortTimeAscending = false;
  int? _selectedEntryIndex;
  late List<LogEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = LogEntryStore().getAsList();
    sortEntries();
  }

  void sortEntries() {
    _selectedEntryIndex = null;
    _entries.sort((a, b) => _sortTimeAscending ? a.timestamp.compareTo(b.timestamp) : b.timestamp.compareTo(a.timestamp));
  }

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
          child: ListView.separated(
              // +1 for the divider
              // +1 for the notice card if there are no logs
              itemCount: _entries.length + 1,
              separatorBuilder: (_, index) => index == 0 ? const SizedBox() : const Divider(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDivider();
                }
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedEntryIndex = _selectedEntryIndex == index - 1 ? null : index - 1;
                  }),
                  onLongPress: () => CommonActions.copyToClipboard(this, _entries[index - 1].message),
                  child: _buildLogEntryTile(_entries[index - 1], index - 1, expanded: index - 1 == _selectedEntryIndex),
                );
              }),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                _sortTimeAscending = !_sortTimeAscending;
                sortEntries();
              }),
              icon: Icon(_sortTimeAscending ? Icons.arrow_downward : Icons.arrow_upward, size: 17),
              label: Text(_sortTimeAscending ? 'Oldest first' : 'Newest first'),
            ),
            const Spacer(),
            Text('${_entries.length} entries'),
            IconButton(
                onPressed: () => setState(() {
                      LogEntryStore().clear();
                      _entries.clear();
                    }),
                icon: const Icon(Icons.delete_sweep_outlined))
          ],
        ),
        const Divider()
      ],
    );
  }

  Widget _buildLogEntryTile(LogEntry entry, int index, {bool expanded = false}) {
    final Color? tint = _getColorTint(entry.level);
    return Container(
      decoration: BoxDecoration(
        color: tint?.withOpacity(0.1),
        borderRadius: tint != null ? BorderRadius.circular(10) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.loggerName, style: ref.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(entry.message, maxLines: expanded ? null : 1),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(_getIcon(entry.level), color: _getColorTint(entry.level), size: 17),
                ),
                Expanded(child: Text('${entry.level.name}, ${StoreKey.dateTimeFormat.readSync()!.format(entry.timestamp)}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(LogLevel level) {
    return switch (level) {
      LogLevel.finest => Icons.notes_outlined,
      LogLevel.finer => Icons.notes_outlined,
      LogLevel.fine => Icons.notes_outlined,
      LogLevel.config => Icons.handyman_outlined,
      LogLevel.info => Icons.info_outline,
      LogLevel.warning => Icons.warning_amber_outlined,
      LogLevel.severe => Icons.error_outline,
      LogLevel.shout => Icons.error_outline,
    };
  }

  Color? _getColorTint(LogLevel level) {
    return switch (level) {
      LogLevel.config => Colors.blue,
      LogLevel.warning => Colors.orange,
      LogLevel.severe => Colors.red,
      LogLevel.shout => Colors.red,
      _ => null,
    };
  }
}
