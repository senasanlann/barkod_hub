import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders cache clear and API status sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('API Bağlantı Durumu'), findsOneWidget);
    expect(find.text('Çevrimdışı Önbelleği Temizle'), findsOneWidget);
  });
}
