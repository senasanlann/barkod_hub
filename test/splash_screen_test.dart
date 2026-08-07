import 'package:barkod_hub/core/routes/app_router.dart';
import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen renders title and barcode animation widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        home: const SplashScreen(),
      ),
    );

    expect(find.text('Barkod Hub'), findsOneWidget);
    expect(find.text('Ürün & Barkod Havuzu'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(seconds: 5));
  });
}
