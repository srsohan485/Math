import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/AuthController/auth_controller.dart';


// ─────────────────────────────────────────────
// ENTER OTP — shared screen for SignUp & Forgot Password flows
// isSignUpFlow: true  → verifySignUpOtp (shows email verified overlay)
// isSignUpFlow: false → verifyForgotOtp (navigates to ResetPassword)
// ─────────────────────────────────────────────
class EnterOtpScreen extends StatelessWidget {
  final bool isSignUpFlow;

  const EnterOtpScreen({super.key, required this.isSignUpFlow});

  @override
  Widget build(BuildContext context) {
    final colors     = AppColors.instance;
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: Image.asset(AppImages.Toplogo, height: 56.h),
              ),
              SizedBox(height: 36.h),
              Text(
                AppStrings.otptext,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.titleTextColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isSignUpFlow
                    ? "We sent a code to verify your email address."
                    : "We sent a code to reset your password.",
                style: TextStyle(fontSize: 13.sp, color: colors.hintTextColor),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.titleTextColor,
                  letterSpacing: 6,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.enterotptext,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: colors.hintTextColor,
                    letterSpacing: 0,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: colors.softMintBackground,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: colors.mainBtnColor),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _buildResendRow(colors, controller),
              const Spacer(),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => isSignUpFlow
                      ? controller.verifySignUpOtp(context)
                      : controller.verifyForgotOtp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.mainBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.btnTextColor,
                    ),
                  )
                      : Text(
                    AppStrings.Submit,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.btnTextColor,
                    ),
                  ),
                ),
              )),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow(AppColors colors, AuthController controller) {
    return Obx(() {
      final secs    = controller.seconds.value;
      final canSend = controller.canResend.value;

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
              fontSize: 12.sp, color: colors.hintTextColor, height: 1.5),
          children: [
            const TextSpan(
              text:
              'We sent a verification code to your email. Please check. If not, resend in ',
            ),
            TextSpan(
              text: '0:${secs.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: colors.titleTextColor),
            ),
            const TextSpan(text: ' minutes. '),
            WidgetSpan(
              child: GestureDetector(
                onTap: canSend ? controller.resendOtp : null,
                child: Text(
                  'Resend',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color:
                    canSend ? colors.mainBtnColor : colors.hintTextColor,
                    decoration: canSend
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}