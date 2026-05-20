// lib/core/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxService {
  static const String LANGUAGE_CODE_KEY = 'language_code';
  
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;
  
  Future<LanguageService> init() async {
    await loadLanguage();
    return this;
  }
  
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(LANGUAGE_CODE_KEY);
    
    if (languageCode != null && languageCode.isNotEmpty) {
      _currentLocale = Locale(languageCode);
      debugPrint('✅ Language loaded: $languageCode');
    } else {
      // Use device locale as default
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null && 
          (deviceLocale.languageCode == 'en' || 
           deviceLocale.languageCode == 'ur' || 
           deviceLocale.languageCode == 'ar')) {
        _currentLocale = Locale(deviceLocale.languageCode);
      } else {
        _currentLocale = const Locale('en');
      }
      debugPrint('✅ Using device language: ${_currentLocale.languageCode}');
    }
    
    // Update GetX locale
    Get.updateLocale(_currentLocale);
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE_KEY, languageCode);
    
    _currentLocale = Locale(languageCode);
    Get.updateLocale(_currentLocale);
    
    debugPrint('✅ Language changed to: $languageCode');
  }
  
  String getCurrentLanguage() {
    return _currentLocale.languageCode;
  }
  
  bool isLanguageSelected(String languageCode) {
    return _currentLocale.languageCode == languageCode;
  }
}