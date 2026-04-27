// import 'package:flutter/material.dart';
// import '../features/home/home_screen.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Downloader',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const HomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}