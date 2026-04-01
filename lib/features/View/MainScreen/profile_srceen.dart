import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mathsolving/features/View/MainScreen/termscondition_screen.dart';

import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';


// ═══════════════════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════════════════
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          AppStrings.profile,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: c.titleTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),

          // ── User card ───────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26.r,
                  backgroundImage: AssetImage(AppImages.Centerlogo2),
                  backgroundColor: c.border,
                ),
                SizedBox(width: 12.w),

                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: c.titleTextColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'nusratJahan@gmail.com',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: c.hintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3-dot menu
                _ThreeDotMenu(colors: c),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          Divider(color: c.border, thickness: 1, height: 1),

          // ── Menu items ──────────────────────────────
          _ProfileMenuItem(
            icon: Icons.shield_outlined,
            label: AppStrings.termsconditiontext,
            colors: c,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TermsAndPrivacyScreen(),
              ),
            ),
            showArrow: true,
          ),

          Divider(color: c.border, thickness: 1, height: 1,
              indent: 20.w, endIndent: 20.w),

          _ProfileMenuItem(
            icon: Icons.logout_rounded,
            label: AppStrings.Logout,
            colors: c,
            onTap: () => _showLogoutDialog(context, c),
            showArrow: false,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppColors c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Log out',
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.w700,
                color: c.titleTextColor)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(fontSize: 13.sp, color: c.hintTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: c.hintTextColor, fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/sign-in', (r) => false);
            },
            child: Text('Log out',
                style: TextStyle(
                    color: c.error,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── 3-dot popup menu ────────────────────────────────────
class _ThreeDotMenu extends StatelessWidget {
  final AppColors colors;
  const _ThreeDotMenu({required this.colors});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded,
          color: colors.titleTextColor, size: 22.sp),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      color: colors.softMintBackground,
      elevation: 4,
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog(context, colors);
        } else if (value == 'delete') {
          _showDeleteDialog(context, colors);
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
              Text(AppStrings.edit,
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
              Text(AppStrings.deletetext,
                  style: TextStyle(
                      fontSize: 14.sp, color: colors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, AppColors c) {
    final ctrl = TextEditingController(text: AppStrings.name1);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.edit_outlined, size: 18.sp, color: c.titleTextColor),
              SizedBox(width: 6.w),
              Text(AppStrings.edit,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: c.titleTextColor)),
            ]),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                    color: c.hintTextColor,
                    shape: BoxShape.circle),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(fontSize: 14.sp, color: c.titleTextColor),
          decoration: InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(color: c.hintTextColor, fontSize: 14.sp),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: c.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: c.mainBtnColor)),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.mainBtnColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Save',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: c.btnTextColor,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppColors c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Account',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: c.titleTextColor)),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(fontSize: 13.sp, color: c.hintTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: c.hintTextColor, fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Delete',
                style: TextStyle(
                    color: c.error,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Profile menu row ─────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final bool showArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: colors.titleTextColor),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.titleTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16.sp, color: colors.hintTextColor),
          ],
        ),
      ),
    );
  }
}

