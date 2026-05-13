import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  AppOpenAd? _appOpenAd;

  // Load Interstitial Ad
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _setupFullScreenCallback(ad);
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }
    return false;
  }

  // Load Rewarded Ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setupFullScreenCallback(ad);
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: ${error.message}');
          _rewardedAd = null;
        },
      ),
    );
  }

  // Show Rewarded Ad with callback
  Future<bool> showRewardedAd({
    required Function(RewardItem reward) onRewarded,
  }) async {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded(reward);
        },
      );
      return true;
    }
    return false;
  }

  // Setup Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('BannerAd loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    _bannerAd!.load();
  }

  // Get BannerAd Widget
  Widget? getBannerWidget() {
    return _bannerAd == null
        ? null
        : SafeArea(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          );
  }

  // Load App Open Ad
  Future<void> loadAppOpenAd() async {
    await AppOpenAd.load(
      adUnitId: AdMobConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _setupFullScreenCallback(ad);
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: ${error.message}');
          _appOpenAd = null;
        },
      ),
    );
  }

  // Show App Open Ad (when app comes to foreground)
  void showAppOpenAd() {
    if (_appOpenAd != null) {
      _appOpenAd!.show();
    }
  }

  void _setupFullScreenCallback(dynamic ad) {
    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (ad is InterstitialAd) {
          ad.dispose();
          _interstitialAd = null;
        } else if (ad is RewardedAd) {
          ad.dispose();
          _rewardedAd = null;
        } else if (ad is AppOpenAd) {
          ad.dispose();
          _appOpenAd = null;
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Ad failed to show: ${error.message}');
        if (ad is InterstitialAd) {
          ad.dispose();
          _interstitialAd = null;
        } else if (ad is RewardedAd) {
          ad.dispose();
          _rewardedAd = null;
        } else if (ad is AppOpenAd) {
          ad.dispose();
          _appOpenAd = null;
        }
      },
    );
  }

  // Clean up
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _appOpenAd?.dispose();
  }
}
