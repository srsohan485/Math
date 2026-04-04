import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/AuthController/auth_controller.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.instance;
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: Image.asset(AppImages.Toplogo, height: 56.h),
              ),
              SizedBox(height: 28.h),
              Text(
                AppStrings.signin.tr,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.titleTextColor,
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                controller: controller.emailController,
                hint: AppStrings.email.tr,
                colors: colors,
              ),
              SizedBox(height: 12.h),
              Obx(() => _buildTextField(
                controller: controller.passwordController,
                hint: AppStrings.password.tr,
                colors: colors,
                obscure: controller.isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colors.hintTextColor,
                    size: 20.sp,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.goToForgotPassword,
                  child: Text(
                    AppStrings.forgotpassword.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colors.hintTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Obx(() => _buildPrimaryButton(
                label: AppStrings.singin.tr,
                colors: colors,
                isLoading: controller.isLoading.value,
                onTap: controller.isLoading.value ? null : controller.login,
              )),
              SizedBox(height: 20.h),
              _buildDivider(colors),
              SizedBox(height: 16.h),
              _buildSocialRow(colors),
              SizedBox(height: 24.h),
              _buildBottomText(
                prefix: AppStrings.dontaccounttext.tr,
                action: AppStrings.signup.tr,
                colors: colors,
                onTap: controller.goToSignUp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required AppColors colors,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 14.sp, color: colors.titleTextColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: colors.hintTextColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.softMintBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.mainBtnColor),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required AppColors colors,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.mainBtnColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          width: 22.w,
          height: 22.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.btnTextColor,
          ),
        )
            : Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: colors.btnTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(AppColors colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'or'.tr,
            style: TextStyle(fontSize: 13.sp, color: colors.hintTextColor),
          ),
        ),
        Expanded(child: Divider(color: colors.border)),
      ],
    );
  }

  Widget _buildSocialRow(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(AppImages.google, colors),
        SizedBox(width: 16.w),
        _buildSocialButton(AppImages.google, colors),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath, AppColors colors) {
    return Container(
      width: 90.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: colors.softMintBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Image.asset(assetPath, height: 24.h),
      ),
    );
  }

  Widget _buildBottomText({
    required String prefix,
    required String action,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '$prefix ',
          style: TextStyle(fontSize: 13.sp, color: colors.hintTextColor),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  action,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.mainBtnColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}