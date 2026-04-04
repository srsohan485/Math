import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/AppText/app_translate.dart';
import 'core/services/api_service.dart';
import 'core/storege/storage_service.dart';
import 'features/Controller/AuthController/auth_controller.dart';
import 'features/Controller/LanguageController/language_controller.dart';
import 'features/View/SplashScreen/splash_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  Get.put(ApiServices(baseUrl: 'https://mathapi.dsrt321.online'));
  Get.put(AuthController());

  // Register LanguageController early so the saved locale is ready
  final langController = Get.put(LanguageController());

  runApp(MyApp(initialLocale: langController.currentLanguage.value));
}

class MyApp extends StatelessWidget {
  final String initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,

          // ── Localization ──────────────────────────────────
          translations: AppTranslations(),
          locale: initialLocale == 'bg'
              ? const Locale('bg', 'BG')
              : const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          // ─────────────────────────────────────────────────

          home: const SplashScreen(),
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}