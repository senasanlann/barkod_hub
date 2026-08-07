import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:barkod_hub/features/suggestion/models/suggestion_model.dart';
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

  group('Section 7 Cache & Sync', () {
    test('OfflineCacheService manages favorite sectors correctly', () async {
      final initialFavs = await ServiceLocator.offlineCacheService.getFavoriteSectors();
      expect(initialFavs, isEmpty);

      final added = await ServiceLocator.offlineCacheService.toggleFavoriteSector('s-gida');
      expect(added, isTrue);
      expect(await ServiceLocator.offlineCacheService.isFavoriteSector('s-gida'), isTrue);

      final removed = await ServiceLocator.offlineCacheService.toggleFavoriteSector('s-gida');
      expect(removed, isFalse);
      expect(await ServiceLocator.offlineCacheService.isFavoriteSector('s-gida'), isFalse);
    });

    test('SuggestionQueueService processPendingQueue syncs and removes items', () async {
      final report = SuggestionModel.create(
        type: 'product_suggestion',
        barcode: '8690000000003',
        productName: 'Test Ürün',
      );

      await ServiceLocator.suggestionQueueService.enqueue(report);
      expect(await ServiceLocator.suggestionQueueService.pendingCount(), equals(1));

      final syncedCount = await ServiceLocator.suggestionQueueService.processPendingQueue(
        ServiceLocator.apiService,
      );
      expect(syncedCount, equals(1));
      expect(await ServiceLocator.suggestionQueueService.pendingCount(), equals(0));
    });
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService() : super(client: ApiClient());

  @override
  Future<bool> postProductSuggestion(SuggestionModel suggestion) async {
    return true;
  }

  @override
  Future<bool> postImageReport(SuggestionModel report) async {
    return true;
  }
}
