

import 'dart:io';

import 'package:facebook_video_downloader/firebase_options.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:facebook_video_downloader/core/routes/app_pages.dart';
import 'package:facebook_video_downloader/core/bindings/initial_binding.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart'; // Add this import
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:facebook_video_downloader/core/services/mobile_ads_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAnalytics? analytics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 1. Load .env FIRST
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded successfully');
  } catch (e) {
    debugPrint('⚠️ .env load failed: $e');
  }

  /// 2. Firebase init
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    analytics = FirebaseAnalytics.instance;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  /// 3. Mobile Ads + mediation adapters (Meta, Liftoff, Mintegral)
  try {
    await MobileAdsService.initialize();
    debugPrint('✅ Mobile Ads & mediation initialized successfully');
  } catch (e) {
    debugPrint('❌ Mobile Ads initialization error: $e');
  }

  /// 4. Android media scan (improved version)
  if (Platform.isAndroid) {
    _scanDownloadedVideos();
  }

  /// 5. Load saved language preference
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language_code');
  Locale initialLocale;

  if (savedLanguage != null && savedLanguage.isNotEmpty) {
    initialLocale = Locale(savedLanguage);
    debugPrint('✅ Loaded saved language: $savedLanguage');
  } else {
    // Use device locale if supported, otherwise English
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null &&
        (deviceLocale.languageCode == 'en' ||
            deviceLocale.languageCode == 'ur' ||
            deviceLocale.languageCode == 'ar')) {
      initialLocale = Locale(deviceLocale.languageCode);
      debugPrint('✅ Using device language: ${deviceLocale.languageCode}');
    } else {
      initialLocale = const Locale('en');
      debugPrint('✅ Using default language: en');
    }
  }

  runApp(MyApp(initialLocale: initialLocale));
}

/// Improved Media scanner for Android
Future<void> _scanDownloadedVideos() async {
  // Check if directory exists first
  final directory = Directory(
    '/storage/emulated/0/Pictures/VideoDownloaderApp',
  );

  if (await directory.exists()) {
    try {
      // Method 1: Media scanner broadcast
      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
      ]);
      debugPrint('✅ Media scanner triggered');
    } catch (e) {
      debugPrint('❌ Media scan error (method 1): $e');

      // Method 2: Alternative method using file list
      try {
        final files = await directory.list().toList();
        for (var file in files) {
          if (file.path.endsWith('.mp4') || file.path.endsWith('.mp3')) {
            await Process.run('am', [
              'broadcast',
              '-a',
              'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
              '-d',
              'file://${file.path}',
            ]);
          }
        }
        debugPrint('✅ Media scanner triggered for individual files');
      } catch (e2) {
        debugPrint('❌ Media scan error (method 2): $e2');
      }
    }
  } else {
    debugPrint('⚠️ Video downloader directory does not exist yet');
  }
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Downloader',
      debugShowCheckedModeBanner: false,

      /// Localization - Use initialLocale directly
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ur'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// Routing
      initialRoute: '/splash',
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      /// Theme
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Roboto',
      ),

      navigatorObservers: [
        if (analytics != null)
          FirebaseAnalyticsObserver(
            analytics: analytics!,
          ), // Now this works with the import
      ],
    );
  }
}
