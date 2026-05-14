
import 'dart:io';

import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/navigation/onboarding_director.dart';
import 'package:facebook_video_downloader/features/providers/language_provider.dart';
import 'package:facebook_video_downloader/features/splash/spalshscreen.dart';
import 'package:facebook_video_downloader/firebase_options.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase Analytics instance
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  // STEP 1: Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 2: Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // STEP 3: Initialize Mobile Ads
  try {
    await MobileAds.instance.initialize();
    debugPrint('✅ Mobile Ads initialized successfully');
  } catch (e) {
    debugPrint('❌ Mobile Ads initialization error: $e');
  }

  // STEP 4: Load .env file
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded successfully');
  } catch (e) {
    debugPrint('⚠️ .env file not found or failed to load');
  }

  // STEP 5: Optional media scan (Android only)
  if (Platform.isAndroid) {
    _scanDownloadedVideos();
  }

  // STEP 6: Run app
  runApp(const MyApp());
}

// Android media scanner
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadController()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Video Downloader',

            debugShowCheckedModeBanner: false,

            // Localization
            locale: languageProvider.locale,

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

            // Firebase Analytics observer
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],

            // Initial screen
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      bool hasSeenOnboarding =
          prefs.getBool(OnboardingDirector.KEY_ONBOARDING) ?? false;

      bool hasSelectedLanguage =
          prefs.getBool(OnboardingDirector.KEY_LANGUAGE) ?? false;

      bool hasSelectedInterests =
          prefs.getBool(OnboardingDirector.KEY_INTERESTS) ?? false;

      // Detect first-time user
      bool isFirstLaunch =
          !hasSeenOnboarding && !hasSelectedLanguage && !hasSelectedInterests;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(isReturningUser: !isFirstLaunch),
        ),
      );
    } catch (e) {
      debugPrint('❌ App initialization error: $e');

      // Fallback navigation
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SplashScreen(isReturningUser: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
