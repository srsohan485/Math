import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/AuthController/auth_controller.dart';


class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.instance;
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
                AppStrings.resetpassword,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.titleTextColor,
                ),
              ),
              SizedBox(height: 20.h),
              Obx(() => _buildTextField(
                controller: controller.passwordController,
                hint: AppStrings.password,
                colors: colors,
                obscure: controller.isPasswordVisible.value,
                onToggle: controller.togglePasswordVisibility,
              )),
              SizedBox(height: 12.h),
              Obx(() => _buildTextField(
                controller: controller.retypePasswordController,
                hint: AppStrings.retypepassword,
                colors: colors,
                obscure: controller.isRetypePasswordVisible.value,
                onToggle: controller.toggleRetypePasswordVisibility,
              )),
              const Spacer(),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
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
                    'Confirm',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required AppColors colors,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 14.sp, color: colors.titleTextColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: colors.hintTextColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colors.hintTextColor,
            size: 20.sp,
          ),
          onPressed: onToggle,
        ),
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
}