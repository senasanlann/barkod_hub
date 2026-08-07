import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/barcode/barcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BarcodeScreen renders flash toggle, scanner and manual barcode button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BarcodeScreen(),
      ),
    );

    expect(find.text('Kamera ile Barkod Tara'), findsOneWidget);
    expect(find.text('Manuel Girişe Git'), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
  });
}
