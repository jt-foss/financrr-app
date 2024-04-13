enum LogLevel { finest, finer, fine, config, info, warning, severe, shout }

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  const LogEntry({required this.message, required this.level, required this.timestamp});
}

abstract class InMemoryRepository<T> {
  final List<T> _items = [];

  int get length => _items.length;

  void add(T item) => _items.add(item);
  bool remove(T item) => _items.remove(item);
  void clear() => _items.clear();
  List<T> getAsList() => List.from(_items);
}

class LogEntryRepository extends InMemoryRepository<LogEntry> {
  static final LogEntryRepository _instance = LogEntryRepository._();

  factory LogEntryRepository() => _instance;

  LogEntryRepository._();
}
