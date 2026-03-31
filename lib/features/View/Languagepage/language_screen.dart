import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mathsolving/core/AppColor/app_color.dart';
import 'package:mathsolving/core/AppImages/app_images.dart';
import 'package:mathsolving/core/AppText/app_text.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String _selectedLanguage = 'English';
  bool _isDropdownOpen = false;

  final List<String> _languages = [
    'English',
    'Arabic',
    'French',
    'German',
    'Spanish',
    'Turkish',
    'Urdu',
    'Bengali',
  ];

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

              /// Eye of Horus Logo
              Center(
                child: SizedBox(
                  width: 80.w,
                  height: 60.h,
                  child: Image.asset(AppImages.Toplogo)
                ),
              ),

              SizedBox(height: 24.h),

              /// Title
              Text(
                'Select language',
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
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                child: Column(
                  children: [
                    /// Dropdown Button
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

                    /// Dropdown List
                    if (_isDropdownOpen)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          border: Border(
                            left: BorderSide(
                                color: const Color(0xFFE0E0E0), width: 1.5),
                            right: BorderSide(
                                color: const Color(0xFFE0E0E0), width: 1.5),
                            bottom: BorderSide(
                                color: const Color(0xFFE0E0E0), width: 1.5),
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
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = lang;
                                  _isDropdownOpen = false;
                                });
                              },
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
                  onPressed: () {
                    // Handle confirm action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language selected: $_selectedLanguage'),
                        backgroundColor: const Color(0xFF1A2A4A),
                      ),
                    );
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
                    AppStrings.Continue,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.instance.textColor
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

