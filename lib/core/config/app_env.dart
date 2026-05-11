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
}
