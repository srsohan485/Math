// lib/features/View/ChatScreen/main_chat_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mathsolving/features/View/MainScreen/profile_srceen.dart';
import 'package:mathsolving/features/View/MainScreen/termscondition_screen.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/ChatController/chat_controller.dart';
import '../../Model/ChetModel/chat_model.dart';
import '../AuthScreen/singin_screen.dart';
import '../AuthScreen/singup_srceen.dart';

class MainChatScreen extends StatelessWidget {
  const MainChatScreen({super.key});

  static const List<_SparkleData> _sparkles = [
    _SparkleData(dx: 0.07, dy: 0.18, size: 16, color: Color(0xFF8BAAD8), delay: 0),
    _SparkleData(dx: 0.73, dy: 0.15, size: 9,  color: Color(0xFF8BAAD8), delay: 180),
    _SparkleData(dx: 0.16, dy: 0.35, size: 22, color: Color(0xFFFFD100), delay: 350),
    _SparkleData(dx: 0.54, dy: 0.36, size: 10, color: Color(0xFF8BAAD8), delay: 90),
    _SparkleData(dx: 0.07, dy: 0.52, size: 26, color: Color(0xFFFFD100), delay: 550),
    _SparkleData(dx: 0.26, dy: 0.54, size: 13, color: Color(0xFF8BAAD8), delay: 270),
    _SparkleData(dx: 0.18, dy: 0.60, size: 18, color: Color(0xFFFFD100), delay: 480),
    _SparkleData(dx: 0.60, dy: 0.48, size: 7,  color: Color(0xFFB5C8E8), delay: 130),
    _SparkleData(dx: 0.80, dy: 0.57, size: 9,  color: Color(0xFFB5C8E8), delay: 320),
    _SparkleData(dx: 0.87, dy: 0.43, size: 11, color: Color(0xFFB5C8E8), delay: 410),
    _SparkleData(dx: 0.42, dy: 0.64, size: 7,  color: Color(0xFFB5C8E8), delay: 230),
    _SparkleData(dx: 0.66, dy: 0.68, size: 6,  color: Color(0xFFB5C8E8), delay: 520),
    _SparkleData(dx: 0.50, dy: 0.24, size: 5,  color: Color(0xFFB5C8E8), delay: 660),
    _SparkleData(dx: 0.91, dy: 0.29, size: 8,  color: Color(0xFFB5C8E8), delay: 740),
    _SparkleData(dx: 0.34, dy: 0.44, size: 6,  color: Color(0xFFB5C8E8), delay: 860),
  ];

  @override
  Widget build(BuildContext context) {
    final colors     = AppColors.instance;
    final controller = Get.put(ChatController());

    return Scaffold(
      backgroundColor: colors.background,
      drawer: _buildDrawer(colors, controller),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, colors),
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty &&
                    !controller.isLoading.value) {
                  return _buildEmptyBody(colors);
                }
                return _buildMessageList(colors, controller);
              }),
            ),
            _buildBottomBar(colors, controller),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  DRAWER
  // ════════════════════════════════════════════════════
  Widget _buildDrawer(AppColors colors, ChatController controller) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50.h),

          // ── Header: menu icon + New Chat ──────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.menu, size: 28.sp),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    Get.back();
                    await controller.startNewSession();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xff2F3E5B),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 15.sp),
                        SizedBox(width: 6.w),
                        Text(AppStrings.newtext,
                            style: TextStyle(
                                color: Colors.white, fontSize: 13.sp)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Profile & Terms ───────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _drawerNavBtn(
                  icon: Icons.person_outline,
                  label: AppStrings.profile,
                  onTap: () => Get.to(() => ProfileScreen()),
                ),
                _drawerNavBtn(
                  icon: Icons.description_outlined,
                  label: AppStrings.termsconditiontext,
                  onTap: () => Get.to(() => TermsAndPrivacyScreen()),
                ),
              ],
            ),
          ),

          Divider(height: 1.h),
          SizedBox(height: 6.h),

          // ── History label + refresh ───────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              children: [
                Text(
                  AppStrings.history,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoadingSessions.value
                    ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff2F3E5B)),
                )
                    : GestureDetector(
                  onTap: controller.loadSessions,
                  child: Icon(Icons.refresh,
                      size: 20.sp, color: Colors.black38),
                )),
              ],
            ),
          ),

          // ── Session list ──────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingSessions.value &&
                  controller.sessions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xff2F3E5B)),
                );
              }
              if (controller.sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 34.sp, color: Colors.black26),
                      SizedBox(height: 8.h),
                      Text(AppStrings.nochats,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black38)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                itemCount: controller.sessions.length,
                itemBuilder: (ctx, i) {
                  final session = controller.sessions[i];
                  return Obx(() {
                    final isActive =
                        controller.sessionId.value == session.id;
                    return _SessionTile(
                      session: session,
                      isActive: isActive,
                      onTap: () async {
                        Get.back();
                        await controller.loadSession(session.id);
                      },
                      onRename: () =>
                          _showRenameDialog(ctx, controller, session),
                      onDelete: () =>
                          _showDeleteDialog(ctx, controller, session.id),
                    );
                  });
                },
              );
            }),
          ),

          Divider(height: 1.h),
          SizedBox(height: 10.h),

          // ── Logout ────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Obx(() {
              final isOut = controller.isLoggingOut.value;
              return GestureDetector(
                onTap: isOut
                    ? null
                    : () async {
                  // ✅ confirm dialog
                  final confirm = await showDialog<bool>(
                    context: Get.context!,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Logout?"),
                      content: const Text("Are you sure you want to log out of your account?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2F3E5B),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Get.offAll(() => SignInScreen());
                  }
                  if (confirm == true) {
                    Get.back(); // drawer বন্ধ করো
                    await controller.logout(); // ✅ API call
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isOut
                        ? const Color(0xff2F3E5B).withOpacity(0.5)
                        : const Color(0xff2F3E5B),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: isOut
                      ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout,
                          color: Colors.white, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        AppStrings.Logout,
                        style: TextStyle(
                            color: Colors.white, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // ── Rename dialog ─────────────────────────────────
  void _showRenameDialog(
      BuildContext context, ChatController controller, ChatSession session) {
    final tc = TextEditingController(text: session.title ?? "");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Chat"),
        content: TextField(
          controller: tc,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Chat এর নাম লিখুন...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2F3E5B)),
            onPressed: () async {
              final name = tc.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await controller.renameSession(session.id, name);
            },
            child: const Text("Save",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete confirm dialog ─────────────────────────
  void _showDeleteDialog(
      BuildContext context, ChatController controller, int sessionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Chat?"),
        content: const Text("এই chat টি permanently delete হয়ে যাবে।"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteSession(sessionId);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _drawerNavBtn(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp, color: Colors.black87),
      label: Text(label,
          style:
          TextStyle(fontSize: 15.sp, color: Colors.black87)),
    );
  }

  // ════════════════════════════════════════════════════
  //  TOP BAR
  // ════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context, AppColors colors) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: Icon(Icons.menu, size: 26.sp),
              padding: EdgeInsets.zero,
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const SignUpScreen()),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 22.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: colors.mainBtnColor,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Text(
                AppStrings.signup,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.btnTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  EMPTY BODY (sparkles)
  // ════════════════════════════════════════════════════
  Widget _buildEmptyBody(AppColors colors) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Stack(
        children: [
          ..._sparkles.map((s) => Positioned(
            left: s.dx * w,
            top: s.dy * h,
            child: _AnimatedSparkle(data: s),
          )),
          Positioned(
            top: 70.h,
            left: 24.w,
            right: 60.w,
            child: Text(
              AppStrings.maintext,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: colors.titleTextColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      );
    });
  }

  // ════════════════════════════════════════════════════
  //  MESSAGE LIST
  // ════════════════════════════════════════════════════
  Widget _buildMessageList(AppColors colors, ChatController controller) {
    return Obx(() {
      final itemCount = controller.messages.length +
          (controller.isLoading.value ? 1 : 0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.scrollController.hasClients) {
          controller.scrollController.animateTo(
            controller.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      return ListView.builder(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: 16.w, vertical: 12.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (controller.isLoading.value &&
              index == controller.messages.length) {
            return _buildTypingIndicator(colors);
          }
          final msg = controller.messages[index];
          return msg.isUser
              ? _buildUserBubble(msg, colors)
              : _buildAiBubble(msg, colors);
        },
      );
    });
  }

  // ── User bubble ───────────────────────────────────
  Widget _buildUserBubble(ChatMessage msg, AppColors colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 60.w),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: colors.mainBtnColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(4.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🖼️ IMAGE
              if (msg.image != null && msg.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    msg.image!.startsWith('http')
                        ? msg.image!
                        : "https://mathapi.dsrt321.online${msg.image!}",
                    width: 200.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: 200.w,
                        height: 120.h,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ),

              if (msg.image != null && msg.message.isNotEmpty)
                SizedBox(height: 6.h),

              // 🎤 AUDIO (IMPROVED)
              if (msg.audio != null && msg.audio!.isNotEmpty)
                Obx(() {
                  final ctrl = Get.find<ChatController>();
                  final isPlaying = ctrl.playingAudioId.value == msg.id;

                  return GestureDetector(
                    onTap: () async {
                      await ctrl.playAudio(msg.id, msg.audio!);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          SizedBox(width: 8.w),

                          // 🔊 Text + fake duration style
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPlaying ? "Playing..." : "Voice Message",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                isPlaying ? "Tap to stop" : "Tap to play",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              if (msg.audio != null && msg.message.isNotEmpty)
                SizedBox(height: 6.h),

              // 💬 TEXT
              if (msg.message.isNotEmpty)
                Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.btnTextColor,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AI bubble ─────────────────────────────────────
  Widget _buildAiBubble(ChatMessage msg, AppColors colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 60.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            margin: EdgeInsets.only(right: 8.w, top: 2.h),
            decoration: BoxDecoration(
                color: colors.mainBtnColor,
                shape: BoxShape.circle),
            child: Icon(Icons.auto_awesome,
                color: Colors.white, size: 16.sp),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colors.softMintBackground,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.only(
                  topLeft:     Radius.circular(4.r),
                  topRight:    Radius.circular(16.r),
                  bottomLeft:  Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Text(
                _cleanLatex(msg.message),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.titleTextColor,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Typing indicator ──────────────────────────────
  Widget _buildTypingIndicator(AppColors colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 60.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            margin: EdgeInsets.only(right: 8.w, top: 2.h),
            decoration: BoxDecoration(
                color: colors.mainBtnColor,
                shape: BoxShape.circle),
            child: Icon(Icons.auto_awesome,
                color: Colors.white, size: 16.sp),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: colors.softMintBackground,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ════════════════════════════════════════════════════
  Widget _buildBottomBar(AppColors colors, ChatController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image preview
        GetBuilder<ChatController>(
          builder: (ctrl) {
            if (ctrl.selectedImage == null) {
              return const SizedBox.shrink();
            }
            return Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 6.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(ctrl.selectedImage!,
                        height: 50.h,
                        width: 50.w,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(width: 8.w),
                  Text("Image ready",
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ctrl.selectedImage = null;
                      ctrl.update();
                    },
                    child:
                    const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),

        // Input bar
        Container(
          color: colors.mainBtnColor,
          padding: EdgeInsets.symmetric(
              horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Obx(() => GestureDetector(
                onTap: () => controller.toggleRecording(),
                child: Icon(
                  controller.isRecording.value
                      ? Icons.stop_circle
                      : Icons.mic_none_rounded,
                  color: controller.isRecording.value
                      ? Colors.red
                      : Colors.white,
                  size: 26.sp,
                ),
              )),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Icon(Icons.image_outlined,
                    color: Colors.white, size: 26.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.20)),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller.inputController,
                    style: TextStyle(
                        color: Colors.white, fontSize: 14.sp),
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Image সম্পর্কে প্রশ্ন করুন...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() => GestureDetector(
                onTap: controller.isLoading.value
                    ? null
                    : controller.sendMessage,
                child: controller.isLoading.value
                    ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Transform.rotate(
                  angle: -0.3,
                  child: Icon(Icons.send_rounded,
                      color: Colors.white,
                      size: 24.sp),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _cleanLatex(String raw) {
    return raw
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\\', '')
        .replaceAll(r'\frac', '')
        .replaceAll(r'\sqrt', '√')
        .replaceAll(r'\boxed', '')
        .replaceAll(r'\Delta', 'Δ')
        .replaceAll(r'\$', '')
        .replaceAll(r'$$', '')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '');
  }
}

// ══════════════════════════════════════════════════════════
//  SESSION TILE  (swipe to delete + long-press to rename)
// ══════════════════════════════════════════════════════════
class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("session_${session.id}"),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        margin: EdgeInsets.only(bottom: 4.h),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.delete_outline,
            color: Colors.white, size: 22.sp),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // controller handles removal
      },
      child: GestureDetector(
        onLongPress: onRename,
        child: Container(
          margin: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xff2F3E5B).withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w, vertical: 2.h),
            leading: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xff2F3E5B)
                    : const Color(0xff2F3E5B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15.sp,
                color: isActive
                    ? Colors.white
                    : const Color(0xff2F3E5B),
              ),
            ),
            title: Text(
              session.title ?? "Chat #${session.id}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive
                    ? const Color(0xff2F3E5B)
                    : Colors.black87,
              ),
            ),
            subtitle: Text(
              _formatDate(session.createdAt),
              style: TextStyle(
                  fontSize: 11.sp, color: Colors.black38),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  size: 18.sp, color: Colors.black38),
              onSelected: (val) {
                if (val == 'rename') onRename();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16.sp, color: Colors.black54),
                      SizedBox(width: 8.w),
                      const Text("Rename"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 16.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text("Delete",
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt  = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day) return "Today";
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${months[dt.month]} ${dt.day}";
    } catch (_) {
      return "";
    }
  }
}

// ══════════════════════════════════════════════════════════
//  ANIMATED SPARKLE
// ══════════════════════════════════════════════════════════
class _AnimatedSparkle extends StatefulWidget {
  final _SparkleData data;
  const _AnimatedSparkle({required this.data});
  @override
  State<_AnimatedSparkle> createState() => _AnimatedSparkleState();
}

class _AnimatedSparkleState extends State<_AnimatedSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration:
      Duration(milliseconds: 1600 + widget.data.delay ~/ 2),
    );
    _anim = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.data.delay),
            () {
          if (mounted) _ctrl.repeat(reverse: true);
        });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Transform.scale(
          scale: 0.75 + _anim.value * 0.25,
          child: _Sparkle(
              size: widget.data.size.toDouble(),
              color: widget.data.color),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TYPING DOTS
// ══════════════════════════════════════════════════════════
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (t - i * 0.25).clamp(0.0, 1.0);
            final opacity =
            (math.sin(phase * math.pi)).clamp(0.3, 1.0);
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8BAAD8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  SPARKLE PAINTER
// ══════════════════════════════════════════════════════════
class _Sparkle extends StatelessWidget {
  final double size;
  final Color  color;
  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _SparklePainter(color));
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx    = size.width  / 2;
    final cy    = size.height / 2;
    final outer = size.width  / 2;
    final inner = outer * 0.22;
    final path  = Path();
    for (int i = 0; i < 8; i++) {
      final angle =
          (i * 45.0 - 90.0) * math.pi / 180.0;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) =>
      old.color != color;
}

// ══════════════════════════════════════════════════════════
//  DATA CLASS
// ══════════════════════════════════════════════════════════
class _SparkleData {
  final double dx, dy;
  final int    size, delay;
  final Color  color;
  const _SparkleData(
      {required this.dx,
        required this.dy,
        required this.size,
        required this.color,
        required this.delay});
}