import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/suggestion/product_not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProductNotFoundScreen renders all action buttons and barcode card', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProductNotFoundScreen(barcode: '8690000000999'),
      ),
    );

    expect(find.text('Bu barkod veritabanımızda bulunamadı'), findsOneWidget);
    expect(find.text('8690000000999'), findsOneWidget);
    expect(find.text('Yeni Ürün Öner'), findsOneWidget);
    expect(find.text('Tekrar Tara'), findsOneWidget);
    expect(find.text('Manuel Bilgi Ekle'), findsOneWidget);
  });
}
