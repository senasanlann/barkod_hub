import 'package:barkod_hub/core/theme/app_theme.dart';
import 'package:barkod_hub/features/auth/welcome_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WelcomeAuthScreen renders user, admin, and guest login options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WelcomeAuthScreen(),
      ),
    );

    expect(find.text('Barkod Hub'), findsOneWidget);
    expect(find.text('Kullanıcı Olarak Giriş Yap'), findsOneWidget);
    expect(find.text('Editör Olarak Giriş Yap'), findsOneWidget);
    expect(find.text('Yönetici (Admin) Olarak Giriş Yap'), findsOneWidget);
    expect(find.text('Misafir Olarak Devam Et (Sınırlı Sorgu)'), findsOneWidget);
  });
}
