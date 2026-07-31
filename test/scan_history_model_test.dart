import 'package:barkod_hub/features/history/models/scan_history_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanHistoryModel', () {
    test('reads json fields', () {
      final history = ScanHistoryModel.fromJson({
        'barcode': '8695077102010',
        'productName': 'Dost Tam Yağlı Süt',
        'imageUrl': 'https://example.com/sut.png',
        'scannedAt': '2026-07-30T12:00:00.000',
        'status': 'success',
      });

      expect(history.barcode, '8695077102010');
      expect(history.productName, 'Dost Tam Yağlı Süt');
      expect(history.imageUrl, 'https://example.com/sut.png');
      expect(history.scannedAt, '2026-07-30T12:00:00.000');
      expect(history.status, 'success');
    });

    test('converts to json', () {
      const history = ScanHistoryModel(
        barcode: '12345678',
        productName: null,
        imageUrl: null,
        scannedAt: '2026-07-30T12:30:00.000',
        status: 'not_found',
      );

      expect(history.toJson(), {
        'barcode': '12345678',
        'productName': null,
        'imageUrl': null,
        'scannedAt': '2026-07-30T12:30:00.000',
        'status': 'not_found',
      });
    });
  });
}
