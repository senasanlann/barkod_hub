import 'package:barkod_hub/features/sectors/models/barcode_list_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeListModel', () {
    test('reads default API field names', () {
      final list = BarcodeListModel.fromJson({
        'id': 1,
        'sectorId': 2,
        'title': 'Market Temel Liste',
        'version': '2026.07',
        'itemCount': 1200,
        'exportLinks': {
          'pdf': 'https://example.com/market.pdf',
          'excel': 'https://example.com/market.xlsx',
        },
      });

      expect(list.id, '1');
      expect(list.sectorId, '2');
      expect(list.title, 'Market Temel Liste');
      expect(list.version, '2026.07');
      expect(list.itemCount, 1200);
      expect(list.exportLinks['pdf'], 'https://example.com/market.pdf');
    });

    test('reads alternative API field names', () {
      final list = BarcodeListModel.fromJson({
        'list_id': 'l-1',
        'sector_id': 's-1',
        'list_name': 'Kırtasiye Liste',
        'updated_at': '2026-07-24',
        'product_count': '350',
        'downloads': {'zip': 'https://example.com/kirtasiye.zip'},
      });

      expect(list.id, 'l-1');
      expect(list.sectorId, 's-1');
      expect(list.title, 'Kırtasiye Liste');
      expect(list.version, '2026-07-24');
      expect(list.itemCount, 350);
      expect(list.exportLinks['zip'], 'https://example.com/kirtasiye.zip');
    });

    test('toJson round-trips through fromJson', () {
      const list = BarcodeListModel(
        id: 'l-1',
        sectorId: 's-1',
        title: 'Market Temel Liste',
        version: '2026.07',
        itemCount: 1200,
        exportLinks: {'pdf': 'https://example.com/market.pdf'},
      );

      final restored = BarcodeListModel.fromJson(list.toJson());

      expect(restored.id, list.id);
      expect(restored.sectorId, list.sectorId);
      expect(restored.title, list.title);
      expect(restored.version, list.version);
      expect(restored.itemCount, list.itemCount);
      expect(restored.exportLinks, list.exportLinks);
    });
  });
}
