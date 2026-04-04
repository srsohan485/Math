import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/ProfileController/profile_controller.dart';
import '../MainScreen/termscondition_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final c = AppColors.instance;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: c.titleTextColor, size: 20.sp),
        ),
        title: Text(
          'Profile'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: c.titleTextColor,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: c.mainBtnColor),
          );
        }

        return Column(
          children: [
            SizedBox(height: 16.h),

            // ── User card ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundImage:
                    controller.profilePicture.value.isNotEmpty
                        ? NetworkImage(controller.profilePicture.value)
                    as ImageProvider
                        : AssetImage(AppImages.sohan),
                    backgroundColor: c.border,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.username.value.isNotEmpty
                              ? controller.username.value
                              : AppStrings.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: c.titleTextColor,
                          ),
                        )),
                        SizedBox(height: 2.h),
                        Obx(() => Text(
                          controller.email.value.isNotEmpty
                              ? controller.email.value
                              : '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: c.hintTextColor,
                          ),
                        )),
                      ],
                    ),
                  ),
                  _ThreeDotMenu(colors: c, controller: controller),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            Divider(color: c.border, thickness: 1, height: 1),

            // ── Menu items ────────────────────────────────
            _ProfileMenuItem(
              icon: Icons.shield_outlined,
              label: 'Terms and privacy policy'.tr,
              colors: c,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsAndPrivacyScreen(),
                ),
              ),
              showArrow: true,
            ),

            Divider(
                color: c.border,
                thickness: 1,
                height: 1,
                indent: 20.w,
                endIndent: 20.w),

            Obx(() => _ProfileMenuItem(
              icon: Icons.logout_rounded,
              label: 'Log out'.tr,
              colors: c,
              onTap: () => _showLogoutDialog(context, c, controller),
              showArrow: false,
              isLoading: controller.isLoggingOut.value,
            )),
          ],
        );
      }),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AppColors c, ProfileController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Log out'.tr,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: c.titleTextColor)),
        content: Text('logout_confirm'.tr,
            style: TextStyle(fontSize: 13.sp, color: c.hintTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr,
                style: TextStyle(color: c.hintTextColor, fontSize: 13.sp)),
          ),
          Obx(() => TextButton(
            onPressed: controller.isLoggingOut.value
                ? null
                : () {
              Navigator.pop(context);
              controller.logout(context);
            },
            child: controller.isLoggingOut.value
                ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: c.error),
            )
                : Text('Log out'.tr,
                style: TextStyle(
                    color: c.error,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}

// ── 3-dot popup menu ──────────────────────────────────────
class _ThreeDotMenu extends StatelessWidget {
  final AppColors colors;
  final ProfileController controller;

  const _ThreeDotMenu({required this.colors, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded,
          color: colors.titleTextColor, size: 22.sp),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: colors.softMintBackground,
      elevation: 4,
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog(context);
        } else if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 18.sp, color: colors.titleTextColor),
              SizedBox(width: 8.w),
              Text('Edit'.tr,
                  style: TextStyle(
                      fontSize: 14.sp, color: colors.titleTextColor)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 18.sp, color: colors.error),
              SizedBox(width: 8.w),
              Text('Delete account'.tr,
                  style: TextStyle(fontSize: 14.sp, color: colors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: controller.username.value);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.edit_outlined,
                  size: 18.sp, color: colors.titleTextColor),
              SizedBox(width: 6.w),
              Text('Edit'.tr,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.titleTextColor)),
            ]),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                    color: colors.hintTextColor, shape: BoxShape.circle),
                child:
                Icon(Icons.close_rounded, color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(fontSize: 14.sp, color: colors.titleTextColor),
          decoration: InputDecoration(
            hintText: 'edit_username_hint'.tr,
            hintStyle:
            TextStyle(color: colors.hintTextColor, fontSize: 14.sp),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.mainBtnColor)),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isUpdating.value
                  ? null
                  : () => controller.updateUsername(ctrl.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.mainBtnColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: controller.isUpdating.value
                  ? SizedBox(
                height: 18.h,
                width: 18.h,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.btnTextColor),
              )
                  : Text('save'.tr,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.btnTextColor,
                      fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete account'.tr,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colors.titleTextColor)),
        content: Text('delete_account_confirm'.tr,
            style: TextStyle(fontSize: 13.sp, color: colors.hintTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr,
                style:
                TextStyle(color: colors.hintTextColor, fontSize: 13.sp)),
          ),
          Obx(() => TextButton(
            onPressed: controller.isDeleting.value
                ? null
                : () {
              Navigator.pop(context);
              controller.deleteAccount(context);
            },
            child: controller.isDeleting.value
                ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: colors.error),
            )
                : Text('delete'.tr,
                style: TextStyle(
                    color: colors.error,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}

// ── Profile menu row ───────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final bool showArrow;
  final bool isLoading;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    required this.showArrow,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: colors.titleTextColor),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.titleTextColor,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            if (isLoading)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.hintTextColor),
              )
            else if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16.sp, color: colors.hintTextColor),
          ],
        ),
      ),
    );
  }
}