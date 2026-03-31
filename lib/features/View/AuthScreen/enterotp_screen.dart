import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
// ─────────────────────────────────────────────
// ENTER OTP
// ─────────────────────────────────────────────
class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.instance;
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
              SizedBox(height: 20.h),
              TextField(
                controller: _otpController,
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
              _buildVerificationText(colors),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reset-password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.mainBtnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.Submit,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.btnTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationText(AppColors colors) {
    // "We sent a verification code to your email. Please check.
    //  If not, resend in 0:22 minutes. Resend"
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 12.sp, color: colors.hintTextColor, height: 1.5),
        children: [
          const TextSpan(
              text:
              'We sent a verification code to your email. Please check. If not, resend in '),
          TextSpan(
            text: '0:22',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: colors.titleTextColor),
          ),
          const TextSpan(text: ' minutes. '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Resend',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.mainBtnColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}