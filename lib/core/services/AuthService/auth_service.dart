import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/View/AuthScreen/singin_screen.dart';
import '../../storege/storage_service.dart';
import '../app_log.dart';

class AuthService {
  static const String baseUrl = "https://mathapi.dsrt321.online";

  /// ===========================
  /// LOGIN USER
  /// ===========================
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    const endpoint = "/api/users/login/";
    final body = {"email": email, "password": password};

    AppLog.request(endpoint, body: body);

    var url = Uri.parse("$baseUrl$endpoint");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
      await StorageService.saveToken(data["tokens"]["access"]);
      await StorageService.saveRefreshToken(data["tokens"]["refresh"]);
      return {"success": true, "data": data};
    }

    AppLog.error(endpoint, data, statusCode: response.statusCode);
    return {"success": false, "data": data};
  }

  /// ===========================
  /// REGISTER USER
  /// ===========================
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    const endpoint = "/api/users/register/";
    final body = {
      "username": username,
      "email": email,
      "password": password,
      "password_confirm": confirmPassword,
    };

    AppLog.request(endpoint, body: body);

    var url = Uri.parse("$baseUrl$endpoint");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// RESEND OTP
  /// ===========================
  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    const endpoint = "/api/users/resend-otp/";
    final body = {"email": email};

    AppLog.request(endpoint, body: body);

    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// FORGOT PASSWORD (SEND OTP)
  /// ===========================
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    const endpoint = "/api/users/password-reset/";
    final body = {"email": email};

    AppLog.request(endpoint, body: body);

    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// VERIFY EMAIL OTP
  /// ===========================
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    const endpoint = "/api/users/verify-email/";
    final body = {"email": email, "otp": otp};

    AppLog.request(endpoint, body: body);

    var url = Uri.parse("$baseUrl$endpoint");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// VERIFY EMAIL (PASSWORD RESET)
  /// ===========================
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    const endpoint = "/api/users/password-reset/verify/";
    final body = {"email": email, "otp": otp};

    AppLog.request(endpoint, body: body);

    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// RESET PASSWORD
  /// ===========================
  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String new_password,
    required String confirm_password,
  }) async {
    const endpoint = "/api/users/password-reset/confirm/";
    final body = {
      "reset_token": resetToken,
      "new_password": new_password,
      "password_confirm": confirm_password,
    };

    AppLog.request(endpoint, body: body);

    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      AppLog.response(endpoint, data);
    } else {
      AppLog.error(endpoint, data, statusCode: response.statusCode);
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// ===========================
  /// GET SAVED ACCESS TOKEN
  /// ===========================
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// ===========================
  /// GET SAVED REFRESH TOKEN
  /// ===========================
  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  // ════════════════════════════════════════════════════
  //  LOGOUT USER
  //  POST /api/users/logout/
  //  Body: { "refresh": "<refresh_token>" }
  // ════════════════════════════════════════════════════
  static Future<void> logout() async {
    const endpoint = "/api/users/logout/";

    final accessToken  = StorageService.accessToken;
    final refreshToken = StorageService.refreshToken;

    AppLog.request(endpoint, method: 'POST', body: {"refresh": "***"});

    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          if (accessToken != null && accessToken.isNotEmpty)
            "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "refresh": refreshToken ?? "",
        }),
      );

      AppLog.response(endpoint, {
        "status": response.statusCode,
        "body": response.body,
      });

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 205) {
        AppLog.info("Logout API success ✅");
      } else {
        AppLog.error(endpoint, response.body,
            statusCode: response.statusCode);
      }
    } catch (e) {
      AppLog.info("Logout network error (ignoring): $e");
    }

    // ✅ সবসময় local storage clear করো
    await StorageService.logout();

    // ✅ ChatController instance delete করো যাতে পরের user এর data আলাদা থাকে
    // Lazy import এড়াতে dynamic delete ব্যবহার করা হচ্ছে
    try {
      Get.delete(tag: 'ChatController', force: true);
    } catch (_) {}

    Get.offAll(() => const SignInScreen());
  }

  /// ===========================
  /// PROTECTED API CALL EXAMPLE
  /// ===========================
  static Future<http.Response> fetchTermsPrivacy() async {
    const endpoint = "/api/users/terms-privacy/";

    AppLog.request(endpoint, method: 'GET');

    var token = await getAccessToken();
    var url = Uri.parse("$baseUrl$endpoint");

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      AppLog.response(endpoint, jsonDecode(response.body));
    } else {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
    }

    return response;
  }
}