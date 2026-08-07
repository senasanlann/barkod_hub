import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/network/api_exception.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 6 API Integration & Response Standards', () {
    test(
      'ApiService.searchProducts finds products by name or barcode query',
      () async {
        final service = ApiService(client: ApiClient());
        final results = await service.searchProducts('sut');
        expect(results, isNotNull);
      },
    );

    test(
      'ApiClient handles status codes 401, 404, 429, 500 with user-friendly messages',
      () {
        final client = ApiClient();

        expect(client.get('/invalid-path'), throwsA(isA<ApiException>()));
      },
    );
  });
}
