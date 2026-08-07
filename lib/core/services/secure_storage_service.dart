import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final Future<SharedPreferences> _preferences;

  SecureStorageService({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  static const String _accessTokenKey = 'sec_access_token';
  static const String _refreshTokenKey = 'sec_refresh_token';

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    final prefs = await _preferences;
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await _preferences;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
