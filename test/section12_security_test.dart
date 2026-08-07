import 'package:barkod_hub/core/services/auth_service.dart';
import 'package:barkod_hub/core/services/secure_storage_service.dart';
import 'package:barkod_hub/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Section 12 Security & Authentication Tests', () {
    test('SecureStorageService saves and retrieves access and refresh tokens', () async {
      final service = SecureStorageService();
      await service.saveTokens(
        accessToken: 'access_12345',
        refreshToken: 'refresh_67890',
      );

      expect(await service.getAccessToken(), equals('access_12345'));
      expect(await service.getRefreshToken(), equals('refresh_67890'));

      await service.clearTokens();
      expect(await service.getAccessToken(), isNull);
    });

    test('AuthService maxGuestDailyQueries limit is 50', () {
      expect(AuthService.maxGuestDailyQueries, equals(50));
    });

    testWidgets('SettingsScreen displays KVKK privacy section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KVKK Aydınlatma Metni'), findsOneWidget);
    });
  });
}
