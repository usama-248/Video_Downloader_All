// import 'package:flutter/material.dart';
// // Import these if you're using in-app purchase package
// // import 'package:in_app_purchase/in_app_purchase.dart';
// // import 'package:in_app_purchase_android/in_app_purchase_android.dart';

// class PremiumScreen extends StatelessWidget {
//   const PremiumScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 34, 111, 226),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.close,
//             color: Color.fromARGB(255, 255, 255, 255),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // Top Blue Ribbon
//             Image.asset('assets/images/premium-quality.png', height: 80),

//             const SizedBox(height: 16),

//             const Text(
//               "START LIKE A PRO",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),

//             const Text(
//               "Unlock All Features",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),

//             const SizedBox(height: 40),

//             // Features Table
//             Table(
//               columnWidths: const {
//                 0: FlexColumnWidth(2.2),
//                 1: FlexColumnWidth(1),
//                 2: FlexColumnWidth(1),
//               },
//               children: [
//                 _buildFeatureRow(
//                   "Unlimited Video Downloads",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Download in HD Quality",
//                   "assets/images/hd.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Ultra-Fast Download Speed",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Watch Trending",
//                   "assets/images/Watch_Video.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Download anything",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Seamless Experience",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   "Ads Free Experience",
//                   "assets/images/Watch_Video.png",
//                   false,
//                   true,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // Weekly Premium Plan Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Weekly Premium",
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text(
//                         "Subscription",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         "Rs 4,200",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         "Per week",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // 3-Days Free Trial Info
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Center(
//                 child: Text(
//                   "Start 3-Days Free Trial",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               "After 3-days free trial, Rs 4,200 subscription charges per week applies. Auto renews. Cancel anytime from Play Store.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//             const SizedBox(height: 25),

//             // START FREE TRIAL Button - This will trigger Google Play Billing
//             GestureDetector(
//               onTap: () {
//                 _startFreeTrial(context); // ← Payment will trigger here
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     "START FREE TRIAL",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(Icons.verified, color: Colors.green, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   "No Payment Now!",
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== FEATURE ROW WITH ASSETS ====================
//   TableRow _buildFeatureRow(
//     String feature,
//     String iconPath,
//     bool basic,
//     bool premium,
//   ) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           child: Row(
//             children: [
//               Image.asset(iconPath, height: 24, width: 24),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(feature, style: const TextStyle(fontSize: 15)),
//               ),
//             ],
//           ),
//         ),
//         Center(
//           child: basic
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//         Center(
//           child: premium
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//       ],
//     );
//   }

//   // ==================== PAYMENT FUNCTION ====================
//   void _startFreeTrial(BuildContext context) async {
//     // TODO: Add your Google Play Billing logic here

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Connecting to Google Play..."),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     // Example: You can call your billing service here
//     // await InAppPurchase.instance.purchaseStream.listen(...);
//     // Or call your custom payment function

//     // For now, showing a message. Replace this with real billing code later.
//     Future.delayed(const Duration(seconds: 2), () {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Google Play Billing Opened (Mock)"),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     });
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:facebook_video_downloader/l10n/app_localizations.dart';
// // Import these if you're using in-app purchase package
// // import 'package:in_app_purchase/in_app_purchase.dart';
// // import 'package:in_app_purchase_android/in_app_purchase_android.dart';

// class PremiumScreen extends StatelessWidget {
//   const PremiumScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 34, 111, 226),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.close,
//             color: Color.fromARGB(255, 255, 255, 255),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // Top Blue Ribbon
//             Image.asset('assets/images/premium-quality.png', height: 80),

//             const SizedBox(height: 16),

//             Text(
//               localizations?.startLikeAPro ?? "START LIKE A PRO",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),

//             Text(
//               localizations?.unlockFeatures ?? "Unlock All Features",
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),

//             const SizedBox(height: 40),

//             // Features Table
//             Table(
//               columnWidths: const {
//                 0: FlexColumnWidth(2.2),
//                 1: FlexColumnWidth(1),
//                 2: FlexColumnWidth(1),
//               },
//               children: [
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ?? "Unlimited Video Downloads",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureHD ?? "Download in HD Quality",
//                   "assets/images/hd.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureFast ?? "Ultra-Fast Download Speed",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureTrending ?? "Watch Trending",
//                   "assets/images/Watch_Video.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureAnything ?? "Download anything",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ?? "Seamless Experience",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ?? "Ads Free Experience",
//                   "assets/images/Watch_Video.png",
//                   false,
//                   true,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // Weekly Premium Plan Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         localizations?.premiumTitle ?? "Weekly Premium",
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text(
//                         "Subscription",
//                         style: const TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: const [
//                       Text(
//                         "Rs 4,200",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         "Per week",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // 3-Days Free Trial Info
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Text(
//                   localizations?.freeTrial ?? "Start 3-Days Free Trial",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               localizations?.disclaimerContent ?? "After 3-days free trial, Rs 4,200 subscription charges per week applies. Auto renews. Cancel anytime from Play Store.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//             const SizedBox(height: 25),

//             // START FREE TRIAL Button - This will trigger Google Play Billing
//             GestureDetector(
//               onTap: () {
//                 _startFreeTrial(context, localizations);
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     localizations?.freeTrial?.toUpperCase() ?? "START FREE TRIAL",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.verified, color: Colors.green, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   localizations?.noPayment ?? "No Payment Now!",
//                   style: const TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== FEATURE ROW WITH ASSETS ====================
//   TableRow _buildFeatureRow(
//     String feature,
//     String iconPath,
//     bool basic,
//     bool premium,
//   ) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           child: Row(
//             children: [
//               Image.asset(iconPath, height: 24, width: 24),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(feature, style: const TextStyle(fontSize: 15)),
//               ),
//             ],
//           ),
//         ),
//         Center(
//           child: basic
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//         Center(
//           child: premium
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//       ],
//     );
//   }

//   // ==================== PAYMENT FUNCTION ====================
//   void _startFreeTrial(BuildContext context, AppLocalizations? localizations) async {
//     // TODO: Add your Google Play Billing logic here

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(localizations?.processing_link ?? "Connecting to Google Play..."),
//         duration: const Duration(seconds: 2),
//       ),
//     );

//     // Example: You can call your billing service here
//     // await InAppPurchase.instance.purchaseStream.listen(...);
//     // Or call your custom payment function

//     // For now, showing a message. Replace this with real billing code later.
//     Future.delayed(const Duration(seconds: 2), () {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Google Play Billing Opened (Mock)"),
//           backgroundColor: Colors.blue,
//         ),
//       );
//     });
//   }
// }

//workiggggggggggggggggggggggggggggggggggggggggg
// import 'package:facebook_video_downloader/features/languageselect/languageSelectorScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:facebook_video_downloader/l10n/app_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Import these if you're using in-app purchase package
// // import 'package:in_app_purchase/in_app_purchase.dart';
// // import 'package:in_app_purchase_android/in_app_purchase_android.dart';

// class PremiumScreen extends StatelessWidget {
//   const PremiumScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 34, 111, 226),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons
//                 .arrow_back, // Changed from close to back arrow for onboarding flow
//             color: Color.fromARGB(255, 255, 255, 255),
//           ),
//           onPressed: () => _goBack(context),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => _skipToNext(context),
//             child: const Text(
//               'Skip',
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // Top Blue Ribbon
//             Image.asset('assets/images/premium-quality.png', height: 80),

//             const SizedBox(height: 16),

//             Text(
//               localizations?.startLikeAPro ?? "START LIKE A PRO",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),

//             Text(
//               localizations?.unlockFeatures ?? "Unlock All Features",
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),

//             const SizedBox(height: 40),

//             // Features Table
//             Table(
//               columnWidths: const {
//                 0: FlexColumnWidth(2.2),
//                 1: FlexColumnWidth(1),
//                 2: FlexColumnWidth(1),
//               },
//               children: [
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ??
//                       "Unlimited Video Downloads",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureHD ?? "Download in HD Quality",
//                   "assets/images/hd.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureFast ?? "Ultra-Fast Download Speed",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureTrending ?? "Watch Trending",
//                   "assets/images/Watch_Video.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureAnything ?? "Download anything",
//                   "assets/images/Download_icon.png",
//                   true,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ?? "Seamless Experience",
//                   "assets/images/Ultra_Fast_truck_.png",
//                   false,
//                   true,
//                 ),
//                 _buildFeatureRow(
//                   localizations?.featureUnlimited ?? "Ads Free Experience",
//                   "assets/images/Watch_Video.png",
//                   false,
//                   true,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // Weekly Premium Plan Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         localizations?.premiumTitle ?? "Weekly Premium",
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text(
//                         "Subscription",
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: const [
//                       Text(
//                         "Rs 4,200",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         "Per week",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // 3-Days Free Trial Info
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE3F2FD),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Text(
//                   localizations?.freeTrial ?? "Start 3-Days Free Trial",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               localizations?.disclaimerContent ??
//                   "After 3-days free trial, Rs 4,200 subscription charges per week applies. Auto renews. Cancel anytime from Play Store.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//             const SizedBox(height: 25),

//             // START FREE TRIAL Button - This will trigger Google Play Billing
//             GestureDetector(
//               onTap: () {
//                 _startFreeTrial(context, localizations);
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     localizations?.freeTrial?.toUpperCase() ??
//                         "START FREE TRIAL",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.verified, color: Colors.green, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   localizations?.noPayment ?? "No Payment Now!",
//                   style: const TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== FEATURE ROW WITH ASSETS ====================
//   TableRow _buildFeatureRow(
//     String feature,
//     String iconPath,
//     bool basic,
//     bool premium,
//   ) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           child: Row(
//             children: [
//               Image.asset(iconPath, height: 24, width: 24),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(feature, style: const TextStyle(fontSize: 15)),
//               ),
//             ],
//           ),
//         ),
//         Center(
//           child: basic
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//         Center(
//           child: premium
//               ? const Icon(Icons.check_circle, color: Colors.blue, size: 26)
//               : const Icon(Icons.close, color: Colors.red, size: 26),
//         ),
//       ],
//     );
//   }

//   // ==================== NAVIGATION FUNCTIONS ====================

//   void _goBack(BuildContext context) {
//     // Show dialog to confirm exit
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Exit Onboarding?'),
//           content: const Text(
//             'Are you sure you want to exit? You can complete the setup later from settings.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close dialog
//                 _skipToNext(context); // Skip to next screen
//               },
//               child: const Text('Continue Setup'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _skipToNext(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_seen_premium', true);

//     if (context.mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LanguageSelectorScreen()),
//       );
//     }
//   }

//   // ==================== PAYMENT FUNCTION ====================
//   void _startFreeTrial(
//     BuildContext context,
//     AppLocalizations? localizations,
//   ) async {
//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     // TODO: Add your Google Play Billing logic here
//     // For now, simulate processing
//     await Future.delayed(const Duration(seconds: 2));

//     // Close loading dialog
//     if (context.mounted) {
//       Navigator.pop(context);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             localizations?.processing_link ?? "Premium activated successfully!",
//           ),
//           duration: const Duration(seconds: 2),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Save premium status and navigate to next screen
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('has_seen_premium', true);
//       await prefs.setBool('is_premium_user', true); // Save premium status

//       if (context.mounted) {
//         await Future.delayed(const Duration(milliseconds: 500));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LanguageSelectorScreen()),
//         );
//       }
//     }
//   }
// }

// ignore_for_file: invalid_null_aware_operator

import 'package:facebook_video_downloader/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Color.fromARGB(255, 117, 115, 115),
            size: 24,
          ),
          onPressed: () => _skipToHome(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔶 Premium Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              localizations?.startLikeAPro ?? "START LIKE A PRO",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              localizations?.unlockFeatures ?? "Unlock All Features",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 🔥 FEATURES CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _featureItem(
                    Icons.download,
                    localizations?.featureUnlimited ??
                        "Unlimited Video Downloads",
                    true,
                  ),
                  _featureItem(
                    Icons.hd,
                    localizations?.featureHD ?? "Download in HD Quality",
                    true,
                  ),
                  _featureItem(
                    Icons.flash_on,
                    localizations?.featureFast ?? "Ultra-Fast Download Speed",
                    false,
                  ),
                  _featureItem(
                    Icons.trending_up,
                    localizations?.featureTrending ?? "Watch Trending",
                    true,
                  ),
                  _featureItem(
                    Icons.all_inclusive,
                    localizations?.featureAnything ?? "Download Anything",
                    true,
                  ),
                  _featureItem(
                    Icons.block,
                    localizations?.featureUnlimited ?? "Ads Free Experience",
                    false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 💳 PLAN CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Premium",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Full Access",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rs 4,200",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Per week", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🎁 FREE TRIAL BOX
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "3 Days Free Trial Included 🎉",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              localizations?.disclaimerContent ??
                  "After trial, subscription applies. Cancel anytime.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🚀 CTA BUTTON
            GestureDetector(
              onTap: () => _startFreeTrial(context, localizations),
              child: Container(
                height: 58,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    localizations?.freeTrial?.toUpperCase() ??
                        "START FREE TRIAL",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text(
                  "No Payment Now!",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= FEATURE ITEM =================
  Widget _featureItem(IconData icon, String text, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.blue : Colors.red,
          ),
        ],
      ),
    );
  }

  // Skip to Home directly
  void _skipToHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_premium', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Start free trial and go to Home
  void _startFreeTrial(
    BuildContext context,
    AppLocalizations? localizations,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // TODO: Add actual payment processing here
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.processing_link ?? "Premium activated successfully!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_user', true);
      await prefs.setBool('has_seen_premium', true);

      // Go to Home after premium activation
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }
}
