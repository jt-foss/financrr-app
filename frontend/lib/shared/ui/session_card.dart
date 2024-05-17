import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/shared/ui/outline_card.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../modules/settings/providers/l10n.provider.dart';

class SessionCard extends ConsumerWidget {
  final Id id;
  final String? name;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCurrent;
  final bool interactive;
  final Function()? onDelete;

  SessionCard({super.key, required PartialSession session, this.interactive = true, this.onDelete})
      : id = session.id.value,
        name = session.name,
        createdAt = session.createdAt,
        expiresAt = session.expiresAt,
        isCurrent = session.api.session.id.value == session.id.value;

  const SessionCard.fromData(
      {super.key,
      required this.id,
      required this.name,
      required this.createdAt,
      required this.expiresAt,
      required this.isCurrent,
      this.interactive = true,
      this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var l10n = ref.watch(l10nProvider);

    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.devices_rounded),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? (isCurrent ? L10nKey.sessionCurrent : L10nKey.sessionUnnamed).toString(),
                    style: theme.textTheme.titleSmall),
                Text('${l10n.dateFormat.format(createdAt)} ($id)'),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(isCurrent ? Icons.logout_rounded : Icons.delete_rounded),
          )
        ],
      ),
    );
  }
}
