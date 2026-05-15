



import 'dart:io';
import 'package:facebook_video_downloader/firebase_options.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:facebook_video_downloader/core/routes/app_pages.dart';
import 'package:facebook_video_downloader/core/bindings/initial_binding.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

// Firebase Analytics instance
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // Initialize Mobile Ads
  try {
    await MobileAds.instance.initialize();
    debugPrint('✅ Mobile Ads initialized successfully');
  } catch (e) {
    debugPrint('❌ Mobile Ads initialization error: $e');
  }

  // Load .env file
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded successfully');
  } catch (e) {
    debugPrint('⚠️ .env file not found or failed to load');
  }

  // Android media scan
  if (Platform.isAndroid) {
    _scanDownloadedVideos();
  }

  // Run app with GetX
  runApp(const MyApp());
}

Future<void> _scanDownloadedVideos() async {
  try {
    await Process.run('am', [
      'broadcast',
      '-a',
      'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
      '-d',
      'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
    ]);
    debugPrint('✅ Media scanner triggered');
  } catch (e) {
    debugPrint('❌ Media scan error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video Downloader',
      debugShowCheckedModeBanner: false,
      
      // Routing
      initialRoute: '/splash',
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      
      // Localization
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ur'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Theme
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      
      // Firebase Analytics
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}