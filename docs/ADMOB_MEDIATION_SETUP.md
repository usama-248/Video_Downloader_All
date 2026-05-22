# AdMob Mediation Setup

This app integrates three mediation partners via official Google mediation plugins:

| Network | Flutter package | AdMob mediation type |
|---------|-----------------|----------------------|
| Meta Audience Network | `gma_mediation_meta` | Bidding only |
| Liftoff Monetize | `gma_mediation_liftoffmonetize` | Bidding + waterfall |
| Mintegral | `gma_mediation_mintegral` | Bidding + waterfall |

## Code integration (done in repo)

- Dependencies in `pubspec.yaml`
- Adapter registration: `lib/core/services/ad_mediation.dart`
- SDK init + adapter status logging: `lib/core/services/mobile_ads_service.dart`
- App startup: `lib/main.dart`
- Mediation adapter logging on ad load: `lib/core/services/ad_service.dart`
- Android: Mintegral Maven repo in `android/build.gradle.kts`, `network_security_config.xml` (Meta caching), ProGuard rules
- iOS: `SKAdNetworkItems` and `GADApplicationIdentifier` in `ios/Runner/Info.plist`

## Required: AdMob console configuration

For each ad unit (banner, interstitial, rewarded, app open), in [AdMob](https://apps.admob.com/):

1. Open **Mediation** → your mediation group (or create one).
2. Add ad sources:
   - **Meta Audience Network (Bidding)** — map Placement IDs from [Meta Business Manager](https://business.facebook.com/pub/start).
   - **Liftoff Monetize (Bidding)** and/or waterfall — map App ID + Placement Reference IDs from [Liftoff dashboard](https://publisher.vungle.com/applications).
   - **Mintegral (Bidding)** and/or waterfall — map App Key, App ID, Placement ID, Ad Unit ID from [Mintegral](https://dev.mintegral.com/).
3. Disable auto-refresh on third-party banner placements (AdMob controls refresh).
4. Under **Privacy & messaging**, add **Meta**, **Liftoff**, and **Mintegral/Mobvista** to GDPR and US state regulations partner lists.

## Partner dashboards

### Meta Audience Network (bidding)

1. Create property + placements in [Business Manager](https://business.facebook.com/pub/start).
2. Select **Google AdMob** as mediation platform when creating placements.
3. In AdMob, add **Meta Audience Network (Bidding)** with each Placement ID.
4. Update `app-ads.txt` per [Meta app-ads.txt guide](https://developers.facebook.com/docs/audience-network/optimization/best-practices/authorized-sellers-app-ads/).
5. Testing: enable test mode in Meta UI; test device in AdMob; Facebook app installed and logged in on device.

### Liftoff Monetize

1. Add app and placements at [publisher.vungle.com](https://publisher.vungle.com/applications).
2. Enable **In-App Bidding** on placements used for bidding.
3. In AdMob, add Liftoff with App ID + Reference ID per format.
4. Append Liftoff entries to `app-ads.txt` from [Vungle app-ads.txt](https://publisher.vungle.com/vungleAdsTxt).
5. Optional CCPA: `GmaMediationLiftoffmonetize.setCCPAStatus(true)` before ad requests (see Liftoff docs).

### Mintegral

1. Register app and placements at [dev.mintegral.com](https://dev.mintegral.com/).
2. Use **Header Bidding** for bidding placements.
3. In AdMob waterfall setup, use Reporting API Skey/Secret from Mintegral **Account → API Tools**.
4. iOS deployment target ≥ 13.0 (project uses 14.0).

## Verify integration

1. Run the app in debug and check logs for:
   - `[ADS] Adapter ...` lines after startup
   - `[ADS] <format> loaded via mediation adapter: ...` when ads load
2. Use [Ad Inspector](https://developers.google.com/admob/flutter/ad-inspector) → **Single ad source testing** for each network.
3. Turn off test modes before release.

## References

- [AdMob Flutter mediation overview](https://developers.google.com/admob/flutter/mediation)
- [Meta](https://developers.google.com/admob/flutter/mediation/meta)
- [Liftoff Monetize](https://developers.google.com/admob/flutter/mediation/liftoff-monetize)
- [Mintegral](https://developers.google.com/admob/flutter/mediation/mintegral)
