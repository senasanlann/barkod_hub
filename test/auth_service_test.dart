import 'package:barkod_hub/core/services/auth_service.dart';
import 'package:barkod_hub/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = AuthService();
  });

  test('default user is guest', () async {
    final user = await service.getCurrentUser();

    expect(user.isGuest, isTrue);
    expect(user.isRegistered, isFalse);
    expect(user.role, UserRole.guest);
  });

  test('guest daily query limit is enforced at 10 queries', () async {
    expect(await service.canPerformGuestQuery(), isTrue);
    expect(await service.getRemainingGuestQueries(), 10);

    for (var i = 0; i < 10; i++) {
      await service.incrementGuestQueryCount();
    }

    expect(await service.getGuestQueryCount(), 10);
    expect(await service.getRemainingGuestQueries(), 0);
    expect(await service.canPerformGuestQuery(), isFalse);
  });

  test('login creates registered user session and bypasses guest limit', () async {
    final loggedIn = await service.login('test@example.com', 'secret123');
    expect(loggedIn, isTrue);

    final user = await service.getCurrentUser();
    expect(user.isRegistered, isTrue);
    expect(user.role, UserRole.user);
    expect(user.email, 'test@example.com');

    for (var i = 0; i < 15; i++) {
      await service.incrementGuestQueryCount();
    }

    expect(await service.canPerformGuestQuery(), isTrue);
  });

  test('logout returns user to guest mode', () async {
    await service.login('user@domain.com', 'pass');
    var user = await service.getCurrentUser();
    expect(user.isRegistered, isTrue);

    await service.logout();
    user = await service.getCurrentUser();
    expect(user.isGuest, isTrue);
  });
}
