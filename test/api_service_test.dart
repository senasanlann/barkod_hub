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
    dynamic options,
  }) async {
    if (response is Exception) {
      throw response as Exception;
    }
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
  });

  group('ApiService tiered barcode lookup with Open Food Facts API', () {
    test('step 1: returns product from CSV when present', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient(null),
      );

      final product = await service.getProductByBarcode('8695077102010');

      expect(product.name, 'Dost Tam Yağlı Süt');
      expect(product.category, 'Süt');
    });

    test('step 1b: fetches OFF image when CSV product has missing image', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient({
          'product': {
            'image_url': 'https://images.openfoodfacts.org/off_image.jpg',
          },
        }),
      );

      final product = await service.getProductByBarcode('8690637000010');

      expect(product.name, 'Ariel Sıvı Deterjan 3L');
      expect(product.imageUrl, 'https://images.openfoodfacts.org/off_image.jpg');
    });

    test('step 2: queries OFF API when barcode is not in CSV and parses product with status 1', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient({
          'status': 1,
          'product': {
            'code': '5449000000996',
            'product_name': 'Coca-Cola Zero',
            'brands': 'Coca-Cola',
            'categories': 'İçecekler, Gazlı İçecekler, Kolalı İçecekler',
            'image_url': 'https://images.openfoodfacts.org/front.jpg',
          },
        }),
      );

      final product = await service.getProductByBarcode('9990000000099');

      expect(product.name, 'Coca-Cola Zero');
      expect(product.brand, 'Coca-Cola');
      expect(product.category, 'İçecekler');
      expect(product.imageUrl, 'https://images.openfoodfacts.org/front.jpg');
      expect(product.price, isNull);
    });

    test('step 3: returns status "Ürün bulunamadı" when OFF API returns status 0', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient({'status': 0}),
      );

      final product = await service.getProductByBarcode('0000000000000');

      expect(product.name, isNull);
      expect(product.rawData['status'], 'Ürün bulunamadı');
    });

    test('gracefully handles network exception and falls back to "Ürün bulunamadı"', () async {
      final service = ApiService(
        useMockData: false,
        client: _FakeApiClient(Exception('Network error')),
      );

      final product = await service.getProductByBarcode('0000000000000');

      expect(product.name, isNull);
      expect(product.rawData['status'], 'Ürün bulunamadı');
    });
  });

  group('ApiService mock data mode', () {
    test(
      'getSectors returns non-empty mock sectors without hitting the client',
      () async {
        final service = ApiService(
          useMockData: true,
          client: _FakeApiClient(null),
        );

        final sectors = await service.getSectors();

        expect(sectors, isNotEmpty);
      },
    );

    test('getSectorList returns items for a known mock sector', () async {
      final service = ApiService(
        useMockData: true,
        client: _FakeApiClient(null),
      );

      final sectors = await service.getSectors();
      final result = await service.getSectorList(sectors.first.id);

      expect(result.items, isNotEmpty);
      expect(result.list.itemCount, result.items.length);
    });

    test('finds a product by barcode from the bundled CSV', () async {
      final service = ApiService(
        useMockData: true,
        client: _FakeApiClient(null),
      );

      final product = await service.getProductByBarcode('8695077102010');

      expect(product.name, 'Dost Tam Yağlı Süt');
      expect(product.category, 'Süt');
      expect(product.price, isNull);
    });
  });
}
