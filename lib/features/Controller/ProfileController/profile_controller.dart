import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/app_log.dart';
import '../../../core/storege/storage_service.dart'; // ← AppLog import
import '../../View/AuthScreen/singin_screen.dart';

class ProfileController extends GetxController {
  final ApiServices _apiServices;

  ProfileController({ApiServices? apiServices})
      : _apiServices = apiServices ??
      ApiServices(baseUrl: 'https://mathapi.dsrt321.online');

  final RxBool isLoading    = false.obs;
  final RxBool isUpdating   = false.obs;
  final RxBool isDeleting   = false.obs;
  final RxBool isLoggingOut = false.obs;

  final RxInt    userId         = 0.obs;
  final RxString username       = ''.obs;
  final RxString email          = ''.obs;
  final RxString profilePicture = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    fetchProfile();
  }

  void _loadFromStorage() {
    AppLog.info('📂 Loading profile from local storage...');
    username.value       = StorageService.username;
    email.value          = StorageService.email;
    profilePicture.value = StorageService.profilePicture;
    AppLog.info('📂 Storage → username: ${username.value} | email: ${email.value}');
  }

  Map<String, String> get _authHeader => {
    'Authorization': 'Bearer ${StorageService.accessToken ?? ''}',
  };

  // ═══════════════════════════════════════════════
  //  1. GET /api/users/profile/
  // ═══════════════════════════════════════════════
  Future<void> fetchProfile() async {
    try {
      if (username.value.isEmpty) isLoading.value = true;

      AppLog.request('/api/users/profile/', method: 'GET');

      final response = await _apiServices.get(
        '/api/users/profile/',
        headers: _authHeader,
      );

      AppLog.response('/api/users/profile/', response);

      userId.value         = response['id']              ?? 0;
      username.value       = response['username']        ?? '';
      email.value          = response['email']           ?? '';
      profilePicture.value = response['profile_picture'] ?? '';

      await StorageService.saveUserInfo(
        username:       username.value,
        email:          email.value,
        profilePicture: profilePicture.value,
      );
      AppLog.info('💾 Profile saved to storage.');
    } catch (e) {
      AppLog.error('/api/users/profile/', e.toString());
      if (username.value.isEmpty) {
        _showErrorSnackbar('Failed to load profile', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════
  //  2. PUT /api/users/profile/ — username update
  // ═══════════════════════════════════════════════
  Future<void> updateUsername(String newUsername) async {
    final trimmed = newUsername.trim();

    if (trimmed.isEmpty) {
      _showErrorSnackbar('Validation', 'Username cannot be empty.');
      return;
    }

    if (trimmed == username.value) {
      Get.back();
      return;
    }

    try {
      isUpdating.value = true;

      AppLog.request('/api/users/profile/',
          method: 'PUT', body: {'username': trimmed});

      final response = await _apiServices.put(
        '/api/users/profile/',
        headers: _authHeader,
        body: {'username': trimmed},
      );

      AppLog.response('/api/users/profile/', response);

      username.value       = response['username']        ?? trimmed;
      email.value          = response['email']           ?? email.value;
      profilePicture.value = response['profile_picture'] ?? profilePicture.value;

      await StorageService.saveUserInfo(
        username:       username.value,
        email:          email.value,
        profilePicture: profilePicture.value,
      );
      AppLog.info('💾 Updated username saved to storage.');

      Get.back();
      _showSuccessSnackbar('Updated!', 'Username changed to "${username.value}"');
    } catch (e) {
      AppLog.error('/api/users/profile/', e.toString());
      _showErrorSnackbar('Update Failed', e.toString());
    } finally {
      isUpdating.value = false;
    }
  }

  // ═══════════════════════════════════════════════
  //  3. POST /api/users/logout/
  // ═══════════════════════════════════════════════
  Future<void> logout(BuildContext context) async {
    try {
      isLoggingOut.value = true;

      AppLog.request('/api/users/logout/',
          method: 'POST', body: {'refresh': '***hidden***'});

      await _apiServices.post(
        '/api/users/logout/',
        headers: _authHeader,
        body: {'refresh': StorageService.refreshToken},
      );

      AppLog.info('✅ Logout API success.');
    } catch (e) {
      AppLog.error('/api/users/logout/', e.toString());
      // Clear session regardless
    } finally {
      isLoggingOut.value = false;
      await StorageService.logout();
      AppLog.info('🗑️  Local storage cleared. Navigating to SignIn.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );
    }
  }

  // ═══════════════════════════════════════════════
  //  4. DELETE /api/users/profile/
  // ═══════════════════════════════════════════════
  Future<void> deleteAccount(BuildContext context) async {
    try {
      isDeleting.value = true;

      AppLog.request('/api/users/profile/', method: 'DELETE');

      await _apiServices.delete('/api/users/profile/', headers: _authHeader);

      AppLog.info('✅ Account deleted successfully.');

      await StorageService.logout();
      AppLog.info('🗑️  Local storage cleared. Navigating to SignIn.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );
    } catch (e) {
      AppLog.error('/api/users/profile/', e.toString());
      _showErrorSnackbar('Delete Failed', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  // ── Snackbar Helpers ─────────────────────────────
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white));
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        icon: const Icon(Icons.error_outline, color: Colors.white));
  }
}