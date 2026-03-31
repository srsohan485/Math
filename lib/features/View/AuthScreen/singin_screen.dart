import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mathsolving/features/View/AuthScreen/singup_srceen.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.instance;
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
                child: Image.asset(
                  AppImages.Toplogo,
                  height: 56.h,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                AppStrings.signin,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.titleTextColor,
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                controller: _emailController,
                hint: AppStrings.email,
                colors: colors,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _passwordController,
                hint: AppStrings.password,
                colors: colors,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colors.hintTextColor,
                    size: 20.sp,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    AppStrings.forgotpassword,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colors.hintTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              _buildPrimaryButton(
                label: AppStrings.singin,
                colors: colors,
                onTap: () {},
              ),
              SizedBox(height: 20.h),
              _buildDivider(colors),
              SizedBox(height: 16.h),
              _buildSocialRow(colors),
              SizedBox(height: 24.h),
              _buildBottomText(
                prefix: AppStrings.dontaccounttext,
                action: AppStrings.signup,
                colors: colors,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()))
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
    required VoidCallback onTap,
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
        child: Text(
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
            'or',
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
