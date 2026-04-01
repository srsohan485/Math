import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mathsolving/features/View/SplashScreen/splash_screen2.dart';
import '../../../core/AppImages/app_images.dart';
import '../../../core/storege/storage_service.dart';
import '../MainScreen/chart_screen.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (StorageService.hasToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainChatScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen2()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            AppImages.BackgroundImage,
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.4)),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.Centerlogo2,
                height: 600.h,
                width: 400.w,
                color: Colors.white,
              ),
              SizedBox(height: 40.h),

              // Dot Indicator

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.h),
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: index == activeIndex
                          ? Colors.white  // active dot
                          : Colors.white24, // inactive dot
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              )
            ],
          ),
        ],
      ),
    );
  }
}