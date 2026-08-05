import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LogEntry {
  final String timestamp;
  final String level; // INFO, WARN, ERROR
  final String message;
  final String? tag;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'level': level,
      'message': message,
      'tag': tag,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: json['timestamp']?.toString() ?? '',
      level: json['level']?.toString() ?? 'INFO',
      message: json['message']?.toString() ?? '',
      tag: json['tag']?.toString(),
    );
  }
}

class LogService {
  LogService({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  static const String _logsKey = 'cache_app_logs';
  static const int maxLogEntries = 100;

  Future<List<LogEntry>> getLogs() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_logsKey) ?? [];
    return list.map((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      return LogEntry.fromJson(json);
    }).toList();
  }

  Future<void> log(
    String level,
    String message, {
    String? tag,
  }) async {
    final prefs = await _preferences;
    final logs = await getLogs();

    final entry = LogEntry(
      timestamp: DateTime.now().toIso8601String(),
      level: level.toUpperCase(),
      message: message,
      tag: tag,
    );

    logs.insert(0, entry);
    if (logs.length > maxLogEntries) {
      logs.removeRange(maxLogEntries, logs.length);
    }

    final rawList = logs.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_logsKey, rawList);
  }

  Future<void> clearLogs() async {
    final prefs = await _preferences;
    await prefs.remove(_logsKey);
  }
}
