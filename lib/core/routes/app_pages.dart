import 'package:get/get.dart';
import 'package:facebook_video_downloader/features/splash/spalshscreen.dart';
import 'package:facebook_video_downloader/features/onboarding/screens/onboarding_screen.dart';
import 'package:facebook_video_downloader/features/languageselect/languageSelectorScreen.dart';
import 'package:facebook_video_downloader/features/interest/interestscreen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/home/home_screen.dart';
import 'package:facebook_video_downloader/features/webview/webview_screen.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart';

import 'package:facebook_video_downloader/controllers/splash_controller.dart';
import 'package:facebook_video_downloader/controllers/onboarding_controller.dart';
import 'package:facebook_video_downloader/controllers/language_controller.dart';
import 'package:facebook_video_downloader/controllers/interest_controller.dart';
import 'package:facebook_video_downloader/controllers/home_controller.dart';
import 'package:facebook_video_downloader/controllers/premium_controller.dart';
import 'package:facebook_video_downloader/controllers/webview_controller.dart';
import 'package:facebook_video_downloader/controllers/history_controller.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.languageSelect,
      page: () => const LanguageSelectorScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LanguageController>(() => LanguageController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.interest,
      page: () => const InterestScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InterestController>(() => InterestController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PremiumController>(() => PremiumController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.webview,
      page: () {
        final String url = Get.arguments?['url'] ?? 'https://facebook.com';
        return WebViewScreen(url: url);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut<WebViewControllerr>(() => WebViewControllerr(url: ''));
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HistoryController>(() => HistoryController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
