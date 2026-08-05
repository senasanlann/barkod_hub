import 'package:barkod_hub/core/services/favorites_service.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FavoritesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = FavoritesService();
  });

  test('favorites is empty initially', () async {
    final list = await service.getFavorites();
    expect(list, isEmpty);
  });

  test('toggleFavorite adds and removes product', () async {
    final product = ProductModel.fromJson({
      'barcode': '8690000000001',
      'name': 'Test Çikolata',
      'brand': 'Marka A',
    });

    final added = await service.toggleFavorite(product);
    expect(added, isTrue);

    expect(await service.isFavorite('8690000000001'), isTrue);
    var list = await service.getFavorites();
    expect(list, hasLength(1));
    expect(list.first.name, 'Test Çikolata');

    final removed = await service.toggleFavorite(product);
    expect(removed, isFalse);

    expect(await service.isFavorite('8690000000001'), isFalse);
    list = await service.getFavorites();
    expect(list, isEmpty);
  });

  test('removeFavorite removes item by barcode', () async {
    final product = ProductModel.fromJson({
      'barcode': '8690000000002',
      'name': 'Test Bisküvi',
    });

    await service.toggleFavorite(product);
    expect(await service.isFavorite('8690000000002'), isTrue);

    await service.removeFavorite('8690000000002');
    expect(await service.isFavorite('8690000000002'), isFalse);
  });
}
