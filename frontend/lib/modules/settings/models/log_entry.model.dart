enum LogLevel { finest, finer, fine, config, info, warning, severe, shout }

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String loggerName;

  const LogEntry({required this.message, required this.level, required this.timestamp, required this.loggerName});
}
