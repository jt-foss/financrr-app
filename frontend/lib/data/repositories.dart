import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/data/bloc/repository_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RepositoryKey<T> {
  hostUrl<String>('host_url', type: String),
  dateTimeFormat<DateFormat>('date_time_format',
      type: DateFormat, defaultFactory: _defaultDateFormat, fromValue: _dateFormatFromValue, toValue: _dateFormatToValue),
  decimalSeparator<String>('decimal_separator', type: String, defaultValue: '.'),
  thousandSeparator<String>('thousand_separator', type: String, defaultValue: ','),
  sessionToken<String>('session_token', type: String, secure: true),
  themeMode<ThemeMode>('theme_mode',
      type: ThemeMode, defaultValue: ThemeMode.system, fromValue: _themeModeFromValue, toValue: _enumToValue),
  currentLightThemeId<String>('current_light_theme_id', type: String, defaultValue: 'LIGHT'),
  currentDarkThemeId<String>('current_dark_theme_id', type: String, defaultValue: 'DARK'),
  ;

  final String key;
  final Type type;
  final T? defaultValue;
  final T Function()? defaultFactory;
  final bool secure;
  final T? Function(String?)? fromValue;
  final String? Function(T?)? toValue;

  const RepositoryKey(this.key, {required this.type, this.defaultValue, this.defaultFactory, this.secure = false, this.fromValue, this.toValue})
      : assert(!secure || (type == String), 'Secure keys must be of type String!'), assert(defaultValue == null || defaultFactory == null);

  T? readSync() => Repository().readSync(this);
  String? readSyncAsString() => Repository().readSyncAsString(this);
  Future<T?> readAsync() => Repository().readAsync(this);
  Future<String?> readAsyncAsString() => Repository().readAsyncAsString(this);
  void write(T value) => RepositoryBloc().write(this, value);
  Future<void> delete() => Repository().delete(this);

  static DateFormat _defaultDateFormat() => DateFormat.yMd();
  static DateFormat? _dateFormatFromValue(String? value) => value == null ? null : DateFormat(value);
  static String? _dateFormatToValue(DateFormat? format) => format?.pattern;

  // Enums
  static T? _enumFromValue<T extends Enum>(String? value, List<T> values) =>
      value == null ? null : values.firstWhere((element) => element.name == value);
  static String? _enumToValue<T extends Enum>(T? value) => value?.name;
  static ThemeMode? _themeModeFromValue(String? value) => _enumFromValue(value, ThemeMode.values);
}

class Repository {
  static final Repository _instance = Repository._();
  static final Map<String, dynamic> _localCache = {};

  late final SharedPreferences _preferences;
  late final FlutterSecureStorage _storage;
  bool _initialized = false;

  factory Repository() => _instance;

  Repository._();

  static Future<void> init() async {
    if (_instance._initialized) {
      throw StateError('Repository has already been initialized!');
    }
    _instance._preferences = await SharedPreferences.getInstance();
    _instance._storage = const FlutterSecureStorage();
    _instance._initialized = true;
    for (RepositoryKey key in RepositoryKey.values) {
      // initializes all default values for keys that do not exist &
      // populate local cache
      _localCache[key.key] = await key.readAsync();
    }
    print(_localCache);
  }

  T? readSync<T>(RepositoryKey<T> key) {
    _checkInitialized();
    return _localCache[key.key];
  }

  String? readSyncAsString<T>(RepositoryKey<T> key) {
    return _toStringOrValue(readSync(key), key);
  }

  Future<T?> readAsync<T>(RepositoryKey<T> key) async {
    _checkInitialized();
    if (key.secure) {
      return await _readOrInitSecureStringKey(key);
    }
    return await _readOrInitSharedPrefsKey(key);
  }

  Future<String?> readAsyncAsString<T>(RepositoryKey<T> key) async {
    return _toStringOrValue(await readAsync(key), key);
  }

  Future<void> write<T>(RepositoryKey<T> key, T value) async {
    _checkInitialized();
    final dynamic effectiveValue = _toStringOrValue(value, key);
    print('Writing $effectiveValue to ${key.key}');
    _localCache[key.key] = effectiveValue;
    if (key.secure) {
      return await _storage.write(key: key.key, value: effectiveValue);
    }
    await switch (effectiveValue) {
      (String value) => _preferences.setString(key.key, value),
      (int value) => _preferences.setInt(key.key, value),
      (bool value) => _preferences.setBool(key.key, value),
      (double value) => _preferences.setDouble(key.key, value),
      _ => throw StateError(
          'Invalid value for key ${key.key}! Got: ${effectiveValue.runtimeType}, Expected either String, int, bool or double')
    };
  }

  Future<void> delete<T>(RepositoryKey<T> key) async {
    _checkInitialized();
    _localCache.remove(key.key);
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
    final T? effectiveValue = value == null ? null : _fromStringOrValue(value, key);
    if (effectiveValue != null) {
      return effectiveValue;
    }
    T? defaultValue = _getDefault(key);
    if (defaultValue == null) {
      return null;
    }
    await write(key, effectiveValue);
    return defaultValue as T?;
  }

  FutureOr<T>? _readOrInitSharedPrefsKey<T>(RepositoryKey<T> key) {
    if (_preferences.containsKey(key.key)) {
      final dynamic value = _preferences.get(key.key);
      return _fromStringOrValue(value, key);
    }
    final T? defaultValue = _getDefault(key);
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

  T? _getDefault<T>(RepositoryKey<T> key) {
    if (key.defaultFactory != null) {
      return key.defaultFactory!();
    }
    return key.defaultValue;
  }

  static dynamic _toStringOrValue<T>(T value, RepositoryKey<T> key) {
    if (key.toValue != null) {
      return key.toValue!(value);
    }
    return value;
  }

  static T? _fromStringOrValue<T>(dynamic value, RepositoryKey<T> key) {
    if (key.fromValue != null) {
      return key.fromValue!(value);
    }
    return value as T?;
  }
}
