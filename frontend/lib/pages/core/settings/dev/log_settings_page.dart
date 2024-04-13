import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/entities/log_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/log_repository.dart';
import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../../../widgets/notice_card.dart';
import '../../settings_page.dart';

class LogSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'logs');

  const LogSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends State<LogSettingsPage> {
  bool _sortTimeAscending = false;
  int? _selectedEntryIndex;
  late List<LogEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = LogEntryRepository().getAsList();
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
          child: ListView.builder(
              // +1 for the divider
              // +1 for the notice card if there are no logs
              itemCount: _entries.length + 1 + (_entries.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDivider();
                }
                if (_entries.isEmpty) {
                  return const NoticeCard(
                      iconData: Icons.info_outline, title: 'No logs', description: 'No logs have been recorded yet.');
                }
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedEntryIndex = _selectedEntryIndex == index - 1 ? null : index - 1;
                  }),
                  onLongPress: () async {
                    context.showSnackBar('Copied to clipboard');
                    await Clipboard.setData(ClipboardData(text: _entries[index - 1].message));
                  },
                  child:
                      LogEntryCard(index: index - 1, logEntry: _entries[index - 1], expanded: index - 1 == _selectedEntryIndex),
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
                      LogEntryRepository().clear();
                      _entries.clear();
                    }),
                icon: const Icon(Icons.delete_sweep_outlined))
          ],
        ),
        const Divider()
      ],
    );
  }
}
