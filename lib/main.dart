// //working alllllllllllllllllll

// import 'dart:io';
// import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'features/home/home_screen.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // FIX: Scan videos when app opens (solves gallery not showing)
//   if (Platform.isAndroid) {
//     await Future.delayed(Duration(seconds: 1));
//     await Process.run('am', [
//       'broadcast',
//       '-a',
//       'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
//       '-d',
//       'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
//     ]);
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [ChangeNotifierProvider(create: (_) => DownloadController())],
//       child: MaterialApp(
//         title: 'Video Downloader',
//         theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//         debugShowCheckedModeBanner: false,
//         home: const HomeScreen(),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
// import 'package:facebook_video_downloader/features/providers/language_provider.dart';
// import 'package:facebook_video_downloader/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:provider/provider.dart';
// import 'features/home/home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // FIX: Scan videos when app opens (solves gallery not showing)
//   if (Platform.isAndroid) {
//     await Future.delayed(Duration(seconds: 1));
//     await Process.run('am', [
//       'broadcast',
//       '-a',
//       'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
//       '-d',
//       'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
//     ]);
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => DownloadController()),
//         ChangeNotifierProvider(create: (_) => LanguageProvider()),
//       ],
//       child: Consumer<LanguageProvider>(
//         builder: (context, languageProvider, child) {
//           return MaterialApp(
//             title: 'Video Downloader',
//             locale: languageProvider.locale,
//             localizationsDelegates: const [
//               AppLocalizations.delegate,
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: const [
//               Locale('en'),
//               Locale('ur'),
//               Locale('ar'),
//             ],
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//               useMaterial3: true,
//             ),
//             debugShowCheckedModeBanner: false,
//             home: const HomeScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/onboarding/screens/onboarding_screen.dart';
import 'package:facebook_video_downloader/features/providers/language_provider.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if onboarding has been shown before
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('show_onboarding') ?? true;

  // FIX: Scan videos when app opens (solves gallery not showing)
  if (Platform.isAndroid) {
    await Future.delayed(Duration(seconds: 1));
    await Process.run('am', [
      'broadcast',
      '-a',
      'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
      '-d',
      'file:///storage/emulated/0/Pictures/VideoDownloaderApp',
    ]);
  }

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

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
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            debugShowCheckedModeBanner: false,
            // Show onboarding or home screen based on first launch
            home: showOnboarding
                ? const OnboardingScreen()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}
