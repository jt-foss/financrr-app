import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/bloc/store_bloc.dart';
import '../../data/log_store.dart';
import '../../data/store.dart';

class LogEntryCard extends StatelessWidget {
  final int index;
  final LogEntry logEntry;
  final bool expanded;

  const LogEntryCard({super.key, required this.index, required this.logEntry, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Card.outlined(
          elevation: 1,
          surfaceTintColor: _getColorTint(logEntry.level),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(logEntry.message, maxLines: expanded ? null : 1),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(_getIcon(logEntry.level), color: _getColorTint(logEntry.level), size: 17),
                    ),
                    Expanded(
                        child:
                            Text('${logEntry.level.name}, ${StoreKey.dateTimeFormat.readSync()!.format(logEntry.timestamp)}')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
