import 'package:barkod_hub/core/services/offline_cache_service.dart';
import 'package:barkod_hub/features/downloads/models/download_file_model.dart';
import 'package:barkod_hub/features/history/models/scan_history_model.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:barkod_hub/features/sectors/models/barcode_list_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineCacheService.product cache', () {
    test('caches and reads back a product by barcode', () async {
      final service = OfflineCacheService();
      final product = ProductModel.fromJson({
        'barcode': '8695077102010',
        'name': 'Dost Tam Yağlı Süt',
      });

      await service.cacheProduct(product);
      final cached = await service.getCachedProduct('8695077102010');

      expect(cached, isNotNull);
      expect(cached!.product.name, 'Dost Tam Yağlı Süt');
      expect(cached.isStale, isFalse);
    });

    test('returns null for a barcode that was never cached', () async {
      final service = OfflineCacheService();

      final cached = await service.getCachedProduct('0000000000000');

      expect(cached, isNull);
    });
  });

  group('OfflineCacheService.sector list cache', () {
    test('caches and reads back a sector list with its items', () async {
      final service = OfflineCacheService();
      const list = BarcodeListModel(
        id: 'l-1',
        sectorId: 's-1',
        title: 'Market Listesi',
        version: '2026.07',
        itemCount: 1,
        exportLinks: {'pdf': 'https://example.com/market.pdf'},
      );
      final items = [
        ProductModel.fromJson({'barcode': '123', 'name': 'Ürün A'}),
      ];

      await service.cacheSectorList('s-1', list, items);
      final cached = await service.getCachedSectorList('s-1');

      expect(cached, isNotNull);
      expect(cached!.list.title, 'Market Listesi');
      expect(cached.items, hasLength(1));
      expect(cached.items.first.name, 'Ürün A');
    });
  });

  group('OfflineCacheService.scan history', () {
    test('adds entries with the newest first and prunes old entries', () async {
      final service = OfflineCacheService();
      final oldEntry = ScanHistoryModel(
        barcode: '111',
        scannedAt: DateTime.now()
            .subtract(const Duration(days: 40))
            .toIso8601String(),
        status: 'success',
      );
      final recentEntry = ScanHistoryModel(
        barcode: '222',
        scannedAt: DateTime.now().toIso8601String(),
        status: 'success',
      );

      await service.addScanHistory(oldEntry);
      await service.addScanHistory(recentEntry);

      final history = await service.getScanHistory();

      expect(history, hasLength(1));
      expect(history.first.barcode, '222');
    });

    test('clearScanHistory empties the list', () async {
      final service = OfflineCacheService();
      await service.addScanHistory(
        ScanHistoryModel(
          barcode: '333',
          scannedAt: DateTime.now().toIso8601String(),
          status: 'success',
        ),
      );

      await service.clearScanHistory();
      final history = await service.getScanHistory();

      expect(history, isEmpty);
    });
  });

  group('OfflineCacheService.downloaded files', () {
    test('adds and removes a downloaded file record', () async {
      final service = OfflineCacheService();
      const file = DownloadFileModel(
        fileName: 'market.pdf',
        fileType: 'pdf',
        path: '/tmp/does-not-exist-market.pdf',
        size: 2048,
        downloadedAt: '2026-07-30T10:00:00.000',
      );

      await service.addDownloadedFile(file);
      final files = await service.getDownloadedFiles();

      expect(files, hasLength(1));
      expect(files.first.fileName, 'market.pdf');

      await service.removeDownloadedFile(file.path);
      final remaining = await service.getDownloadedFiles();

      expect(remaining, isEmpty);
    });
  });
}
