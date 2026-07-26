import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SectorModel', () {
    test('reads default API field names', () {
      final sector = SectorModel.fromJson({
        'id': 1,
        'name': 'Market',
        'slug': 'market',
        'itemCount': 1200,
        'imageUrl': 'https://example.com/market.png',
      });

      expect(sector.id, '1');
      expect(sector.name, 'Market');
      expect(sector.slug, 'market');
      expect(sector.itemCount, 1200);
      expect(sector.imageUrl, 'https://example.com/market.png');
    });

    test('reads alternative API field names', () {
      final sector = SectorModel.fromJson({
        'sector_id': 's-1',
        'sector_name': 'Kırtasiye',
        'code': 'kirtasiye',
        'product_count': '350',
        'icon_url': 'https://example.com/kirtasiye.png',
      });

      expect(sector.id, 's-1');
      expect(sector.name, 'Kırtasiye');
      expect(sector.slug, 'kirtasiye');
      expect(sector.itemCount, 350);
      expect(sector.imageUrl, 'https://example.com/kirtasiye.png');
    });
  });
}
