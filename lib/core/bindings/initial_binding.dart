// import 'package:facebook_video_downloader/core/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:facebook_video_downloader/controllers/language_controller.dart';
// import 'package:facebook_video_downloader/controllers/download_controller.dart';

// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Register all controllers and services here
//     Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
//     Get.lazyPut<DownloadController>(() => DownloadController(), fenix: true);
//     Get.lazyPut<DatabaseHelper>(() => DatabaseHelper(), fenix: true);
    
//     debugPrint('✅ InitialBinding: All dependencies registered');
//   }
// }



import 'package:facebook_video_downloader/core/database_helper.dart';
import 'package:facebook_video_downloader/core/services/language_service.dart';
import 'package:facebook_video_downloader/core/services/ad_service.dart';
import 'package:facebook_video_downloader/controllers/home_controller.dart';
import 'package:facebook_video_downloader/controllers/language_controller.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/controllers/history_controller.dart';
import 'package:facebook_video_downloader/controllers/premium_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('🔄 InitialBinding: Registering dependencies...');
    
    // ==================== SERVICES ====================
    // Core Services (permanent)
    Get.lazyPut<LanguageService>(() => LanguageService(), fenix: true);
    Get.lazyPut<AdService>(() => AdService(), fenix: true);
    
    // Database
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper(), fenix: true);
    
    // ==================== CONTROLLERS ====================
    // Home Controller (permanent - survives navigation)
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    
    // Download Controller
    Get.lazyPut<DownloadController>(() => DownloadController(), fenix: true);
    
    // History Controller
    Get.lazyPut<HistoryController>(() => HistoryController(), fenix: true);
    
    
    // Premium Controller
    Get.lazyPut<PremiumController>(() => PremiumController(), fenix: true);
    
    // Language Controller
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    
    // WebView Controller
    Get.lazyPut<WebViewController>(() => WebViewController(), fenix: true);
    
    debugPrint('✅ InitialBinding: All dependencies registered successfully');
    debugPrint('   📦 Services: LanguageService, AdService, DatabaseHelper');
    debugPrint('   🎮 Controllers: Home, Download, History, Settings, Premium, Language, WebView');
  }
}