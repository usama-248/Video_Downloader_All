import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  // App Open Ad (for app launch/resume)
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3605518487927639/7526774448';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3605518487927639/7526774448'; // Replace with your iOS ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Banner Ad
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3605518487927639/8115755781';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3605518487927639/8115755781'; // Replace with your iOS ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Interstitial Ad
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3605518487927639/3124495001';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3605518487927639/3124495001'; // Replace with your iOS ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Rewarded Ad
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3605518487927639/1811413333';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3605518487927639/1811413333'; // Replace with your iOS ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // MREC Ad (Medium Rectangle)
  static String get mrecAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3605518487927639/6802674114';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3605518487927639/6802674114'; // Replace with your iOS ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Test mode configuration
  static bool get isTestMode => false; // Set to true during development

  // Request configuration for test devices
  static Future<void> setupTestMode() async {
    if (isTestMode) {
      // Add your test device ID here (find it from console logs)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['YOUR_TEST_DEVICE_ID']),
      );
    }
  }
}
