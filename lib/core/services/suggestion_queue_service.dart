import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/suggestion/models/suggestion_model.dart';

class SuggestionQueueService {
  SuggestionQueueService({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;
  static const String _queueKey = 'cache_suggestion_queue';

  Future<List<SuggestionModel>> getAll() async {
    final prefs = await _preferences;
    final raw = prefs.getStringList(_queueKey) ?? const [];

    return raw
        .map((item) => SuggestionModel.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<List<SuggestionModel>> getPending() async {
    final all = await getAll();
    return all.where((item) {
      return (item.syncStatus == 'pending' || item.syncStatus == 'syncing') &&
          item.attemptCount < 5;
    }).toList();
  }

  Future<int> pendingCount() async {
    final pending = await getPending();
    return pending.length;
  }

  Future<void> enqueue(SuggestionModel suggestion) async {
    final prefs = await _preferences;
    final all = await getAll();
    final updated = [suggestion, ...all];

    await prefs.setStringList(
      _queueKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> markSynced(String id) async {
    final prefs = await _preferences;
    final all = await getAll();
    final updated = all.map((item) {
      if (item.id == id) {
        return item.copyWith(syncStatus: 'synced');
      }
      return item;
    }).toList();

    await prefs.setStringList(
      _queueKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> markFailed(String id) async {
    final prefs = await _preferences;
    final all = await getAll();
    final updated = all.map((item) {
      if (item.id == id) {
        final newCount = item.attemptCount + 1;
        final newStatus = newCount >= 5 ? 'failed' : 'pending';
        return item.copyWith(
          attemptCount: newCount,
          syncStatus: newStatus,
        );
      }
      return item;
    }).toList();

    await prefs.setStringList(
      _queueKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> remove(String id) async {
    final prefs = await _preferences;
    final all = await getAll();
    final updated = all.where((item) => item.id != id).toList();

    await prefs.setStringList(
      _queueKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.remove(_queueKey);
  }
}
