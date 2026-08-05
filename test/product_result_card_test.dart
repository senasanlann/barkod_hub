import 'package:barkod_hub/features/barcode/widgets/product_result_card.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProductResultCard displays formatted price when non-null', (
    WidgetTester tester,
  ) async {
    final product = ProductModel.fromJson({
      'name': 'Test Ürün',
      'barcode': '123456',
      'price': '12.50',
      'source': 'OpenFoodFacts',
      'updatedAt': '2026-08-05T12:00:00Z',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProductResultCard(product: product)),
        ),
      ),
    );

    expect(find.text('12,50 TL'), findsOneWidget);
    expect(find.text('Kaynak: OpenFoodFacts • 05.08.2026'), findsOneWidget);
  });

  testWidgets('ProductResultCard displays "Fiyat belirtilmedi" when price is null', (
    WidgetTester tester,
  ) async {
    final product = ProductModel.fromJson({
      'name': 'Test Ürün',
      'barcode': '123456',
      'fiyat': 'bilinmiyor',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProductResultCard(product: product)),
        ),
      ),
    );

    expect(find.text('Fiyat belirtilmedi'), findsOneWidget);
  });
}
