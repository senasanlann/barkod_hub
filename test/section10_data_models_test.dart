import 'package:barkod_hub/features/home/widgets/sector_card.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:barkod_hub/features/sectors/models/sector_model.dart';
import 'package:barkod_hub/features/suggestion/models/suggestion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Section 10 Data Models & UI Integration', () {
    test('ProductModel supports id, sector and updatedAt fields', () {
      final product = ProductModel(
        id: 'p100',
        barcode: '8690000000100',
        name: 'Test Product',
        sector: 'Gıda',
        updatedAt: '2026-08-07T12:00:00Z',
        rawData: const {},
      );

      expect(product.id, equals('p100'));
      expect(product.sector, equals('Gıda'));
      expect(product.updatedAt, equals('2026-08-07T12:00:00Z'));
    });

    testWidgets('SectorCard displays network image when imageUrl is present', (tester) async {
      const sector = SectorModel(
        id: 's-gida',
        name: 'Gıda',
        slug: 'gida',
        itemCount: 42,
        imageUrl: 'https://example.com/gida.png',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectorCard(sector: sector, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    test('SuggestionModel contains all required fields and JSON round-trip', () {
      final suggestion = SuggestionModel.create(
        type: 'product_suggestion',
        barcode: '8690000000101',
        productName: 'Yeni Ürün Önerisi',
        note: 'Eksik marka bilgisi',
        imagePath: '/tmp/image.jpg',
      );

      final json = suggestion.toJson();
      final back = SuggestionModel.fromJson(json);

      expect(back.barcode, equals('8690000000101'));
      expect(back.productName, equals('Yeni Ürün Önerisi'));
      expect(back.note, equals('Eksik marka bilgisi'));
      expect(back.imagePath, equals('/tmp/image.jpg'));
      expect(back.syncStatus, equals('pending'));
    });
  });
}
