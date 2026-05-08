import 'dart:io';
import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/navigation/onboarding_director.dart';
import 'package:facebook_video_downloader/features/providers/language_provider.dart';
import 'package:facebook_video_downloader/features/splash/spalshscreen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep app running with fallback defaults when .env is missing.
  }

  // REMOVED the auto-clear for production
  // Only uncomment for testing
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.clear();

  // Scan videos when app opens
  if (Platform.isAndroid) {
    await Future.delayed(const Duration(seconds: 1));
    await Process.run('am', [
      'broadcast',
      '-a',
      'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
      '-d',
      'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
    ]);
  }

  runApp(const MyApp());
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
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ur'), Locale('ar')],
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

// Widget to handle initial navigation decision
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
    // Check if this is first launch or returning user
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding =
        prefs.getBool(OnboardingDirector.KEY_ONBOARDING) ?? false;
    bool hasSelectedLanguage =
        prefs.getBool(OnboardingDirector.KEY_LANGUAGE) ?? false;
    bool hasSelectedInterests =
        prefs.getBool(OnboardingDirector.KEY_INTERESTS) ?? false;

    // First launch check
    bool isFirstLaunch =
        !hasSeenOnboarding && !hasSelectedLanguage && !hasSelectedInterests;

    if (mounted) {
      if (isFirstLaunch) {
        // NEW USER: Splash → Onboarding flow (all screens)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SplashScreen(isReturningUser: false),
          ),
        );
      } else {
        // RETURNING USER: Splash → Premium only (skip onboarding)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SplashScreen(isReturningUser: true),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
