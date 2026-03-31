import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/AppColor/app_color.dart';
import '../../../core/AppText/app_text.dart';


// ─────────────────────────────────────────────────────────
//  MAIN CHAT SCREEN
//  Matches the mockup: hamburger | "Sign up" btn, sparkle
//  background, "What can I help with?" heading, bottom
//  input bar with mic + image + text field + send.
// ─────────────────────────────────────────────────────────

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();

  // Each sparkle gets its own AnimationController for independent pulsing.
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const List<_SparkleData> _sparkles = [
    // left-top area
    _SparkleData(dx: 0.07, dy: 0.18, size: 16, color: Color(0xFF8BAAD8), delay: 0),
    _SparkleData(dx: 0.73, dy: 0.15, size: 9,  color: Color(0xFF8BAAD8), delay: 180),
    // mid-left
    _SparkleData(dx: 0.16, dy: 0.35, size: 22, color: Color(0xFFFFD100), delay: 350),
    _SparkleData(dx: 0.54, dy: 0.36, size: 10, color: Color(0xFF8BAAD8), delay: 90),
    // lower left cluster
    _SparkleData(dx: 0.07, dy: 0.52, size: 26, color: Color(0xFFFFD100), delay: 550),
    _SparkleData(dx: 0.26, dy: 0.54, size: 13, color: Color(0xFF8BAAD8), delay: 270),
    _SparkleData(dx: 0.18, dy: 0.60, size: 18, color: Color(0xFFFFD100), delay: 480),
    // right mid
    _SparkleData(dx: 0.60, dy: 0.48, size: 7,  color: Color(0xFFB5C8E8), delay: 130),
    _SparkleData(dx: 0.80, dy: 0.57, size: 9,  color: Color(0xFFB5C8E8), delay: 320),
    _SparkleData(dx: 0.87, dy: 0.43, size: 11, color: Color(0xFFB5C8E8), delay: 410),
    // scattered small
    _SparkleData(dx: 0.42, dy: 0.64, size: 7,  color: Color(0xFFB5C8E8), delay: 230),
    _SparkleData(dx: 0.66, dy: 0.68, size: 6,  color: Color(0xFFB5C8E8), delay: 520),
    _SparkleData(dx: 0.50, dy: 0.24, size: 5,  color: Color(0xFFB5C8E8), delay: 660),
    _SparkleData(dx: 0.91, dy: 0.29, size: 8,  color: Color(0xFFB5C8E8), delay: 740),
    _SparkleData(dx: 0.34, dy: 0.44, size: 6,  color: Color(0xFFB5C8E8), delay: 860),
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_sparkles.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1600 + i * 130),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _sparkles[i].delay), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.instance;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(colors),
            Expanded(child: _buildBody(colors)),
            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────────────────
  Widget _buildTopBar(AppColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger (3 lines, bottom-two shorter)
          GestureDetector(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: (){
                  Drawer(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 50.h),

                          /// Menu Icon
                          Icon(Icons.menu, size: 28.sp),

                          SizedBox(height: 30.h),

                          /// New Chat Button
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),

                          /// Profile
                          Text(
                            "Profile",
                            style: TextStyle(fontSize: 16.sp),
                          ),

                          SizedBox(height: 20.h),

                          /// Terms
                          Text(
                            "Terms and privacy policy",
                            style: TextStyle(fontSize: 16.sp),
                          ),

                          SizedBox(height: 20.h),

                          Divider(),

                          SizedBox(height: 10.h),

                          /// History with dropdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "History",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),

                          const Spacer(),

                          /// Logout Button
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff2F3E5B),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "Log out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  );
                }, icon: Icon(Icons.menu))
              ],
            ),
          ),

          // Sign Up pill button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/sign-up'),
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
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double width, AppColors colors) => Container(
    width: width,
    height: 2.2.h,
    decoration: BoxDecoration(
      color: colors.titleTextColor,
      borderRadius: BorderRadius.circular(2.r),
    ),
  );

  // ── BODY (sparkles + heading) ────────────────────────────
  Widget _buildBody(AppColors colors) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          // Sparkles
          ..._buildSparkleWidgets(w, h),

          // Main heading
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

  List<Widget> _buildSparkleWidgets(double w, double h) {
    return List.generate(_sparkles.length, (i) {
      final s = _sparkles[i];
      return Positioned(
        left: s.dx * w,
        top: s.dy * h,
        child: AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Opacity(
            opacity: _animations[i].value,
            child: Transform.scale(
              scale: 0.75 + _animations[i].value * 0.25,
              child: _Sparkle(size: s.size.toDouble(), color: s.color),
            ),
          ),
        ),
      );
    });
  }

  // ── BOTTOM INPUT BAR ─────────────────────────────────────
  Widget _buildBottomBar(AppColors colors) {
    return Container(
      color: colors.mainBtnColor,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          // Mic
          _iconBtn(Icons.mic_none_rounded, () {}),
          SizedBox(width: 8.w),
          // Image
          _iconBtn(Icons.image_outlined, () {}),
          SizedBox(width: 8.w),
          // Text field
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              child: TextField(
                controller: _inputController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppStrings.serchtext,
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
          // Send
          GestureDetector(
            onTap: () {},
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 26.sp),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  4-POINT SPARKLE  (CustomPainter)
// ─────────────────────────────────────────────────────────
class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size),
    painter: _SparklePainter(color),
  );
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.22;

    // 8-point star (4 main + 4 inner)
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
  final double dx;   // fraction of width
  final double dy;   // fraction of height
  final int size;
  final Color color;
  final int delay;   // ms

  const _SparkleData({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.delay,
  });
}