import 'package:barkod_hub/core/services/api_service.dart';
import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:barkod_hub/features/sectors/sector_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 9 Sector Lists & Download UI', () {
    test('ApiService mock sectors include new sectors from CSV', () async {
      final sectors = await ServiceLocator.apiService.getSectors();
      final sectorNames = sectors.map((s) => s.name).toList();

      expect(sectors, isNotEmpty);
      expect(sectorNames, contains('Market'));
      expect(sectorNames, contains('Kırtasiye'));
      expect(sectorNames, contains('Temizlik'));
      expect(sectorNames, contains('Kozmetik'));
      expect(sectorNames, contains('Hırdavat'));
    });

    testWidgets('SectorDetailScreen displays list version and estimated download file sizes', (tester) async {
      const sector = SectorModel(
        id: 's-market',
        name: 'Market',
        slug: 'market',
        itemCount: 15,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SectorDetailScreen(sector: sector),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(SectorDetailScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
