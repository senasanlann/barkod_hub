import 'package:barkod_hub/features/barcode/widgets/product_result_card.dart';
import 'package:barkod_hub/features/product/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 8 Product Result Card UI', () {
    testWidgets('ProductResultCard renders bold 2-line title, copyable barcode, brand/category chips and KDV', (tester) async {
      final product = ProductModel(
        id: '1',
        barcode: '8690000000001',
        name: 'Sütaş Yağlı Süt 1L Çok Uzun Ürün Başlığı Denemesi',
        brand: 'Sütaş',
        category: 'Süt & Süt Ürünleri',
        price: 34.50,
        rawData: {
          'vat': '20',
          'status': 'published',
          'sector': 'gida',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductResultCard(product: product),
          ),
        ),
      );

      expect(find.text('Sütaş Yağlı Süt 1L Çok Uzun Ürün Başlığı Denemesi'), findsOneWidget);
      expect(find.text('8690000000001'), findsOneWidget);
      expect(find.text('EAN-13'), findsOneWidget);
      expect(find.text('Sütaş'), findsOneWidget);
      expect(find.text('Süt & Süt Ürünleri'), findsOneWidget);
      expect(find.text('34,50 TL'), findsOneWidget);
      expect(find.text('Düzenle'), findsOneWidget);
      expect(find.text('Hata Bildir'), findsOneWidget);

      // Verify internal keys 'status' and 'sector' are excluded from details
      expect(find.text('status'), findsNothing);
      expect(find.text('sector'), findsNothing);
    });
  });
}
