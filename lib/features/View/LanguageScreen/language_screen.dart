import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mathsolving/core/AppColor/app_color.dart';
import 'package:mathsolving/core/AppImages/app_images.dart';

import '../../Controller/LanguageController/language_controller.dart';
import '../AuthScreen/singin_screen.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  // Lazily find or create the controller
  final LanguageController _langController = Get.put(LanguageController());

  bool _isDropdownOpen = false;

  // Display names shown in the UI
  final List<String> _languages = ['English', 'Bulgarian'];

  // Local selection — starts from whatever is persisted
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _langController.currentDisplayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              /// Logo
              Center(
                child: SizedBox(
                  width: 80.w,
                  height: 60.h,
                  child: Image.asset(AppImages.Toplogo),
                ),
              ),

              SizedBox(height: 24.h),

              /// Title — uses GetX translation
              Text(
                'Select language'.tr,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 24.h),

              /// Dropdown
              GestureDetector(
                onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
                child: Column(
                  children: [
                    // ── Dropdown Button ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: _isDropdownOpen
                            ? BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        )
                            : BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _isDropdownOpen
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isDropdownOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF4CAF50),
                              size: 22.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Dropdown List ────────────────────────────────
                    if (_isDropdownOpen)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          border: const Border(
                            left:   BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                            right:  BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _languages.map((lang) {
                            final isSelected = lang == _selectedLanguage;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedLanguage = lang;
                                _isDropdownOpen   = false;
                              }),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 13.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF5F5F5)
                                      : Colors.white,
                                ),
                                child: Text(
                                  lang,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: isSelected
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFBDBDBD),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              /// Confirm Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Persist & apply the locale via controller
                    await _langController.changeLanguageByName(_selectedLanguage);

                    // 2. Navigate
                    Get.off(() => const SignInScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2A4A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    'Continue'.tr,    // ← localized
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.instance.baseColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}