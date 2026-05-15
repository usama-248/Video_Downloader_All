import 'package:facebook_video_downloader/core/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facebook_video_downloader/controllers/language_controller.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register all controllers and services here
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<DownloadController>(() => DownloadController(), fenix: true);
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper(), fenix: true);
    
    debugPrint('✅ InitialBinding: All dependencies registered');
  }
}