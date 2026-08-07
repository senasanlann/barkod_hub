import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/core/network/api_client.dart';
import 'package:barkod_hub/core/services/api_service.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barkod_hub/main.dart';

void main() {
  setUp(() {
    ServiceLocator.setApiServiceOverride(_FakeApiService());
  });

  tearDown(() {
    ServiceLocator.setApiServiceOverride(null);
  });

  testWidgets('BarkodHubApp opens splash screen and navigates to welcome/home', (WidgetTester tester) async {
    await tester.pumpWidget(const BarkodHubApp());

    expect(find.text('Barkod Hub'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Barkod Hub'), findsWidgets);
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService() : super(client: ApiClient());

  @override
  Future<List<SectorModel>> getSectors() async {
    return const [];
  }
}
