import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:facebook_video_downloader/features/languageselect/languageSelectorScreen.dart';

class OnboardingPageData {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingController extends GetxController {
  // Observable variables
  var currentPage = 0.obs;
  var isLastPage = false.obs;
  
  // Non-observable
  late PageController pageController;
  late List<OnboardingPageData> onboardingData;
  
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _initializeOnboardingData();
  }
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
  void _initializeOnboardingData() {
    // Initialize with empty data, will be updated when localization is ready
    onboardingData = [
      OnboardingPageData(
        imagePath: 'assets/images/onboarding1.png',
        title: '',
        description: '',
      ),
      OnboardingPageData(
        imagePath: 'assets/images/onboarding2.png',
        title: '',
        description: '',
      ),
      OnboardingPageData(
        imagePath: 'assets/images/onboarding3.png',
        title: '',
        description: '',
      ),
    ];
  }
  
  void updateLocalizedStrings(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      onboardingData = [
        OnboardingPageData(
          imagePath: 'assets/images/onboarding1.png',
          title: localizations.onboarding_title_1,
          description: localizations.onboarding_desc_1,
        ),
        OnboardingPageData(
          imagePath: 'assets/images/onboarding2.png',
          title: localizations.onboarding_title_2,
          description: localizations.onboarding_desc_2,
        ),
        OnboardingPageData(
          imagePath: 'assets/images/onboarding3.png',
          title: localizations.onboarding_title_3,
          description: localizations.onboarding_desc_3,
        ),
      ];
      update(); // Notify listeners
    }
  }
  
  void onPageChanged(int index) {
    currentPage.value = index;
    isLastPage.value = index == onboardingData.length - 1;
  }
  
  void nextPage() {
    if (isLastPage.value) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    // OPTION 2: With custom transition
    Get.offAll(
      () => const LanguageSelectorScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
  
  void skipOnboarding() {
    completeOnboarding();
  }
  
  // Helper methods for building UI
  List<OnboardingPageData> get onboardingPages => onboardingData;
  
  int get totalPages => onboardingData.length;
}