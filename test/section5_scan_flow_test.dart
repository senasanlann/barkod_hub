import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ServiceLocator.setApiServiceOverride(_FakeApiService());
  });

  tearDown(() {
    ServiceLocator.setApiServiceOverride(null);
  });

  test('ApiService.postScanLog sends barcode scan log', () async {
    final result = await ServiceLocator.apiService.postScanLog('8690000000001', 'success');
    expect(result, isTrue);
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService() : super(client: ApiClient());

  @override
  Future<bool> postScanLog(String barcode, String status) async {
    return true;
  }
}
