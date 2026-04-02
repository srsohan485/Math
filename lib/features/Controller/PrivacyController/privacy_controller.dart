// ═══════════════════════════════════════════════════
//  TERMS AND PRIVACY CONTROLLER
//  File: lib/features/Controller/terms_privacy_controller.dart
// ═══════════════════════════════════════════════════

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/storege/storage_service.dart';
import '../../../core/services/app_log.dart';

class TermsPrivacyController extends GetxController {
  // ── Observable State ────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString title = ''.obs;
  final RxString content = ''.obs;

  static const String _baseUrl = "https://mathapi.dsrt321.online";
  static const String _endpoint = "/api/users/terms-privacy/";

  // ── Lifecycle ────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchTermsPrivacy();
  }

  // ── Fetch API ────────────────────────────────────
  Future<void> fetchTermsPrivacy() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      AppLog.request(_endpoint, method: 'GET');

      final token = StorageService.accessToken;

      final url = Uri.parse('$_baseUrl$_endpoint');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppLog.response(_endpoint, data);

        title.value = data['title'] ?? '';
        content.value = data['content'] ?? '';
      } else {
        AppLog.error(_endpoint, data, statusCode: response.statusCode);
        hasError.value = true;
        errorMessage.value =
            data['detail'] ?? data['message'] ?? 'Something went wrong.';
      }
    } catch (e) {
      AppLog.error(_endpoint, e.toString());
      hasError.value = true;
      errorMessage.value = 'Failed to load. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Retry ────────────────────────────────────────
  void retry() => fetchTermsPrivacy();
}