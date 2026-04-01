import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/services/AuthService/auth_service.dart';
import '../../View/AuthScreen/enterotp_screen.dart';
import '../../View/AuthScreen/forgot_password.dart';
import '../../View/AuthScreen/reset_password.dart';
import '../../View/AuthScreen/singin_screen.dart';
import '../../View/AuthScreen/singup_srceen.dart';
import '../../View/MainScreen/chart_screen.dart';


class AuthController extends GetxController {
  // ─── Text Controllers ───────────────────────────────
  final usernameController        = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController             = TextEditingController();
  final retypePasswordController  = TextEditingController();

  // ─── Observable States ──────────────────────────────
  final isLoading                = false.obs;
  final isPasswordVisible        = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isRetypePasswordVisible  = false.obs;
  final seconds                  = 60.obs;
  final canResend                = false.obs;

  // ─── Internal ───────────────────────────────────────
  String _otpEmail   = '';
  String _resetToken = '';
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    retypePasswordController.dispose();
    super.onClose();
  }

  // ════════════════════════════════════════════════════
  //  Visibility Toggles
  // ════════════════════════════════════════════════════

  void togglePasswordVisibility()        => isPasswordVisible.value        = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  void toggleRetypePasswordVisibility()  => isRetypePasswordVisible.value  = !isRetypePasswordVisible.value;

  // ════════════════════════════════════════════════════
  //  Navigation Helpers
  // ════════════════════════════════════════════════════

  void goToSignIn()         => Get.to(() => const SignInScreen());
  void goToSignUp()         => Get.to(() => const SignUpScreen());
  void goToForgotPassword() => Get.to(() => const ForgotPasswordScreen());

  // ════════════════════════════════════════════════════
  //  OTP Timer
  // ════════════════════════════════════════════════════

  void startTimer() {
    canResend.value = false;
    seconds.value   = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      final result = await AuthService().resendOtp(email: _otpEmail);

      if (result["status"] == 200) {
        _showSuccess("OTP resent successfully");
        startTimer();
      } else {
        _showError(_extractMessage(result["data"]) ?? "Failed to resend OTP");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Sign Up
  // ════════════════════════════════════════════════════

  Future<void> signUp() async {
    final username        = usernameController.text.trim();
    final email           = emailController.text.trim();
    final password        = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return _showError("Please fill in all fields");
    }

    if (password != confirmPassword) {
      return _showError("Passwords do not match");
    }

    isLoading.value = true;

    try {
      final result = await AuthService.registerUser(
        email: email,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result["status"] == 201) {
        _showSuccess(_extractMessage(result["data"]) ?? "Registration successful");
        _otpEmail = email;
        startTimer();
        // Clear OTP field before navigating
        otpController.clear();
        Get.to(() => const EnterOtpScreen(isSignUpFlow: true));
      } else {
        _showError(_extractMessage(result["data"]) ?? "Registration failed");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Sign In
  // ════════════════════════════════════════════════════

  Future<void> login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return _showError("Please fill in all fields");
    }

    isLoading.value = true;

    try {
      final result = await AuthService().loginUser(
        email: email,
        password: password,
      );

      if (result["success"] == true) {
        _showSuccess("Login Successful");
        Get.offAll(() => MainChatScreen());
      } else {
        _showError(_extractMessage(result["data"]) ?? "Login failed");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Forgot Password — Send OTP
  // ════════════════════════════════════════════════════

  Future<void> sendForgotOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) return _showError("Please enter your email");

    isLoading.value = true;

    try {
      final result = await AuthService().forgotPassword(email: email);

      if (result["status"] == 200) {
        _showSuccess("OTP sent to your email");
        _otpEmail = email;
        startTimer();
        otpController.clear();
        Get.to(() => const EnterOtpScreen(isSignUpFlow: false));
      } else {
        _showError(_extractMessage(result["data"]) ?? "Failed to send OTP");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Verify OTP — Sign Up flow
  // ════════════════════════════════════════════════════

  Future<void> verifySignUpOtp(BuildContext context) async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      return _showError("Please enter a valid 6-digit OTP");
    }

    isLoading.value = true;

    try {
      final result = await AuthService().verifyOtp(email: _otpEmail, otp: otp);

      if (result["status"] == 200) {
        _timer?.cancel();
        _showEmailVerifiedOverlay(context);
      } else {
        _showError(_extractMessage(result["data"]) ?? "Invalid OTP");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Verify OTP — Forgot Password flow
  // ════════════════════════════════════════════════════

  Future<void> verifyForgotOtp(BuildContext context) async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      return _showError("Please enter a valid 6-digit OTP");
    }

    isLoading.value = true;

    try {
      final result = await AuthService().verifyEmail(email: _otpEmail, otp: otp);

      if (result["status"] == 200) {
        _timer?.cancel();
        // Extract reset_token safely from the response map
        final data = result["data"];
        _resetToken = (data is Map ? data["reset_token"] : null) ?? '';
        // Clear password fields before navigating
        passwordController.clear();
        retypePasswordController.clear();
        Get.to(() => const ResetPasswordScreen());
      } else {
        _showError(_extractMessage(result["data"]) ?? "Invalid OTP");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Reset Password
  // ════════════════════════════════════════════════════

  Future<void> resetPassword() async {
    final password       = passwordController.text;
    final retypePassword = retypePasswordController.text;

    if (password.isEmpty || retypePassword.isEmpty) {
      return _showError("Please fill in all fields");
    }

    if (password.length < 6) {
      return _showError("Password must be at least 6 characters");
    }

    if (password != retypePassword) {
      return _showError("Passwords do not match");
    }

    if (_resetToken.isEmpty) {
      return _showError("Reset token is missing. Please try again.");
    }

    isLoading.value = true;

    try {
      final result = await AuthService().resetPassword(
        resetToken: _resetToken,
        new_password: password,
        confirm_password: retypePassword,
      );

      if (result["status"] == 200) {
        _showSuccess("Password reset successful");
        _resetToken = '';
        Get.offAll(() => const SignInScreen());
      } else {
        // result["data"] is a Map — extract human-readable message
        _showError(_extractMessage(result["data"]) ?? "Reset failed");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Private Helpers
  // ════════════════════════════════════════════════════

  /// Safely extract a human-readable message from API response data.
  /// Handles String, Map with "message"/"detail"/"error" keys, or any other type.
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.isNotEmpty ? data : null;
    if (data is Map) {
      // Try common message keys returned by Django REST APIs
      for (final key in ["message", "detail", "error", "non_field_errors"]) {
        final value = data[key];
        if (value != null) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          return value.toString();
        }
      }
      // Fallback: join all values
      return data.values.map((v) => v.toString()).join(", ");
    }
    return data.toString();
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  void _showEmailVerifiedOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 300,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppImages.Confirmimgae, height: 50, width: 50),
                  const SizedBox(height: 16),
                  const Text(
                    "Email Verified!",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_otpEmail,
                      style: const TextStyle(fontSize: 16)),
                  const Text(
                    "Your email address has been successfully verified",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        overlayEntry?.remove();
                        Get.offAll(() => MainChatScreen());
                      },
                      child: const Text("Continue"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}