import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/features/onboarding/screens/onboarding_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/languageselect/languageSelectorScreen.dart';
import 'package:facebook_video_downloader/features/interest/interestscreen.dart';
import 'package:facebook_video_downloader/features/home/home_screen.dart';

class OnboardingDirector {
  static const String KEY_ONBOARDING = 'has_seen_onboarding';
  static const String KEY_PREMIUM = 'has_seen_premium';
  static const String KEY_LANGUAGE = 'has_selected_language';
  static const String KEY_INTERESTS = 'has_selected_interests';
  static const String KEY_IS_PREMIUM_USER = 'is_premium_user';

  // For first launch: Get the correct screen sequence
  static Future<Widget> getNextScreenAfterSplash(Widget currentScreen) async {
    final prefs = await SharedPreferences.getInstance();
    
    bool hasSeenOnboarding = prefs.getBool(KEY_ONBOARDING) ?? false;
    bool hasSelectedLanguage = prefs.getBool(KEY_LANGUAGE) ?? false;
    bool hasSelectedInterests = prefs.getBool(KEY_INTERESTS) ?? false;
    
    // Determine which screen comes next
    if (currentScreen is OnboardingScreen && !hasSeenOnboarding) {
      await prefs.setBool(KEY_ONBOARDING, true);
      return const LanguageSelectorScreen();
    }
    
    if (currentScreen is LanguageSelectorScreen && !hasSelectedLanguage) {
      await prefs.setBool(KEY_LANGUAGE, true);
      return const InterestScreen();
    }
    
    if (currentScreen is InterestScreen && !hasSelectedInterests) {
      await prefs.setBool(KEY_INTERESTS, true);
      return const PremiumScreen();
    }
    
    if (currentScreen is PremiumScreen) {
      await prefs.setBool(KEY_PREMIUM, true);
      return const HomeScreen();
    }
    
    // Default fallback
    return const HomeScreen();
  }
  
  // Check if this is first launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(KEY_ONBOARDING) ?? false) &&
           !(prefs.getBool(KEY_LANGUAGE) ?? false) &&
           !(prefs.getBool(KEY_INTERESTS) ?? false);
  }
}