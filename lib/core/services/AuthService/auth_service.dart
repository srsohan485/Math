import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/View/AuthScreen/singin_screen.dart';
import '../../storege/storage_service.dart';

class AuthService {

  static const String baseUrl = "https://mathapi.dsrt321.online"; // Change according to your server



  /// ===========================
  /// LOGIN USER
  /// ===========================
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    var url = Uri.parse("$baseUrl/api/users/login/");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Access token save করুন
      await StorageService.saveToken(data["tokens"]["access"]);

      // Refresh token ও save করুন
      await StorageService.saveRefreshToken(data["tokens"]["refresh"]);

      return {"success": true, "data": data};
    }

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
    var url = Uri.parse("$baseUrl/api/users/register/");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "password_confirm": confirmPassword,
      }),
    );

    var data = jsonDecode(response.body);

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
    final url = Uri.parse("$baseUrl/api/users/resend-otp/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
      }),
    );

    print(response.statusCode);
    print(response.body);


    return {
      "status": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }

  /// ===========================
  /// FORGOT PASSWORD (SEND OTP)sa
  /// ===========================
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {

    final url = Uri.parse("$baseUrl/api/users/password-reset/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
      }),
    );

    final data = jsonDecode(response.body);

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
    var url = Uri.parse("$baseUrl/api/users/verify-email/");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    var data = jsonDecode(response.body);

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

  // OTP verify API
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/password-reset/verify/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
    print(response.statusCode);

    return {
      "status": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }

  /// ===========================
  /// GET SAVED REFRESH TOKEN
  /// ===========================
  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  /// ===========================
  /// LOGOUT USER
  /// ===========================
  static Future<void> logout() async {
    await StorageService.logout(); // সব clear
    Get.offAll(() => const SignInScreen());
  }

  /// ===========================
  /// PROTECTED API CALL EXAMPLE
  /// ===========================
  static Future<http.Response> fetchTermsPrivacy() async {
    var token = await getAccessToken();

    var url = Uri.parse("$baseUrl/api/users/terms-privacy/");

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String new_password,
    required String confirm_password,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/password-reset/confirm/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "reset_token": resetToken,
        "new_password": new_password,
        "password_confirm": confirm_password,
      }),
    );

    print(response.statusCode);
    print(response.body);

    return {
      "status": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }
}