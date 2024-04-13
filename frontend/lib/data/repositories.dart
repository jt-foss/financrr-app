import 'dart:async';

import 'package:financrr_frontend/data/bloc/repository_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  static final Repository _instance = Repository._();
  late final SharedPreferences _preferences;
  late final FlutterSecureStorage _storage;
  bool _initialized = false;

  factory Repository() => _instance;

  Repository._();

  static Future<void> init() async {
    if (_instance._initialized) {
      throw StateError('Repository has already been initialized!');
    }
    SharedPreferences.setPrefix('financrr.');
    _instance._preferences = await SharedPreferences.getInstance();
    _instance._storage = const FlutterSecureStorage();
    _instance._initialized = true;
    for (RepositoryKey key in RepositoryKey.values) {
      // initializes all default values for keys that do not exist
      await _instance.read(key);
    }
  }

  FutureOr<T?> read<T>(RepositoryKey<T> key) async {
    _checkInitialized();
    if (key.secure) {
      return await _readOrInitSecureStringKey(key);
    }
    return await _readOrInitSharedPrefsKey(key);
  }

  Future<void> write<T>(RepositoryKey<T> key, T value) async {
    _checkInitialized();
    if (value is Enum) {
      return await write(key, value.name);
    }
    if (key.secure) {
      return await _storage.write(key: key.key, value: value as String);
    }
    await switch (value) {
      (String value) => _preferences.setString(key.key, value),
      (int value) => _preferences.setInt(key.key, value),
      (bool value) => _preferences.setBool(key.key, value),
      (double value) => _preferences.setDouble(key.key, value),
      _ => throw StateError(
          'Invalid value for key ${key.key}! Got: ${value.runtimeType}, Expected either String, int, bool or double')
    };
  }

  Future<void> delete<T>(RepositoryKey<T> key) async {
    _checkInitialized();
    if (key.secure) {
      return await _storage.delete(key: key.key);
    }
    _preferences.remove(key.key);
  }

  Future<T?> _readOrInitSecureStringKey<T>(RepositoryKey<T> key) async {
    if (key.type != String) {
      throw StateError('Secure keys must be of type String!');
    }
    final String? value = await _storage.read(key: key.key);
    if (value != null) {
      return value as T;
    }
    String? defaultValue = key.defaultValue as String?;
    if (defaultValue == null) {
      return null;
    }
    await write(key, value);
    return defaultValue as T?;
  }

  FutureOr<T>? _readOrInitSharedPrefsKey<T>(RepositoryKey<T> key) {
    if (_preferences.containsKey(key.key)) {
      return _preferences.get(key.key) as T;
    }
    final T? defaultValue = key.defaultValue;
    if (defaultValue == null) {
      return null;
    }
    return write(key, defaultValue).then((_) => defaultValue);
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('Repository has not been initialized yet!');
    }
  }
}

enum RepositoryKey<T> {
  hostUrl<String>('host_url', type: String),
  dateTimeFormat<String>('date_time_format', type: String),
  decimalSeparator<String>('decimal_separator', type: String, defaultValue: '.'),
  thousandSeparator<String>('thousand_separator', type: String, defaultValue: ','),
  sessionToken<String>('session_token', type: String, secure: true),
  themeMode<ThemeMode>('theme_mode', type: ThemeMode, defaultValue: ThemeMode.system),
  currentLightThemeId<String>('current_light_theme_id', type: String, defaultValue: 'LIGHT'),
  currentDarkThemeId<String>('current_dark_theme_id', type: String, defaultValue: 'DARK'),
  ;

  final String key;
  final Type type;
  final T? defaultValue;
  final bool secure;

  const RepositoryKey(this.key, {required this.type, this.defaultValue, this.secure = false})
      : assert(!secure || (type == String), 'Secure keys must be of type String!');

  FutureOr<T?> read() => RepositoryBloc().read(this);
  void write(T value) => RepositoryBloc().write(this, value);
  Future<void> delete() => RepositoryBloc().delete(this);
}

abstract class InMemoryRepository<T> {
  final List<T> _items = [];

  int get length => _items.length;

  void add(T item) => _items.add(item);
  bool remove(T item) => _items.remove(item);
  void clear() => _items.clear();
  List<T> getAsList() => List.from(_items);
}
