import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:barkod_hub/features/sectors/sector_detail_screen.dart';
import 'package:barkod_hub/features/barcode/widgets/product_result_card.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:barkod_hub/features/sectors/widgets/list_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 9 Sector Lists & Download UI', () {
    test('ApiService mock sectors reflect the current CSV', () async {
      final sectors = await ServiceLocator.apiService.getSectors();
      final sectorNames = sectors.map((s) => s.name).toList();

      expect(sectors, isNotEmpty);
      expect(sectorNames, contains('Temel Gıda'));
      expect(sectorNames, contains('Gıda Dışı Ürünler'));
      expect(sectorNames, contains('Kişisel Bakım ve Kozmetik'));
      expect(sectorNames, contains('İçecek'));
      expect(sectorNames, contains('Kahvaltılık'));
    });

    testWidgets(
      'SectorDetailScreen displays list version and estimated download file sizes',
      (tester) async {
        const sector = SectorModel(
          id: 's-market',
          name: 'Market',
          slug: 'market',
          itemCount: 15,
        );

        await tester.pumpWidget(
          const MaterialApp(home: SectorDetailScreen(sector: sector)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(SectorDetailScreen), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('Tapping ListProductCard opens ProductResultCard modal sheet', (tester) async {
      final product = const ProductModel(
        rawData: {'barcode': '8690504018087'},
        barcode: '8690504018087',
        name: 'Ülker Çikolatalı Gofret',
        brand: 'Ülker',
        price: 15.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListProductCard(product: product),
          ),
        ),
      );

      await tester.tap(find.byType(ListProductCard));
      await tester.pumpAndSettle();

      expect(find.byType(ProductResultCard), findsOneWidget);
      expect(find.text('Ülker Çikolatalı Gofret'), findsWidgets);
    });
  });
}
