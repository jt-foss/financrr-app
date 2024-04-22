import 'log_entry.model.dart';

abstract class InMemoryStore<T> {
  final List<T> _items = [];

  int get length => _items.length;

  void add(T item) => _items.add(item);
  bool remove(T item) => _items.remove(item);
  void clear() => _items.clear();
  List<T> getAsList() => List.from(_items);
}

class LogEntryStore extends InMemoryStore<LogEntry> {
  static final LogEntryStore _instance = LogEntryStore._();

  factory LogEntryStore() => _instance;

  LogEntryStore._();
}
