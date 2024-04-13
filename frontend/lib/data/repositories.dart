import 'package:financrr_frontend/data/log_repository.dart';
import 'package:financrr_frontend/data/session_repository.dart';
import 'package:financrr_frontend/data/theme_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'host_repository.dart';
import 'l10n_repository.dart';

class Repositories {
  const Repositories._();

  static late final SessionRepository sessionRepository;

  static late final ThemeRepository themeRepository;
  static late final HostRepository hostRepository;
  static late final L10nRepository l10nRepository;

  static late final LogEntryRepository logEntryRepository;

  static Future init(FlutterSecureStorage storage, SharedPreferences preferences) async {
    sessionRepository = SessionRepository(storage: storage);
    themeRepository = ThemeRepository(preferences: preferences);
    hostRepository = HostRepository(preferences: preferences);
    l10nRepository = L10nRepository(preferences: preferences);
    logEntryRepository = LogEntryRepository();
  }
}

abstract class InMemoryRepository<T> {
  final List<T> _items = [];

  int get length => _items.length;

  T operator [](int index) => _items[index];
  void add(T item) => _items.add(item);
  bool remove(T item) => _items.remove(item);
  void clear() => _items.clear();
  List<T> getAsList() => List.from(_items);
}

abstract class SecureStringRepository {
  final FlutterSecureStorage storage;

  const SecureStringRepository({required this.storage});

  String get key;

  Future<bool> exists() {
    try {
      return storage.containsKey(key: key);
    } catch (_) {
      return Future.value(false);
    }
  }

  Future<String?> read() {
    try {
      return storage.read(key: key);
    } catch (_) {
      return Future.value(null);
    }
  }

  Future<void> write(String value) {
    try {
      return storage.write(key: key, value: value);
    } catch (_) {
      return Future.value(null);
    }
  }

  Future<void> delete() {
    try {
      return storage.delete(key: key);
    } catch (_) {
      return Future.value(null);
    }
  }
}

abstract class SharedPreferencesRepository<T> {
  final SharedPreferences preferences;

  SharedPreferencesRepository({required this.preferences}) {
    // initializes all default values for keys that do not exist
    save(toData({}), onlyNonExistentKeys: true);
  }

  String get prefix;

  List<String> get keys;

  List<RepositoryItem<T>> fromData();

  T toData(Map<String, Object?> items);

  Future save(T data, {bool onlyNonExistentKeys = false}) async {
    final List<RepositoryItem<T>> items = fromData();
    for (RepositoryItem<T> item in items) {
      if (onlyNonExistentKeys && preferences.getKeys().contains('${prefix}_${item.key}')) {
        continue;
      }
      await _writeObject(data, '${prefix}_${item.key}', item.applyFunction.call(data));
    }
  }

  T read() {
    final Map<String, Object?> items = {};
    for (String key in keys) {
      items[key] = preferences.get('${prefix}_$key');
    }
    return toData(items);
  }

  Future<bool> _writeObject(T data, String key, Object value) {
    return switch (value) {
      (Enum value) => _writeObject(data, key, value.name),
      (String value) => preferences.setString(key, value),
      (int value) => preferences.setInt(key, value),
      (bool value) => preferences.setBool(key, value),
      (double value) => preferences.setDouble(key, value),
      _ => throw StateError(
          'Encountered invalid Object when saving ${data.runtimeType}! Got: ${value.runtimeType}, Expected either String, int, bool or double')
    };
  }

  Future<void> clear() async {
    for (String key in keys) {
      await preferences.remove('${prefix}_$key');
    }
  }
}

class RepositoryItem<T> {
  final String key;
  final Object Function(T) applyFunction;

  const RepositoryItem({required this.key, required this.applyFunction});
}
