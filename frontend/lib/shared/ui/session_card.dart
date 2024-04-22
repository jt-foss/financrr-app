import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../models/store.dart';

class SessionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.devices_rounded),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? '${isCurrent ? 'Current' : 'Unnamed'} Session', style: context.textTheme.titleSmall),
                  Text('${StoreKey.dateTimeFormat.readSync()!.format(createdAt)} ($id)'),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(isCurrent ? Icons.logout_rounded : Icons.delete_rounded),
            )
          ],
        ),
      ),
    );
  }
}
