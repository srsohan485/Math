// ═══════════════════════════════════════════════════
//  TERMS AND PRIVACY SCREEN  (API-Driven)
//  File: lib/features/View/TermsScreen/terms_and_privacy_screen.dart
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/AppColor/app_color.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/PrivacyController/privacy_controller.dart';


class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TermsPrivacyController());
    final c = AppColors.instance;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: c.titleTextColor,
            size: 20.sp,
          ),
        ),
        title: Obx(
              () => Text(
            controller.isLoading.value || controller.title.value.isEmpty
                ? AppStrings.policytext.tr
                : controller.title.value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: c.titleTextColor,
            ),
          ),
        ),
      ),
      body: Obx(() {
        // ── Loading State ──────────────────────────
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: c.titleTextColor,
              strokeWidth: 2,
            ),
          );
        }

        // ── Error State ────────────────────────────
        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 48.sp,
                    color: c.normalTextColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: c.normalTextColor,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: controller.retry,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: c.titleTextColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Try Again'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: c.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Success State ──────────────────────────
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.title.value.isNotEmpty) ...[
                Text(
                  controller.title.value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: c.titleTextColor,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              ..._buildContentWidgets(controller.content.value, c),

              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildContentWidgets(String content, AppColors c) {
    if (content.isEmpty) return [];

    final paragraphs = content.split('\n\n');

    return paragraphs.map((para) {
      final trimmed = para.trim();
      if (trimmed.isEmpty) return const SizedBox.shrink();

      final headingRegex = RegExp(r'^\d+\.\s+.+$');
      final isHeading = headingRegex.hasMatch(trimmed) && trimmed.length < 80;

      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Text(
          trimmed,
          style: TextStyle(
            fontSize: isHeading ? 13.sp : 12.5.sp,
            fontWeight:
            isHeading ? FontWeight.w700 : FontWeight.w400,
            color: isHeading ? c.titleTextColor : c.normalTextColor,
            height: 1.6,
          ),
        ),
      );
    }).toList();
  }
}