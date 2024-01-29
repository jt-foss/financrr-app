import 'package:financrr_frontend/data/theme_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repositories {
  const Repositories._();

  static late final ThemeRepository themeRepository;

  static Future init(FlutterSecureStorage storage, SharedPreferences preferences) async {
    themeRepository = ThemeRepository(preferences: preferences);
  }
}

abstract class SecureStringRepository {
  final FlutterSecureStorage storage;

  const SecureStringRepository({required this.storage});

  String get key;

  Future<bool> contains() {
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

abstract class Repository<T> {
  final SharedPreferences preferences;

  Repository({required this.preferences}) {
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
}

class RepositoryItem<T> {
  final String key;
  final Object Function(T) applyFunction;

  const RepositoryItem({required this.key, required this.applyFunction});
}