import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  static const _tokenKey               = 'access_token';
  static const _refreshTokenKey        = 'refresh_token';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _usernameKey            = 'username';
  static const _emailKey               = 'email';
  static const _profilePictureKey      = 'profile_picture';

  // ── Onboarding ───────────────────────────────────
  static Future<void> saveOnboardingCompleted() async =>
      await _box.write(_onboardingCompletedKey, true);

  static bool get isOnboardingCompleted =>
      _box.read(_onboardingCompletedKey) ?? false;

  // ── Access Token ─────────────────────────────────
  static Future<void> saveToken(String accessToken) async =>
      await _box.write(_tokenKey, accessToken);

  static String? get accessToken => _box.read(_tokenKey);
  static bool get hasToken => accessToken != null && accessToken!.isNotEmpty;

  // ── Refresh Token ────────────────────────────────
  static Future<void> saveRefreshToken(String token) async {
    await _box.write('refresh_token', token);
  }

  static String? get refreshToken => _box.read<String>('refresh_token');

  // ── User Info ────────────────────────────────────
  static Future<void> saveUserInfo({
    required String username,
    required String email,
    String? profilePicture,
  }) async {
    await _box.write(_usernameKey, username);
    await _box.write(_emailKey, email);
    await _box.write(_profilePictureKey, profilePicture ?? '');
  }

  static String get username       => _box.read(_usernameKey)        ?? '';
  static String get email          => _box.read(_emailKey)           ?? '';
  static String get profilePicture => _box.read(_profilePictureKey)  ?? '';

  static Future<void> saveUsername(String value) async =>
      await _box.write(_usernameKey, value);

  // ── Clear ────────────────────────────────────────
  static Future<void> clearToken() async {
    await _box.remove(_tokenKey);
    await _box.remove(_refreshTokenKey);
  }

  static Future<void> logout() async => await _box.erase();
}