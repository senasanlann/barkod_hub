import 'package:barkod_hub/core/services/log_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LogService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LogService();
  });

  test('logs is empty initially', () async {
    final logs = await service.getLogs();
    expect(logs, isEmpty);
  });

  test('log adds entry with timestamp and tag', () async {
    await service.log('INFO', 'Sorgulama başlatıldı', tag: 'SCAN');
    final logs = await service.getLogs();

    expect(logs, hasLength(1));
    expect(logs.first.level, 'INFO');
    expect(logs.first.message, 'Sorgulama başlatıldı');
    expect(logs.first.tag, 'SCAN');
  });

  test('clearLogs removes all logged entries', () async {
    await service.log('ERROR', 'Ağ bağlantı hatası');
    expect(await service.getLogs(), hasLength(1));

    await service.clearLogs();
    expect(await service.getLogs(), isEmpty);
  });
}
