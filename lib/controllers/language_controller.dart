import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String KEY_LANGUAGE = 'selected_language';
  
  var currentLocale = const Locale('en').obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }
  
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(KEY_LANGUAGE);
    
    if (languageCode != null && languageCode.isNotEmpty) {
      currentLocale.value = Locale(languageCode);
      Get.updateLocale(Locale(languageCode));
    }
  }
  
  Future<void> changeLanguage(String languageCode) async {
    currentLocale.value = Locale(languageCode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LANGUAGE, languageCode);
    
    // Update app language
    Get.updateLocale(Locale(languageCode));
  }
  
  String getCurrentLanguageName() {
    switch(currentLocale.value.languageCode) {
      case 'ur':
        return 'Urdu';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }
}