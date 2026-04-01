import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/api_service.dart';
import 'core/storege/storage_service.dart';
import 'features/Controller/AuthController/auth_controller.dart';
import 'features/View/MainScreen/chart_screen.dart';
import 'features/View/SplashScreen/splash_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← এটা আগে লাগবে
  await GetStorage.init();                   // ← await দিতে হবে

  Get.put(ApiServices(baseUrl: 'https://mathapi.dsrt321.online'));
  Get.put(AuthController());

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
          home: const SplashScreen(), // ← SplashScreen থেকে শুরু
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}