//workingggggggggggggg
// import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'app/app.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => DownloadController()),
//       ],
//       child: MaterialApp(
//         title: 'Video Downloader Browser',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//         ),
//         debugShowCheckedModeBanner: false,
//         home: App(),
//       ),
//     );
//   }
// }

//working alllllllllllllllllll

import 'dart:io';
import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DownloadController())],
      child: MaterialApp(
        title: 'Video Downloader',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
