import 'package:financrr_frontend/data/repositories.dart';

enum LogLevel {
  finest,
  finer,
  fine,
  config,
  info,
  warning,
  severe,
  shout
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  const LogEntry({required this.message, required this.level, required this.timestamp});
}

class LogEntryRepository extends InMemoryRepository<LogEntry> {
}
