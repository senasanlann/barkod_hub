import 'package:barkod_hub/shared/widgets/app_sector_emblem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Section 14 Synthetic Sector Emblem Tests', () {
    testWidgets('AppSectorEmblem renders full card style for Market sector', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSectorEmblem(
              sector: 'Market & Gıda',
              category: 'Un',
              productName: 'Unkur Un 5KG',
              height: 200,
            ),
          ),
        ),
      );

      expect(find.text('MARKET & GIDA'), findsOneWidget);
      expect(find.text('BARKOD HUB • ÜRÜN HAVUZU'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);
    });

    testWidgets('AppSectorEmblem renders compactSquare style for Kırtasiye', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSectorEmblem(
              sector: 'Kırtasiye',
              height: 44,
              style: SectorEmblemStyle.compactSquare,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('AppSectorEmblem renders smallBadge style for Temizlik', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSectorEmblem(
              sector: 'Temizlik',
              style: SectorEmblemStyle.smallBadge,
            ),
          ),
        ),
      );

      expect(find.text('Temizlik & Hijyen'), findsOneWidget);
      expect(find.byIcon(Icons.cleaning_services_outlined), findsOneWidget);
    });

    testWidgets('AppSectorEmblem renders compactSquare icons for Kahvaltılık, Süt, Kozmetik', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppSectorEmblem(sector: 'Kahvaltılık', height: 40, style: SectorEmblemStyle.compactSquare),
                AppSectorEmblem(sector: 'Süt ve Süt Ürünleri', height: 40, style: SectorEmblemStyle.compactSquare),
                AppSectorEmblem(sector: 'Kişisel Bakım ve Kozmetik', height: 40, style: SectorEmblemStyle.compactSquare),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.breakfast_dining_outlined), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
      expect(find.byIcon(Icons.spa_outlined), findsOneWidget);
    });
  });
}
