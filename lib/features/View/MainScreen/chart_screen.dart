// lib/features/View/ChatScreen/main_chat_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/AppText/app_text.dart';
import '../../Controller/ChatController/chat_controller.dart';
import '../../Model/ChetModel/chat_model.dart';
import '../AuthScreen/singup_srceen.dart';

class MainChatScreen extends StatelessWidget {
  const MainChatScreen({super.key});

  // ── Sparkle data ─────────────────────────────────────
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
                // Show sparkle home screen when no messages yet
                if (controller.messages.isEmpty && !controller.isLoading.value) {
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

  // ── DRAWER ───────────────────────────────────────────
  Widget _buildDrawer(AppColors colors, ChatController controller) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.h),
            Icon(Icons.menu, size: 28.sp),
            SizedBox(height: 30.h),
            // New Chat
            GestureDetector(
              onTap: () {
                Get.back(); // close drawer
                controller.messages.clear();
                controller.onInit(); // create fresh session
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xff2F3E5B),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "New chat",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Text("Profile",               style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 20.h),
            Text("Terms and privacy policy", style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("History", style: TextStyle(fontSize: 16.sp)),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xff2F3E5B),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "Log out",
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, AppColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
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
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 9.h),
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

  // ── EMPTY / HOME BODY (sparkles + heading) ───────────
  Widget _buildEmptyBody(AppColors colors) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          ..._sparkles.map((s) => Positioned(
            left: s.dx * w,
            top:  s.dy * h,
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

  // ── MESSAGE LIST ─────────────────────────────────────
  Widget _buildMessageList(AppColors colors, ChatController controller) {
    return Obx(() {
      // messages বা isLoading যখনই change হবে, scroll হবে
      final itemCount = controller.messages.length +
          (controller.isLoading.value ? 1 : 0);

      // Build শেষে auto-scroll
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  // ── USER BUBBLE ──────────────────────────────────────
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
              topLeft:     Radius.circular(16.r),
              topRight:    Radius.circular(16.r),
              bottomLeft:  Radius.circular(16.r),
              bottomRight: Radius.circular(4.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Image ───────────────────────────────
              if (msg.image != null && msg.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    msg.image!.startsWith('http')
                        ? msg.image!
                        : "https://mathapi.dsrt321.online${msg.image!}",
                    width: 200.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 200.w,
                        height: 120.h,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ),

              if (msg.image != null && msg.message.isNotEmpty)
                SizedBox(height: 6.h),

              // ─── Audio Player Button ──────────────────
              if (msg.audio != null && msg.audio!.isNotEmpty)
                Obx(() {
                  final controller = Get.find<ChatController>();
                  final isPlaying  = controller.playingAudioId.value == msg.id;
                  return GestureDetector(
                    onTap: () => controller.playAudio(msg.id, msg.audio!),
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
                          SizedBox(width: 6.w),
                          Text(
                            isPlaying ? "Playing..." : "Voice Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              if (msg.audio != null && msg.message.isNotEmpty)
                SizedBox(height: 6.h),

              // ─── Text ────────────────────────────────
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

  // ── AI BUBBLE ────────────────────────────────────────
  Widget _buildAiBubble(ChatMessage msg, AppColors colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 60.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Container(
            width: 32.w,
            height: 32.w,
            margin: EdgeInsets.only(right: 8.w, top: 2.h),
            decoration: BoxDecoration(
              color: colors.mainBtnColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                // Clean up LaTeX markers for plain-text display.
                // If you add flutter_math_fork later, replace this
                // with a proper LaTeX renderer.
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

  // ── TYPING INDICATOR ─────────────────────────────────
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
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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

  // ── BOTTOM BAR ───────────────────────────────────────
  Widget _buildBottomBar(AppColors colors, ChatController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image selected indicator
        GetBuilder<ChatController>(
          builder: (ctrl) {
            if (ctrl.selectedImage == null) return const SizedBox.shrink();
            return Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      ctrl.selectedImage!,
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Image ready — Tapy Here",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  const Spacer(),
                  // Image remove button
                  GestureDetector(
                    onTap: () {
                      ctrl.selectedImage = null;
                      ctrl.update();
                    },
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),

        // আপনার existing bottom bar
        Container(
          color: colors.mainBtnColor,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Obx(() => GestureDetector(
                onTap: () => controller.toggleRecording(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    controller.isRecording.value
                        ? Icons.stop_circle  // চলছে → stop
                        : Icons.mic_none_rounded, // idle → mic
                    color: controller.isRecording.value
                        ? Colors.red
                        : Colors.white,
                    size: 26.sp,
                  ),
                ),
              )),
              SizedBox(width: 8.w),
              _iconBtn(Icons.image_outlined, () => controller.pickImage()),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.20)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller.inputController,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
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
                onTap: controller.isLoading.value ? null : controller.sendMessage,
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
                      color: Colors.white, size: 24.sp),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: Colors.white, size: 26.sp),
  );

  /// Very light LaTeX cleanup — replaces common markers with readable text.
  /// Replace with flutter_math_fork for full rendering.
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

// ─────────────────────────────────────────────────────────
//  ANIMATED SPARKLE  (StatefulWidget — kept small & local)
// ─────────────────────────────────────────────────────────
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
      duration: Duration(milliseconds: 1600 + widget.data.delay ~/ 2),
    );
    _anim = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.data.delay), () {
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
            size:  widget.data.size.toDouble(),
            color: widget.data.color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TYPING DOTS  (animated "..." indicator)
// ─────────────────────────────────────────────────────────
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
            final opacity = (math.sin(phase * math.pi)).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
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

// ─────────────────────────────────────────────────────────
//  4-POINT SPARKLE  (CustomPainter — unchanged)
// ─────────────────────────────────────────────────────────
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

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angleDeg = i * 45.0 - 90.0;
      final angleRad = angleDeg * math.pi / 180.0;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angleRad);
      final y = cy + r * math.sin(angleRad);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────
//  DATA CLASS
// ─────────────────────────────────────────────────────────
class _SparkleData {
  final double dx;
  final double dy;
  final int    size;
  final Color  color;
  final int    delay;

  const _SparkleData({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.delay,
  });
}