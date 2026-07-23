import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel', () {
    test('reads default API field names', () {
      final product = ProductModel.fromJson({
        'barcode': '8690123456789',
        'name': 'Test Ürün',
        'brand': 'Test Marka',
        'category': 'Test Kategori',
      });

      expect(product.barcode, '8690123456789');
      expect(product.name, 'Test Ürün');
      expect(product.brand, 'Test Marka');
      expect(product.category, 'Test Kategori');
    });

    test('reads alternative API field names', () {
      final product = ProductModel.fromJson({
        'barkod': '12345678',
        'urunAdi': 'Alternatif Ürün',
        'marka': 'Alternatif Marka',
        'kategori': 'Alternatif Kategori',
      });

      expect(product.barcode, '12345678');
      expect(product.name, 'Alternatif Ürün');
      expect(product.brand, 'Alternatif Marka');
      expect(product.category, 'Alternatif Kategori');
    });

    test('keeps original raw data', () {
      final json = {'barcode': '8690123456789', 'status': 'Mock veri'};

      final product = ProductModel.fromJson(json);

      expect(product.rawData, json);
    });
  });
}
