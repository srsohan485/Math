import 'dart:ui';

import 'package:get/get.dart';
import '../../../core/storege/storage_service.dart';

class LanguageController extends GetxController {
  final RxString currentLanguage = 'en'.obs;

  // Map display name → locale code
  static const Map<String, String> languageMap = {
    'English'   : 'en',
    'Bulgarian' : 'bg',
  };

  // Reverse map: locale code → display name
  static const Map<String, String> localeToName = {
    'en': 'English',
    'bg': 'Bulgarian',
  };

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  void loadLanguage() {
    currentLanguage.value = StorageService.language; // 'en' or 'bg'
    _applyLocale(currentLanguage.value);
  }

  /// Called with display name e.g. 'English' or 'Bulgarian'
  Future<void> changeLanguageByName(String displayName) async {
    final code = languageMap[displayName] ?? 'en';
    await changeLanguage(code);
  }

  /// Called with locale code e.g. 'en' or 'bg'
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    await StorageService.saveLanguage(languageCode);
    _applyLocale(languageCode);
    update();
  }

  void _applyLocale(String code) {
    final locale = code == 'bg' ? const Locale('bg', 'BG') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  bool get isEnglish   => currentLanguage.value == 'en';
  bool get isBulgarian => currentLanguage.value == 'bg';

  /// Returns display name for current language
  String get currentDisplayName =>
      localeToName[currentLanguage.value] ?? 'English';
}