// import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

const String historyScreenBannerAdUnitId =
    'ca-app-pub-3605518487927639/8115755781';

class HistoryController extends GetxController {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    super.onInit();
    loadBannerAd();
    logScreenView();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }

  // ================= BANNER AD =================

  BannerAd? bannerAd;
  var isAdLoaded = false.obs;

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: historyScreenBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isAdLoaded.value = false;
          debugPrint('History Banner Ad failed: $error');
        },
      ),
    );
    bannerAd!.load();
  }

  // ================= ANALYTICS =================

  Future<void> logScreenView() async {
    await analytics.logScreenView(
      screenName: 'HistoryScreen',
      screenClass: 'HistoryScreen',
    );
  }

  Future<void> logPlayVideo(String fileName, String quality, String fileSize) async {
    await analytics.logEvent(
      name: 'play_video_from_history',
      parameters: {
        'file_name': fileName,
        'quality': quality,
        'file_size': fileSize,
      },
    );
  }

  Future<void> logDeleteVideo(String fileName, String quality, int historyCount) async {
    await analytics.logEvent(
      name: 'delete_video_from_history',
      parameters: {
        'file_name': fileName,
        'quality': quality,
        'remaining_videos': historyCount - 1,
      },
    );
  }

  Future<void> logRefreshHistory(int historyCount) async {
    await analytics.logEvent(
      name: 'refresh_history',
      parameters: {'total_videos': historyCount},
    );
  }

  Future<void> logNavigateToPremium() async {
    await analytics.logEvent(name: 'navigate_to_premium_from_history');
  }

  Future<void> logNavigateToSettings() async {
    await analytics.logEvent(name: 'navigate_to_settings_from_history');
  }

  Future<void> logOpenFacebook() async {
    await analytics.logEvent(name: 'open_facebook_from_history');
  }

  Future<void> logBottomNavTap(int index, String tabName) async {
    await analytics.logEvent(
      name: 'bottom_nav_tap',
      parameters: {
        'from_screen': 'HistoryScreen',
        'target_tab': tabName,
        'tab_index': index,
      },
    );
  }

  // ================= OPEN FACEBOOK =================

  Future<void> openInChrome(String url) async {
    await logOpenFacebook();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ================= NAVIGATION =================

  void goToPremium() async {
    await logNavigateToPremium();
    Get.to(() => const PremiumScreen());
  }

  void goToSettings() async {
    await logNavigateToSettings();
    Get.to(() => const SettingsScreen());
  }

  // ================= REFRESH =================

  Future<void> refreshHistory(DownloadController controller) async {
    await logRefreshHistory(controller.downloadHistory.length);
    await controller.loadHistory();
    Get.snackbar(
      'Success',
      'History refreshed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // ================= PLAY VIDEO =================

  Future<void> playVideo(Map<String, dynamic> item) async {
    await logPlayVideo(
      item['fileName'].toString(),
      item['quality'].toString(),
      item['fileSize'].toString(),
    );
    await OpenFile.open(item['filePath'].toString());
  }

  // ================= THUMBNAIL =================

  Future<String?> getThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  // ================= DATE FORMAT =================

  String formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (diff.inDays > 0) {
        final days = diff.inDays;
        if (days == 1) {
          return '$days day ago';
        } else {
          return '$days days ago';
        }
      } else if (diff.inHours > 0) {
        final hours = diff.inHours;
        if (hours == 1) {
          return '$hours hour ago';
        } else {
          return '$hours hours ago';
        }
      } else if (diff.inMinutes > 0) {
        final minutes = diff.inMinutes;
        if (minutes == 1) {
          return '$minutes minute ago';
        } else {
          return '$minutes minutes ago';
        }
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}