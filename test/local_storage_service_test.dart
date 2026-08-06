import 'package:barkod_hub/core/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LocalStorageService();
  });

  test('StorageBox put and get works correctly', () async {
    final box = service.productBox;
    await box.put('8690000000001', {'name': 'Test Ürün', 'price': 15.5});

    final data = await box.get('8690000000001');
    expect(data, isNotNull);
    expect(data['name'], 'Test Ürün');
    expect(data['price'], 15.5);
  });

  test('StorageBox delete removes entry', () async {
    final box = service.historyBox;
    await box.put('item_1', {'action': 'scan'});
    expect(await box.get('item_1'), isNotNull);

    await box.delete('item_1');
    expect(await box.get('item_1'), isNull);
  });

  test('StorageBox clear removes all box entries', () async {
    final box = service.favoritesBox;
    await box.put('k1', {'val': 1});
    await box.put('k2', {'val': 2});

    final keysBefore = await box.keys();
    expect(keysBefore, hasLength(2));

    await box.clear();

    final keysAfter = await box.keys();
    expect(keysAfter, isEmpty);
  });
}
