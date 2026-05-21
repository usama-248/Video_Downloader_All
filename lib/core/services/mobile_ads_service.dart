// import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'ad_mediation.dart';
// import '../config/admob_config.dart';

// class MobileAdsService {
//   static bool _isInitialized = false;
//   static String _adapterStatus = 'Unknown';

//   static Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       // Initialize Google Mobile Ads
//       await MobileAds.instance.initialize();

//       // Register mediation adapters
//       AdMediation.registerAdapters();

//       // Log initialization info
//       debugPrint('[ADS] Mobile Ads SDK initialized successfully');
//       debugPrint('[ADS] ✅ Test Mode: ${AdMobConfig.isTestMode}');
//       debugPrint('[ADS] ✅ Platform: Android');

//       // Optional: Test if mediation is working by attempting to load a test ad
//       // This will verify that adapters are properly registered
//       await _testMediationAdapters();

//       _isInitialized = true;
//     } catch (e) {
//       debugPrint('[ADS] ❌ Failed to initialize Mobile Ads: $e');
//     }
//   }

//   // Test if mediation adapters are working by attempting to load a small test banner
//   static Future<void> _testMediationAdapters() async {
//     try {
//       // Create a temporary test banner ad to verify mediation is working
//       // This is just for testing - it won't show anything
//       final tempAd = BannerAd(
//         adUnitId: AdMobConfig.bannerAdUnitId,
//         request: const AdRequest(),
//         size: AdSize.banner,
//         listener: BannerAdListener(
//           onAdLoaded: (ad) {
//             debugPrint('[ADS] ✅ Mediation test: Ad loaded successfully');
//             _adapterStatus = 'Ready';
//             ad.dispose(); // Clean up test ad
//           },
//           onAdFailedToLoad: (ad, error) {
//             debugPrint(
//               '[ADS] ⚠️ Mediation test: Ad failed to load: ${error.message}',
//             );
//             _adapterStatus = 'Needs configuration';
//             ad.dispose();
//           },
//         ),
//       );

//       await tempAd.load();

//       // Give it a moment to load, then dispose if still loading
//       Future.delayed(const Duration(seconds: 5), () {
//         if (_adapterStatus == 'Unknown') {
//           _adapterStatus = 'Loading or not configured';
//           debugPrint(
//             '[ADS] ℹ️ Mediation test: Still loading or not configured in AdMob console',
//           );
//         }
//       });
//     } catch (e) {
//       debugPrint('[ADS] ❌ Mediation test error: $e');
//       _adapterStatus = 'Error';
//     }
//   }

//   static String get adapterStatus => _adapterStatus;
//   static bool get isInitialized => _isInitialized;
// }
