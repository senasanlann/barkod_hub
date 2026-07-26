import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel', () {
    test('reads default API field names', () {
      final product = ProductModel.fromJson({
        'id': 1,
        'barcode': '8690123456789',
        'name': 'Test Ürün',
        'brand': 'Test Marka',
        'sector': 'Market',
        'category': 'Test Kategori',
        'price': 12.5,
        'imageUrl': 'https://example.com/product.png',
        'updatedAt': '2026-07-24',
      });

      expect(product.id, '1');
      expect(product.barcode, '8690123456789');
      expect(product.name, 'Test Ürün');
      expect(product.brand, 'Test Marka');
      expect(product.sector, 'Market');
      expect(product.category, 'Test Kategori');
      expect(product.price, 12.5);
      expect(product.imageUrl, 'https://example.com/product.png');
      expect(product.updatedAt, '2026-07-24');
    });

    test('reads alternative API field names', () {
      final product = ProductModel.fromJson({
        'product_id': 'p-1',
        'barkod': '12345678',
        'urunAdi': 'Alternatif Ürün',
        'marka': 'Alternatif Marka',
        'sector_name': 'Kırtasiye',
        'kategori': 'Alternatif Kategori',
        'fiyat': '19,90',
        'image_url': 'https://example.com/alternative.png',
        'updated_at': '2026-07-24',
      });

      expect(product.id, 'p-1');
      expect(product.barcode, '12345678');
      expect(product.name, 'Alternatif Ürün');
      expect(product.brand, 'Alternatif Marka');
      expect(product.sector, 'Kırtasiye');
      expect(product.category, 'Alternatif Kategori');
      expect(product.price, 19.90);
      expect(product.imageUrl, 'https://example.com/alternative.png');
      expect(product.updatedAt, '2026-07-24');
    });

    test('keeps original raw data', () {
      final json = {'barcode': '8690123456789', 'status': 'Mock veri'};

      final product = ProductModel.fromJson(json);

      expect(product.rawData, json);
    });
  });
}
