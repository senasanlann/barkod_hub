import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageBox<T> {
  final String boxName;
  final Future<SharedPreferences> _preferences;

  StorageBox(this.boxName, this._preferences);

  String _formatKey(String key) => 'box_${boxName}_$key';

  Future<void> put(String key, T value) async {
    final prefs = await _preferences;
    final k = _formatKey(key);

    if (value is String) {
      await prefs.setString(k, value);
    } else if (value is bool) {
      await prefs.setBool(k, value);
    } else if (value is int) {
      await prefs.setInt(k, value);
    } else if (value is double) {
      await prefs.setDouble(k, value);
    } else if (value is Map || value is List) {
      await prefs.setString(k, jsonEncode(value));
    } else {
      await prefs.setString(k, value.toString());
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final prefs = await _preferences;
    final k = _formatKey(key);
    final val = prefs.get(k);

    if (val == null) return defaultValue;

    if (val is String &&
        (T == Map || T == List || val.startsWith('{') || val.startsWith('['))) {
      try {
        return jsonDecode(val);
      } catch (_) {
        return val;
      }
    }

    return val;
  }

  Future<void> delete(String key) async {
    final prefs = await _preferences;
    await prefs.remove(_formatKey(key));
  }

  Future<List<String>> keys() async {
    final prefs = await _preferences;
    final prefix = 'box_${boxName}_';
    return prefs
        .getKeys()
        .where((k) => k.startsWith(prefix))
        .map((k) => k.substring(prefix.length))
        .toList();
  }

  Future<void> clear() async {
    final prefs = await _preferences;
    final prefix = 'box_${boxName}_';
    final targetKeys = prefs
        .getKeys()
        .where((k) => k.startsWith(prefix))
        .toList();
    for (final k in targetKeys) {
      await prefs.remove(k);
    }
  }
}

class LocalStorageService {
  LocalStorageService({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  late final StorageBox<Map<String, dynamic>> productBox =
      StorageBox<Map<String, dynamic>>('products', _preferences);

  late final StorageBox<Map<String, dynamic>> historyBox =
      StorageBox<Map<String, dynamic>>('history', _preferences);

  late final StorageBox<Map<String, dynamic>> favoritesBox =
      StorageBox<Map<String, dynamic>>('favorites', _preferences);

  late final StorageBox<Map<String, dynamic>> queueBox =
      StorageBox<Map<String, dynamic>>('queue', _preferences);

  late final StorageBox<dynamic> settingsBox = StorageBox<dynamic>(
    'settings',
    _preferences,
  );
}
