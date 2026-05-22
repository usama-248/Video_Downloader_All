
// ignore_for_file: avoid_print, unnecessary_underscores, deprecated_member_use

import 'package:facebook_video_downloader/core/services/screen_time_tracker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../core/config/admob_config.dart';
import '../core/config/app_env.dart';
import '../core/config/app_features.dart';

// Firebase Analytics
final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

class HomeController extends GetxController {
  // Observable variables
  var currentIndex = 0.obs;
  var hasAgreed = false.obs;
  var isLoading = true.obs;

  // Browser screen variables - Make it nullable
  TextEditingController? urlController;
  var title = Rx<String?>(null);
  var imageUrl = Rx<String?>(null);
  var isFetching = false.obs;
  var showVideoPreview = false.obs;

  // Flag to track if we came back from webview
  var _justReturnedFromWebview = false;

  // Ad variables
  var isBannerLoaded = false.obs;
  var isMrecLoaded = false.obs;
  var isInterstitialLoaded = false.obs;
  var isWatchBannerLoaded = false.obs;

  // Screen time display (optional)
  var screenTimeText = '00:00'.obs;
  Timer? _screenTimeUpdateTimer;

  // Non-observable
  BannerAd? _bannerAd;
  BannerAd? _mrecAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _watchBannerAd;
  Completer<void>? _adCompleter;

  // Flag to check if controller is still active
  bool _isClosed = false;

  // Track current tab for screen time
  String _currentScreenName = 'BrowserTab';

  @override
  void onInit() {
    super.onInit();
    // Initialize controller here
    urlController = TextEditingController();
    _checkAgreementStatus();
    _logScreenView();
    _logAppOpen();
    _loadBrowserBannerAd();
    _loadMrecAd();
    _loadInterstitialAd();
    _loadWatchBannerAd();
    _startScreenTimeTracking();

    // Add navigation listener to detect returning to home screen
    _setupNavigationListener();
  }

  @override
  void onClose() {
    _isClosed = true;
    _stopScreenTimeTracking();
    // Dispose controller properly
    urlController?.dispose();
    urlController = null;
    _bannerAd?.dispose();
    _mrecAd?.dispose();
    _interstitialAd?.dispose();
    _watchBannerAd?.dispose();
    super.onClose();
  }

  void _setupNavigationListener() {
    // Listen to route changes
    ever(currentIndex, (int index) {
      if (index == 0 && _justReturnedFromWebview) {
        // We're back on browser tab after webview
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _clearPreviewAndShowMrec();
        });
        _justReturnedFromWebview = false;
      }
    });
  }

  // ==================== SCREEN TIME TRACKING ====================

  void _startScreenTimeTracking() {
    // Start tracking for initial screen
    _updateScreenTracking();

    // Optional: Update timer display every second (for UI)
    _screenTimeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      final seconds = ScreenTimeTracker.getCurrentTimeSpent(_currentScreenName);
      screenTimeText.value = _formatTime(seconds);
    });

    developer.log(
      '⏱️ Screen time tracking started for HomeController',
      name: 'Timer',
    );
  }

  void _stopScreenTimeTracking() {
    // Stop tracking current screen
    ScreenTimeTracker.stopTracking(_currentScreenName);

    // Cancel UI timer
    _screenTimeUpdateTimer?.cancel();
    _screenTimeUpdateTimer = null;

    developer.log(
      '⏱️ Screen time tracking stopped for HomeController',
      name: 'Timer',
    );
  }

  void _updateScreenTracking() {
    // Stop tracking previous screen
    ScreenTimeTracker.stopTracking(_currentScreenName);

    // Update current screen name based on tab
    switch (currentIndex.value) {
      case 0:
        _currentScreenName = 'BrowserTab';
        break;
      case 1:
        _currentScreenName = 'WatchTab';
        break;
      case 2:
        _currentScreenName = 'SavedTab';
        break;
    }

    // Start tracking new screen
    ScreenTimeTracker.startTracking(_currentScreenName);

    developer.log(
      '⏱️ Switched to tracking: $_currentScreenName',
      name: 'Timer',
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get current screen time (for UI display)
  String getCurrentScreenTime() {
    return screenTimeText.value;
  }

  // Safe method to update URL text
  void updateUrlText(String text) {
    if (!_isClosed && urlController != null) {
      urlController!.text = text;
    }
  }

  // Safe method to get URL text
  String getUrlText() {
    if (!_isClosed && urlController != null) {
      return urlController!.text.trim();
    }
    return '';
  }

  // ==================== Analytics Methods ====================

  Future<void> _logScreenView() async {
    await _analytics.logScreenView(
      screenName: 'HomeScreen',
      screenClass: 'HomeScreen',
    );
  }

  Future<void> _logAppOpen() async {
    await _analytics.logEvent(
      name: 'app_open',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'is_premium': false,
      },
    );
  }

  Future<void> logTabChange(int index, String tabName) async {
    // Update screen tracking when tab changes
    _updateScreenTracking();

    await _analytics.logEvent(
      name: 'tab_change',
      parameters: {
        'tab_index': index,
        'tab_name': tabName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logDisclaimerAgreed() async {
    await _analytics.logEvent(
      name: 'disclaimer_agreed',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'decision': 'accept',
      },
    );
  }

  Future<void> logDisclaimerCancelled() async {
    await _analytics.logEvent(
      name: 'disclaimer_cancelled',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'decision': 'cancel',
      },
    );
  }

  Future<void> logPasteLink() async {
    await _analytics.logEvent(
      name: 'paste_link_click',
      parameters: {
        'button_name': 'paste_button',
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logClearUrl() async {
    await _analytics.logEvent(
      name: 'clear_url_click',
      parameters: {
        'button_name': 'clear_button',
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logFetchVideo(String url) async {
    await _analytics.logEvent(
      name: 'fetch_video_click',
      parameters: {
        'button_name': 'fetch_button',
        'url_length': url.length,
        'has_facebook': url.contains('facebook') ? 1 : 0,
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logVideoPreview(String? title, bool hasThumbnail) async {
    await _analytics.logEvent(
      name: 'video_preview_shown',
      parameters: {
        'has_title': title != null ? 1 : 0,
        'has_thumbnail': hasThumbnail ? 1 : 0,
        'screen': 'BrowserTab',
      },
    );
  }

  Future<void> logDownloadClick() async {
    await _analytics.logEvent(
      name: 'download_click',
      parameters: {
        'button_name': 'download_button',
        'from_screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logNavigateToWebView(String url) async {
    await _analytics.logEvent(
      name: 'open_in_browser',
      parameters: {
        'button_name': 'open_in_browser_button',
        'from_screen': 'BrowserTab',
        'url_length': url.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logRetryFetch() async {
    await _analytics.logEvent(
      name: 'retry_fetch_click',
      parameters: {
        'button_name': 'retry_button',
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logShareVideo() async {
    await _analytics.logEvent(
      name: 'share_video_click',
      parameters: {
        'button_name': 'share_button',
        'content_type': 'video',
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logSaveToDevice() async {
    await _analytics.logEvent(
      name: 'save_to_device_click',
      parameters: {
        'button_name': 'save_button',
        'content_type': 'video',
        'screen': 'BrowserTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logOpenFacebook() async {
    await _analytics.logEvent(
      name: 'open_facebook_click',
      parameters: {
        'button_name': 'facebook_button',
        'from_screen': 'WatchTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logRefreshWatchTab() async {
    await _analytics.logEvent(
      name: 'refresh_watch_tab_click',
      parameters: {
        'button_name': 'refresh_button',
        'screen': 'WatchTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logViewHelpGuide() async {
    await _analytics.logEvent(
      name: 'help_guide_click',
      parameters: {
        'button_name': 'help_button',
        'from_screen': 'WatchTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logHelpGuideGotIt() async {
    await _analytics.logEvent(
      name: 'help_guide_got_it_click',
      parameters: {
        'button_name': 'got_it_button',
        'dialog_name': 'HelpGuide',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPremiumButtonClick() async {
    await _analytics.logEvent(
      name: 'premium_button_click',
      parameters: {
        'button_name': 'premium_button',
        'from_screen': _getCurrentScreenName(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logSettingsButtonClick() async {
    await _analytics.logEvent(
      name: 'settings_button_click',
      parameters: {
        'button_name': 'settings_button',
        'from_screen': _getCurrentScreenName(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logHistoryButtonClick() async {
    await _analytics.logEvent(
      name: 'history_button_click',
      parameters: {
        'button_name': 'history_button',
        'from_screen': _getCurrentScreenName(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logDeleteAllSaved() async {
    await _analytics.logEvent(
      name: 'delete_all_saved_click',
      parameters: {
        'button_name': 'delete_all_button',
        'screen': 'SavedTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logDeleteSingleSaved(int index, String videoTitle) async {
    await _analytics.logEvent(
      name: 'delete_single_saved_click',
      parameters: {
        'button_name': 'delete_button',
        'item_index': index,
        'video_title': videoTitle.length > 50
            ? videoTitle.substring(0, 50)
            : videoTitle,
        'screen': 'SavedTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPlaySavedVideo(String videoTitle) async {
    await _analytics.logEvent(
      name: 'play_saved_video_click',
      parameters: {
        'button_name': 'play_button',
        'video_title': videoTitle.length > 50
            ? videoTitle.substring(0, 50)
            : videoTitle,
        'screen': 'SavedTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logShareSavedVideo(String videoTitle) async {
    await _analytics.logEvent(
      name: 'share_saved_video_click',
      parameters: {
        'button_name': 'share_button',
        'video_title': videoTitle.length > 50
            ? videoTitle.substring(0, 50)
            : videoTitle,
        'content_type': 'saved_video',
        'screen': 'SavedTab',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logVideoPlayerClose() async {
    await _analytics.logEvent(
      name: 'video_player_close_click',
      parameters: {
        'button_name': 'close_button',
        'screen': 'VideoPlayer',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logBackButtonClick() async {
    await _analytics.logEvent(
      name: 'back_button_click',
      parameters: {
        'button_name': 'back_button',
        'from_screen': _getCurrentScreenName(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  String _getCurrentScreenName() {
    switch (currentIndex.value) {
      case 0:
        return 'BrowserTab';
      case 1:
        return 'WatchTab';
      case 2:
        return 'SavedTab';
      default:
        return 'HomeScreen';
    }
  }

  // ==================== Disclaimer Methods ====================

  Future<void> _checkAgreementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreedBefore = prefs.getBool('disclaimer_agreed') ?? false;

    hasAgreed.value = hasAgreedBefore;
    isLoading.value = false;

    if (!hasAgreed.value) {
      Future.delayed(Duration.zero, () {
        if (!_isClosed) {
          _showDisclaimerDialog();
        }
      });
    }
  }

  Future<void> _saveAgreementStatus(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_agreed', agreed);
    hasAgreed.value = agreed;

    if (agreed) {
      await logDisclaimerAgreed();
    } else {
      await logDisclaimerCancelled();
    }
  }

  void _showDisclaimerDialog() {
    if (hasAgreed.value || _isClosed) return;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          await _analytics.logEvent(
            name: 'disclaimer_back_press',
            parameters: {
              'button_name': 'back_button',
              'dialog': 'Disclaimer',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066ff).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/Disclaimer.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF0066ff),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Disclaimer Title'.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 2, color: Colors.grey.shade200),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066ff).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 16,
                        color: const Color(0xFF0066ff),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Attention Please',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0066ff),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Disclaimer Content'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/FileSave.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.cloud_off,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We will not upload or store any of your downloaded or personal data.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/Privacyicon.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.security,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We are also not collecting and/or transmitting any of your personal or sensitive data from your device.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _analytics.logEvent(
                  name: 'disclaimer_cancel_click',
                  parameters: {
                    'button_name': 'cancel_button',
                    'dialog': 'Disclaimer',
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );
                await logDisclaimerCancelled();
                SystemNavigator.pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _analytics.logEvent(
                  name: 'disclaimer_accept_click',
                  parameters: {
                    'button_name': 'accept_button',
                    'dialog': 'Disclaimer',
                    'decision_time': DateTime.now().toIso8601String(),
                    'app_version': '1.0.0',
                  },
                );
                await _saveAgreementStatus(true);
                if (Get.context != null && !_isClosed) Get.back();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF0066ff),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Accept'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==================== Ad Methods ====================

  void _loadBrowserBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!_isClosed) isBannerLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
          if (!_isClosed) isBannerLoaded.value = false;
        },
      ),
    )..load();
  }

  void _loadMrecAd() {
    _mrecAd = BannerAd(
      adUnitId: AdMobConfig.mrecAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!_isClosed) {
            isMrecLoaded.value = true;
            print('✅ MREC Ad loaded successfully');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ MREC Ad failed to load: $error');
          ad.dispose();
          if (!_isClosed) isMrecLoaded.value = false;
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isClosed) {
            ad.dispose();
            return;
          }
          _interstitialAd = ad;
          isInterstitialLoaded.value = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              if (_adCompleter != null && !_adCompleter!.isCompleted) {
                _adCompleter!.complete();
              }
              ad.dispose();
              if (!_isClosed) {
                _loadInterstitialAd();
                isInterstitialLoaded.value = false;
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (_adCompleter != null && !_adCompleter!.isCompleted) {
                _adCompleter!.complete();
              }
              ad.dispose();
              if (!_isClosed) {
                _loadInterstitialAd();
                isInterstitialLoaded.value = false;
              }
            },
          );
          update();
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          if (!_isClosed) isInterstitialLoaded.value = false;
        },
      ),
    );
  }

  void _loadWatchBannerAd() {
    _watchBannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!_isClosed) isWatchBannerLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('Watch Screen BannerAd failed to load: $error');
          ad.dispose();
          if (!_isClosed) isWatchBannerLoaded.value = false;
        },
      ),
    )..load();
  }

  Future<void> showInterstitialAd() async {
    if (_isClosed) return;
    if (isInterstitialLoaded.value && _interstitialAd != null) {
      _adCompleter = Completer<void>();
      _interstitialAd!.show();
      await _adCompleter!.future;
    }
    return;
  }

  BannerAd? get bannerAd => _bannerAd;
  BannerAd? get mrecAd => _mrecAd;
  BannerAd? get watchBannerAd => _watchBannerAd;

  // ==================== Browser Methods ====================

  Future<void> pasteLink() async {
    if (_isClosed) return;

    await logPasteLink();
    await showInterstitialAd();

    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      updateUrlText(data.text!);
      Get.snackbar(
        'Success',
        'Link pasted successfully!',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearUrl() async {
    if (_isClosed) return;

    await logClearUrl();

    updateUrlText('');
    Get.snackbar(
      'Cleared',
      'URL cleared successfully!',
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> fetchVideo() async {
    if (_isClosed) return;

    String url = getUrlText();

    if (url.isEmpty) {
      Get.snackbar('Error', 'please_paste_link'.tr);
      return;
    }

    await logFetchVideo(url);
    await showInterstitialAd();

    showVideoPreview.value = true;
    isFetching.value = true;

    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    await _fetchMetadata(url);

    isFetching.value = false;
  }

  Future<void> retryFetch() async {
    if (_isClosed) return;

    await logRetryFetch();
    await fetchVideo();
  }

  Future<void> _fetchMetadata(String url) async {
    if (_isClosed) return;
    if (url.isEmpty || !url.contains(AppEnv.facebookHost)) return;

    try {
      final metadata = await MetadataFetch.extract(url);
      if (!_isClosed) {
        title.value = metadata?.title ?? 'Video Preview';
        imageUrl.value = metadata?.image;
        await logVideoPreview(title.value, imageUrl.value != null);
      }
    } catch (e) {
      if (!_isClosed) {
        title.value = 'Video Preview';
        imageUrl.value = null;
        await logVideoPreview(null, false);
      }
    }
  }

  Future<void> navigateToWebView() async {
    if (_isClosed) return;

    String finalUrl = getUrlText();
    if (finalUrl.isEmpty) {
      Get.snackbar('Error', 'please_paste_link'.tr);
      return;
    }

    await logNavigateToWebView(finalUrl);
    await logDownloadClick();
    await showInterstitialAd();

    if (!finalUrl.startsWith('http')) {
      finalUrl = 'https://$finalUrl';
    }

    // Set flag that we're going to webview
    _justReturnedFromWebview = true;

    // Navigate to webview
    await Get.toNamed('/webview', arguments: {'url': finalUrl});

    // This code runs AFTER returning from webview
    _clearPreviewAndShowMrec();
  }

  Future<void> shareVideo() async {
    if (_isClosed) return;

    await logShareVideo();

    String videoUrl = getUrlText();
    if (videoUrl.isNotEmpty) {
      Get.snackbar(
        'Share',
        'Sharing video...',
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> saveToDevice() async {
    if (_isClosed) return;

    await logSaveToDevice();

    Get.snackbar(
      'Save',
      'Saving video to device...',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> openInChrome(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening URL: $e');
    }
  }

  void resetVideoPreview() {
    if (_isClosed) return;
    showVideoPreview.value = false;
    title.value = null;
    imageUrl.value = null;
  }

  // ==================== Watch Tab Methods ====================

  Future<void> refreshWatchTab() async {
    if (_isClosed) return;

    await logRefreshWatchTab();

    Get.snackbar(
      'Refresh',
      'Refreshing content...',
      duration: const Duration(seconds: 1),
    );
  }

  void goToPremium() {
    if (_isClosed || !AppFeatures.showPremiumScreen) return;
    Get.toNamed('/premium');
  }

  void goToSettings() {
    if (_isClosed) return;
    Get.toNamed('/settings');
  }

  void goToHistory() {
    if (_isClosed) return;
    Get.toNamed('/history');
  }

  void openFacebook() async {
    if (_isClosed) return;
    await logOpenFacebook();
    openInChrome(AppEnv.facebookBaseUrl);
  }

  void showHelpGuide() {
    if (_isClosed) return;
    logViewHelpGuide();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Color(0xFF0066ff)),
            const SizedBox(width: 8),
            Text(
              'How to Download Videos'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogStep('1', 'step_1'.tr),
            const SizedBox(height: 12),
            _buildDialogStep('2', 'Tap the share button'),
            const SizedBox(height: 12),
            _buildDialogStep('3', 'Select "Copy Link"'),
            const SizedBox(height: 12),
            _buildDialogStep('4', 'step_2'.tr),
            const SizedBox(height: 12),
            _buildDialogStep('5', 'step_3'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await logHelpGuideGotIt();
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0066ff),
            ),
            child: Text(
              'got_it'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF0066ff).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066ff),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  // ==================== Saved Tab Methods ====================

  Future<void> deleteAllSaved() async {
    if (_isClosed) return;

    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete All'),
        content: const Text(
          'Are you sure you want to delete all saved videos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await logDeleteAllSaved();
      Get.snackbar('Deleted', 'All videos deleted successfully!');
    }
  }

  Future<void> deleteSingleSaved(int index, String videoTitle) async {
    if (_isClosed) return;

    await logDeleteSingleSaved(index, videoTitle);

    Get.snackbar('Deleted', 'Video deleted successfully!');
  }

  Future<void> playSavedVideo(String videoTitle) async {
    if (_isClosed) return;

    await logPlaySavedVideo(videoTitle);

    Get.toNamed('/video_player', arguments: {'title': videoTitle});
  }

  Future<void> shareSavedVideo(String videoTitle) async {
    if (_isClosed) return;

    await logShareSavedVideo(videoTitle);

    Get.snackbar('Share', 'Sharing $videoTitle...');
  }

  Future<void> closeVideoPlayer() async {
    if (_isClosed) return;

    await logVideoPlayerClose();

    Get.back();
  }

  // ==================== Navigation Methods ====================

  void changeTab(int index) {
    if (_isClosed) return;
    currentIndex.value = index;
    String tabName = index == 0 ? 'Home' : (index == 1 ? 'Watch' : 'Saved');
    logTabChange(index, tabName);
  }

  void onBackPressed() async {
    if (_isClosed) return;

    await logBackButtonClick();

    Get.back();
  }

  String? get thumbnailUrl => imageUrl.value;
  String? get videoTitle => title.value;

  // ==================== Clear Preview and Show MREC ====================

  /// Clears the video preview, removes link from URL field, and ensures MREC ad is shown
  void _clearPreviewAndShowMrec() {
    if (_isClosed) return;

    print('🔄 Clearing preview and showing MREC...');

    // Clear video preview
    resetVideoPreview();

    // Clear URL input field
    updateUrlText('');

    // Force reload MREC ad to ensure it shows
    if (_mrecAd != null) {
      _mrecAd?.dispose();
    }
    isMrecLoaded.value = false;
    _loadMrecAd();

    // Update UI
    update();

    print('✅ Preview cleared, URL cleared, MREC reloading');
  }
}
