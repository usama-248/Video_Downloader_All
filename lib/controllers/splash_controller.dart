

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/core/config/admob_config.dart';

class SplashController extends GetxController {
  var isAdLoaded = false.obs;
  var adShown = false.obs;
  var navigated = false.obs;
  
  AppOpenAd? _appOpenAd;
  AnimationController? animationController;
  
  @override
  void onInit() {
    super.onInit();
    loadAppOpenAd();
  }
  
  @override
  void onClose() {
    _appOpenAd?.dispose();
    animationController?.dispose();
    super.onClose();
  }
  
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdMobConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          isAdLoaded.value = true;
          debugPrint('✅ App Open Ad loaded successfully');
          
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('📱 App Open Ad showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('❌ App Open Ad dismissed');
              ad.dispose();
              isAdLoaded.value = false;
              _appOpenAd = null;
              navigateToNextScreen();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('⚠️ App Open Ad failed to show: $error');
              ad.dispose();
              isAdLoaded.value = false;
              _appOpenAd = null;
              navigateToNextScreen();
            },
          );
          
          showAppOpenAd();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ App Open Ad failed to load: $error');
          isAdLoaded.value = false;
          Future.delayed(const Duration(milliseconds: 2500), () {
            navigateToNextScreen();
          });
        },
      ),
    );
  }
  
  void showAppOpenAd() {
    if (adShown.value || navigated.value) return;
    
    if (isAdLoaded.value && _appOpenAd != null) {
      adShown.value = true;
      _appOpenAd!.show();
    }
  }
  
  void navigateToNextScreen() async {
    if (navigated.value) return;
    navigated.value = true;
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has completed onboarding
    bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    bool hasSelectedLanguage = prefs.getBool('has_selected_language') ?? false;
    bool hasSelectedInterests = prefs.getBool('has_selected_interests') ?? false;
    
    bool isNewUser = !hasSeenOnboarding || !hasSelectedLanguage || !hasSelectedInterests;
    
    if (isNewUser) {
      // NEW USER FLOW: Go to Onboarding
      Get.offAllNamed('/onboarding');
    } else {
      // RETURNING USER FLOW: Go to Premium Screen
      Get.offAllNamed('/premium');
    }
  }
  
  void startAnimations() {
    animationController?.forward();
  }
}