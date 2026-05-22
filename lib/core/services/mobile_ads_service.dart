import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_config.dart';
import 'ad_mediation.dart';

/// Initializes Google Mobile Ads and logs mediation adapter status.
class MobileAdsService {
  MobileAdsService._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Bidding adapters require explicit SDK initialization before ad requests.
  static Future<InitializationStatus> initialize() async {
    if (_isInitialized) {
      return MobileAds.instance.initialize();
    }

    final status = await MobileAds.instance.initialize();

    status.adapterStatuses.forEach((adapter, adapterStatus) {
      debugPrint(
        '[ADS] Adapter $adapter: ${adapterStatus.state} — ${adapterStatus.description}',
      );
    });

    await AdMobConfig.configure();

    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: <String>[
            // Add physical device IDs from logcat when testing mediation.
            // 'YOUR_DEVICE_ID',
          ],
        ),
      );
      debugPrint('[ADS] Debug test device configuration applied');
    }

    _isInitialized = true;
    debugPrint('[ADS] Mobile Ads SDK initialized (mediation: ${AdMediation.networks.join(', ')})');
    return status;
  }
}
