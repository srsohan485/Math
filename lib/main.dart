import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'features/View/AuthScreen/email_varification.dart';
import 'features/View/AuthScreen/enterotp_screen.dart';
import 'features/View/AuthScreen/forgot_password.dart';
import 'features/View/AuthScreen/reset_password.dart';
import 'features/View/AuthScreen/singin_screen.dart';
import 'features/View/AuthScreen/singup_srceen.dart';
import 'features/View/Languagepage/language_screen.dart';
import 'features/View/MainScreen/chart_screen.dart';
import 'features/View/SplashScreen/splash_screen1.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,



          home: const MainChatScreen(),


          defaultTransition: Transition.fade,
        );
      },
    );
  }
}