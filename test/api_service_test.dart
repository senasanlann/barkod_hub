import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient(this.response);

  final dynamic response;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService.getSectorList', () {
    test('parses list meta and items from a wrapped map response', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient({
          'success': true,
          'data': {
            'id': 'l-1',
            'sectorId': 's-1',
            'title': 'Market Temel Liste',
            'version': '2026.07',
            'itemCount': 2,
            'exportLinks': {'pdf': 'https://example.com/market.pdf'},
            'items': [
              {'barcode': '1234567890123', 'name': 'Ürün A'},
              {'barcode': '9876543210987', 'name': 'Ürün B'},
            ],
          },
        }),
      );

      final result = await service.getSectorList('s-1');

      expect(result.list.title, 'Market Temel Liste');
      expect(result.list.version, '2026.07');
      expect(result.list.exportLinks['pdf'], 'https://example.com/market.pdf');
      expect(result.items, hasLength(2));
      expect(result.items.first.name, 'Ürün A');
    });

    test('falls back to a plain item list when no meta is present', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient([
          {'barcode': '1234567890123', 'name': 'Ürün A'},
        ]),
      );

      final result = await service.getSectorList('s-2');

      expect(result.list.itemCount, 1);
      expect(result.list.exportLinks, isEmpty);
      expect(result.items, hasLength(1));
    });
  });

  group('ApiService.getExportJob', () {
    test('extracts export job data from a wrapped response', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient({
          'success': true,
          'data': {
            'id': 'job-1',
            'status': 'ready',
            'links': {'pdf': 'https://example.com/job-1.pdf'},
          },
        }),
      );

      final result = await service.getExportJob('job-1');

      expect(result['id'], 'job-1');
      expect(result['status'], 'ready');
      expect(result['links']['pdf'], 'https://example.com/job-1.pdf');
    });

    test('returns mock export links in mock data mode', () async {
      final service = ApiService(client: _FakeApiClient(null));

      final result = await service.getExportJob('job-2');
      final links = result['links'] as Map<String, dynamic>;

      expect(result['status'], 'ready');
      expect(links['pdf'], 'https://example.com/export/job-2.pdf');
      expect(links['excel'], 'https://example.com/export/job-2.xlsx');
      expect(links['zip'], 'https://example.com/export/job-2.zip');
    });
  });

  group('ApiService mock data mode', () {
    test(
      'getSectors returns non-empty mock sectors without hitting the client',
      () async {
        final service = ApiService(client: _FakeApiClient(null));

        final sectors = await service.getSectors();

        expect(sectors, isNotEmpty);
      },
    );

    test('getSectorList returns items for a known mock sector', () async {
      final service = ApiService(client: _FakeApiClient(null));

      final sectors = await service.getSectors();
      final result = await service.getSectorList(sectors.first.id);

      expect(result.items, isNotEmpty);
      expect(result.list.itemCount, result.items.length);
    });

    test('finds a product by barcode from the bundled CSV', () async {
      final service = ApiService(client: _FakeApiClient(null));

      final product = await service.getProductByBarcode('8695077102010');

      expect(product.name, 'Dost Tam Yağlı Süt');
      expect(product.category, 'Süt');
      expect(product.price, isNull);
    });
  });
}
