import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/user_model.dart';

class AuthService {
  AuthService({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  static const String _userSessionKey = 'auth_user_session';
  static const String _guestQueryCountKey = 'auth_guest_query_count';
  static const String _guestQueryDateKey = 'auth_guest_query_date';

  static const int maxGuestDailyQueries = 10;

  Future<UserModel> getCurrentUser() async {
    final prefs = await _preferences;
    final raw = prefs.getString(_userSessionKey);
    if (raw == null) {
      return UserModel.guest();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return UserModel.guest();
    }
  }

  Future<bool> login(String email, String password) async {
    final prefs = await _preferences;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.trim().isEmpty) {
      return false;
    }

    final role = trimmedEmail.toLowerCase().contains('admin')
        ? UserRole.admin
        : trimmedEmail.toLowerCase().contains('editor')
            ? UserRole.editor
            : UserRole.user;

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: trimmedEmail,
      name: trimmedEmail.split('@').first,
      role: role,
      token: 'jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
    return true;
  }

  Future<void> loginAsGuest() async {
    final prefs = await _preferences;
    await prefs.remove(_userSessionKey);
  }

  Future<void> logout() async {
    final prefs = await _preferences;
    await prefs.remove(_userSessionKey);
  }

  Future<void> _resetGuestCountIfNewDay(SharedPreferences prefs) async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_guestQueryDateKey);

    if (savedDate != todayStr) {
      await prefs.setString(_guestQueryDateKey, todayStr);
      await prefs.setInt(_guestQueryCountKey, 0);
    }
  }

  Future<int> getGuestQueryCount() async {
    final prefs = await _preferences;
    await _resetGuestCountIfNewDay(prefs);
    return prefs.getInt(_guestQueryCountKey) ?? 0;
  }

  Future<int> getRemainingGuestQueries() async {
    final count = await getGuestQueryCount();
    final remaining = maxGuestDailyQueries - count;
    return remaining < 0 ? 0 : remaining;
  }

  Future<bool> canPerformGuestQuery() async {
    final user = await getCurrentUser();
    if (user.isRegistered) return true;

    final remaining = await getRemainingGuestQueries();
    return remaining > 0;
  }

  Future<void> incrementGuestQueryCount() async {
    final user = await getCurrentUser();
    if (user.isRegistered) return;

    final prefs = await _preferences;
    await _resetGuestCountIfNewDay(prefs);

    final current = prefs.getInt(_guestQueryCountKey) ?? 0;
    await prefs.setInt(_guestQueryCountKey, current + 1);
  }
}
