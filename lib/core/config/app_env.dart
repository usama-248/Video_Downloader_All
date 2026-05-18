import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String _value(String key, String fallback) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }

  static String get facebookBaseUrl =>
      _value('FACEBOOK_BASE_URL', 'https://www.facebook.com');

  static String get facebookHost {
    final host = Uri.tryParse(facebookBaseUrl)?.host;
    return (host == null || host.isEmpty) ? 'facebook.com' : host;
  }

  static String get facebookReferer =>
      _value('FACEBOOK_REFERER', 'https://www.facebook.com/');

  static String get appStoreUrl => _value(
    'APP_STORE_URL',
    'https://play.google.com/store/apps/details?id=com.FutureDialLabs.facebook.video.downloader',
  );

  /// Play Store listing with reviews (Give us review).
  static String get rateUsUrl => _value('RATE_US_URL', appStoreUrl);

  /// Link included when the user taps Share App.
  static String get shareAppUrl => _value('SHARE_APP_URL', appStoreUrl);

  static String get moreAppsUrl => _value(
    'MORE_APPS_URL',
    'https://play.google.com/store/apps/developer?id=FutureDial+Labs+LLC',
  );

  static String get termsOfUseUrl => _value(
    'TERMS_OF_USE_URL',
    'https://docs.google.com/document/d/12WTnUBG0hlYkg5fRPIwxP4VnNkUhv_gnC19ulCfgHic/edit?tab=t.0#heading=h.yww4ag84enkv',
  );

  static String get privacyPolicyUrl => _value(
    'PRIVACY_POLICY_URL',
    'https://sites.google.com/view/inverter-town-llc/privacy-policy',
  );

  static bool _bool(String key, {bool fallback = false}) {
    final value = dotenv.maybeGet(key)?.trim().toLowerCase();
    if (value == null || value.isEmpty) return fallback;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// When true, the app uses Google's sample ad unit IDs (safe for development).
  static bool get admobTestMode => _bool('ADMOB_TEST_MODE');

  static String get admobAndroidAppOpenId => _value(
    'ADMOB_ANDROID_APP_OPEN_ID',
    'ca-app-pub-3605518487927639/7526774448',
  );

  static String get admobAndroidBannerId => _value(
    'ADMOB_ANDROID_BANNER_ID',
    'ca-app-pub-3605518487927639/8115755781',
  );

  static String get admobAndroidInterstitialId => _value(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    'ca-app-pub-3605518487927639/3124495001',
  );

  static String get admobAndroidRewardedId => _value(
    'ADMOB_ANDROID_REWARDED_ID',
    'ca-app-pub-3605518487927639/1811413333',
  );

  static String get admobAndroidMrecId => _value(
    'ADMOB_ANDROID_MREC_ID',
    'ca-app-pub-3605518487927639/6802674114',
  );

  static String get admobAndroidAppId => _value(
    'ADMOB_ANDROID_APP_ID',
    'ca-app-pub-3605518487927639~1152937785',
  );

  static String get admobIosAppOpenId =>
      _value('ADMOB_IOS_APP_OPEN_ID', admobAndroidAppOpenId);

  static String get admobIosBannerId =>
      _value('ADMOB_IOS_BANNER_ID', admobAndroidBannerId);

  static String get admobIosInterstitialId =>
      _value('ADMOB_IOS_INTERSTITIAL_ID', admobAndroidInterstitialId);

  static String get admobIosRewardedId =>
      _value('ADMOB_IOS_REWARDED_ID', admobAndroidRewardedId);

  static String get admobIosMrecId =>
      _value('ADMOB_IOS_MREC_ID', admobAndroidMrecId);
}
