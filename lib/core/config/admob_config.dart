import 'dart:io';

import 'package:flutter/foundation.dart';

import 'app_env.dart';

class AdMobConfig {
  static bool get isTestMode => AppEnv.admobTestMode;

  /// Google sample ad units (Android).
  static const _androidTestAppOpen = 'ca-app-pub-3940256099942544/3419835294';
  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _androidTestMrec = 'ca-app-pub-3940256099942544/6300978111';

  /// Google sample ad units (iOS).
  static const _iosTestAppOpen = 'ca-app-pub-3940256099942544/5575463023';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';
  static const _iosTestMrec = 'ca-app-pub-3940256099942544/2934735716';

  static String _resolve({
    required String androidProd,
    required String iosProd,
    required String androidTest,
    required String iosTest,
  }) {
    if (isTestMode) {
      return Platform.isIOS ? iosTest : androidTest;
    }
    if (Platform.isAndroid) return androidProd;
    if (Platform.isIOS) return iosProd;
    throw UnsupportedError('Unsupported platform');
  }

  static String get appOpenAdUnitId => _resolve(
    androidProd: AppEnv.admobAndroidAppOpenId,
    iosProd: AppEnv.admobIosAppOpenId,
    androidTest: _androidTestAppOpen,
    iosTest: _iosTestAppOpen,
  );

  static String get bannerAdUnitId => _resolve(
    androidProd: AppEnv.admobAndroidBannerId,
    iosProd: AppEnv.admobIosBannerId,
    androidTest: _androidTestBanner,
    iosTest: _iosTestBanner,
  );

  static String get interstitialAdUnitId => _resolve(
    androidProd: AppEnv.admobAndroidInterstitialId,
    iosProd: AppEnv.admobIosInterstitialId,
    androidTest: _androidTestInterstitial,
    iosTest: _iosTestInterstitial,
  );

  static String get rewardedAdUnitId => _resolve(
    androidProd: AppEnv.admobAndroidRewardedId,
    iosProd: AppEnv.admobIosRewardedId,
    androidTest: _androidTestRewarded,
    iosTest: _iosTestRewarded,
  );

  static String get mrecAdUnitId => _resolve(
    androidProd: AppEnv.admobAndroidMrecId,
    iosProd: AppEnv.admobIosMrecId,
    androidTest: _androidTestMrec,
    iosTest: _iosTestMrec,
  );

  static Future<void> configure() async {
    if (!isTestMode) return;
    debugPrint('AdMob test mode ON — using Google sample ad unit IDs');
  }
}
