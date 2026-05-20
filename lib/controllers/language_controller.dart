// lib/controllers/language_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  Rx<Locale> currentLocale = Rx<Locale>(Get.locale ?? const Locale('en'));
  
  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }
  
  void loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null && languageCode.isNotEmpty) {
      updateLanguage(Locale(languageCode));
    }
  }
  
  void updateLanguage(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    debugPrint('🔄 Language updated to: ${locale.languageCode}');
  }
  
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    final locale = Locale(languageCode);
    currentLocale.value = locale;
    Get.updateLocale(locale);
    
    debugPrint('✅ Language changed to: $languageCode');
  }
  
  String getCurrentLanguageName() {
    switch (currentLocale.value.languageCode) {
      case 'en':
        return 'English';
      case 'ur':
        return 'Urdu';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }
  
  String getCurrentLanguageCode() {
    return currentLocale.value.languageCode;
  }
}