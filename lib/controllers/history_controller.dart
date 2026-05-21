
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/core/services/screen_time_tracker.dart';
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

  // Observable variables
  var isAdLoaded = false.obs;
  var isDeleting = false.obs;
  
  // Screen time display (optional)
  var screenTimeText = '00:00'.obs;
  Timer? _screenTimeUpdateTimer;

  BannerAd? bannerAd;

  @override
  void onInit() {
    super.onInit();
    loadBannerAd();
    _logScreenView();
    _startScreenTimeTracking();
    developer.log('HistoryController initialized', name: 'Analytics');
  }

  @override
  void onClose() {
    _stopScreenTimeTracking();
    bannerAd?.dispose();
    super.onClose();
  }

  // ================= SCREEN TIME TRACKING =================

  void _startScreenTimeTracking() {
    ScreenTimeTracker.startTracking('HistoryScreen');
    
    _screenTimeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = ScreenTimeTracker.getCurrentTimeSpent('HistoryScreen');
      screenTimeText.value = _formatTime(seconds);
    });
    
    developer.log('⏱️ Screen time tracking started for HistoryScreen', name: 'Timer');
  }

  void _stopScreenTimeTracking() {
    ScreenTimeTracker.stopTracking('HistoryScreen');
    _screenTimeUpdateTimer?.cancel();
    _screenTimeUpdateTimer = null;
    developer.log('⏱️ Screen time tracking stopped for HistoryScreen', name: 'Timer');
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ================= BANNER AD =================

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: historyScreenBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoaded.value = true;
          logBannerAdLoaded();
          developer.log('Banner ad loaded successfully', name: 'Ads');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isAdLoaded.value = false;
          logBannerAdFailed(error.toString());
          developer.log('Banner ad failed: $error', name: 'Ads');
        },
      ),
    );
    bannerAd!.load();
  }

  // ================= BANNER AD ANALYTICS =================

  Future<void> logBannerAdLoaded() async {
    try {
      await analytics.logEvent(
        name: 'history_banner_ad_loaded',
        parameters: {
          'ad_type': 'banner',
          'screen': 'history',
        },
      );
      developer.log('✓ Banner ad loaded event logged', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging banner ad loaded: $e', name: 'Analytics');
    }
  }

  Future<void> logBannerAdFailed(String error) async {
    try {
      await analytics.logEvent(
        name: 'history_banner_ad_failed',
        parameters: {
          'error': error,
          'screen': 'history',
        },
      );
      developer.log('✓ Banner ad failed event logged: $error', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging banner ad failed: $e', name: 'Analytics');
    }
  }

  // ================= ANALYTICS METHODS =================

  Future<void> logScreenViewEvent() async {
    try {
      await analytics.logScreenView(
        screenName: 'HistoryScreen',
        screenClass: 'HistoryScreen',
      );
      developer.log('✓ Screen view logged: HistoryScreen', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging screen view: $e', name: 'Analytics');
    }
  }

  Future<void> _logScreenView() async {
    await logScreenViewEvent();
  }

  Future<void> logPlayVideo(
    String fileName,
    String quality,
    String fileSize,
  ) async {
    try {
      await analytics.logEvent(
        name: 'play_video_history',
        parameters: {
          'file_name': _truncateString(fileName, 50),
          'quality': quality,
          'file_size': fileSize,
        },
      );
      developer.log('✓ EVENT: play_video_history - $fileName', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging play video: $e', name: 'Analytics');
    }
  }

  Future<void> logDeleteVideo(
    String fileName,
    String quality,
    int remainingCount,
  ) async {
    try {
      await analytics.logEvent(
        name: 'delete_video_history',
        parameters: {
          'file_name': _truncateString(fileName, 50),
          'quality': quality,
          'remaining_count': remainingCount,
        },
      );
      developer.log('✓ EVENT: delete_video_history - $fileName', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging delete video: $e', name: 'Analytics');
    }
  }

  Future<void> logDeleteAllVideos(int deletedCount) async {
    try {
      await analytics.logEvent(
        name: 'delete_all_videos_history',
        parameters: {'deleted_count': deletedCount},
      );
      developer.log('✓ EVENT: delete_all_videos_history - Count: $deletedCount', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging delete all: $e', name: 'Analytics');
    }
  }

  Future<void> logRefreshHistory(int historyCount) async {
    try {
      await analytics.logEvent(
        name: 'refresh_history',
        parameters: {'total_videos': historyCount},
      );
      developer.log('✓ EVENT: refresh_history - Total: $historyCount', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging refresh: $e', name: 'Analytics');
    }
  }

  Future<void> logNavigateToPremium() async {
    try {
      await analytics.logEvent(
        name: 'navigate_premium_history',
        parameters: {'from_screen': 'history'},
      );
      developer.log('✓ EVENT: navigate_premium_history', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging navigate premium: $e', name: 'Analytics');
    }
  }

  Future<void> logNavigateToSettings() async {
    try {
      await analytics.logEvent(
        name: 'navigate_settings_history',
        parameters: {'from_screen': 'history'},
      );
      developer.log('✓ EVENT: navigate_settings_history', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging navigate settings: $e', name: 'Analytics');
    }
  }

  Future<void> logOpenFacebook() async {
    try {
      await analytics.logEvent(
        name: 'open_facebook_history',
        parameters: {'from_screen': 'history'},
      );
      developer.log('✓ EVENT: open_facebook_history', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging open facebook: $e', name: 'Analytics');
    }
  }

  Future<void> logBottomNavTap(int index, String tabName) async {
    try {
      await analytics.logEvent(
        name: 'bottom_nav_tap_history',
        parameters: {
          'from_screen': 'history',
          'target_tab': tabName,
          'tab_index': index,
        },
      );
      developer.log('✓ EVENT: bottom_nav_tap_history to $tabName', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging bottom nav: $e', name: 'Analytics');
    }
  }

  Future<void> logVideoItemClick(String fileName, int position) async {
    try {
      await analytics.logEvent(
        name: 'video_item_click_history',
        parameters: {
          'file_name': _truncateString(fileName, 50),
          'position': position,
        },
      );
      developer.log('✓ EVENT: video_item_click_history at position $position', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging video item click: $e', name: 'Analytics');
    }
  }

  Future<void> logShareVideo(String fileName, String quality) async {
    try {
      await analytics.logEvent(
        name: 'share_video_history',
        parameters: {
          'file_name': _truncateString(fileName, 50),
          'quality': quality,
          'from_screen': 'history',
        },
      );
      developer.log('✓ EVENT: share_video_history - $fileName', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging share video: $e', name: 'Analytics');
    }
  }

  Future<void> logViewVideoInfo(
    String fileName,
    String quality,
    String fileSize,
  ) async {
    try {
      await analytics.logEvent(
        name: 'view_video_info_history',
        parameters: {
          'file_name': _truncateString(fileName, 50),
          'quality': quality,
          'file_size': fileSize,
        },
      );
      developer.log('✓ EVENT: view_video_info_history - $fileName', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging video info: $e', name: 'Analytics');
    }
  }

  Future<void> logBackButton() async {
    try {
      await analytics.logEvent(
        name: 'back_button_history',
        parameters: {'from_screen': 'history'},
      );
      developer.log('✓ EVENT: back_button_history', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging back button: $e', name: 'Analytics');
    }
  }

  Future<void> logSearchQuery(String query, int resultsCount) async {
    try {
      await analytics.logEvent(
        name: 'search_history',
        parameters: {
          'query': _truncateString(query, 30),
          'results_count': resultsCount,
        },
      );
      developer.log('✓ EVENT: search_history - $query', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging search: $e', name: 'Analytics');
    }
  }

  Future<void> logClearSearch() async {
    try {
      await analytics.logEvent(name: 'clear_search', parameters: {});
      developer.log('✓ EVENT: clear_search', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging clear search: $e', name: 'Analytics');
    }
  }

  Future<void> logSortHistory(String sortBy) async {
    try {
      await analytics.logEvent(
        name: 'sort_history',
        parameters: {'sort_by': sortBy},
      );
      developer.log('✓ EVENT: sort_history - $sortBy', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging sort: $e', name: 'Analytics');
    }
  }

  Future<void> logFilterByQuality(String quality) async {
    try {
      await analytics.logEvent(
        name: 'filter_history',
        parameters: {'filter_by': 'quality', 'quality': quality},
      );
      developer.log('✓ EVENT: filter_history - quality: $quality', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging filter: $e', name: 'Analytics');
    }
  }

  Future<void> logClearFilter() async {
    try {
      await analytics.logEvent(name: 'clear_filter', parameters: {});
      developer.log('✓ EVENT: clear_filter', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging clear filter: $e', name: 'Analytics');
    }
  }

  Future<void> logEmptyHistory() async {
    try {
      await analytics.logEvent(name: 'empty_history_view', parameters: {});
      developer.log('✓ EVENT: empty_history_view', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging empty history: $e', name: 'Analytics');
    }
  }

  Future<void> logDeleteConfirmDialog(String action) async {
    try {
      await analytics.logEvent(
        name: 'delete_dialog_action_history',
        parameters: {'action': action},
      );
      developer.log('✓ EVENT: delete_dialog_action_history - $action', name: 'Analytics');
    } catch (e) {
      developer.log('✗ Error logging delete dialog: $e', name: 'Analytics');
    }
  }

  // Helper method to truncate strings
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;
    return str.substring(0, maxLength);
  }

  // ================= OPEN FACEBOOK =================

  Future<void> openInChrome(String url) async {
    await logOpenFacebook();
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        developer.log('Facebook opened successfully', name: 'Navigation');
      } else {
        developer.log('Cannot open Facebook URL: $url', name: 'Navigation');
      }
    } catch (e) {
      developer.log('Error opening Facebook: $e', name: 'Navigation');
    }
  }

  // ================= NAVIGATION =================

  void goToPremium() async {
    if (!AppFeatures.showPremiumScreen) return;
    await logNavigateToPremium();
    try {
      await Get.to(() => const PremiumScreen());
      developer.log('Navigated to Premium screen', name: 'Navigation');
    } catch (e) {
      developer.log('Error navigating to premium: $e', name: 'Navigation');
    }
  }

  void goToSettings() async {
    await logNavigateToSettings();
    try {
      await Get.to(() => const SettingsScreen());
      developer.log('Navigated to Settings screen', name: 'Navigation');
    } catch (e) {
      developer.log('Error navigating to settings: $e', name: 'Navigation');
    }
  }

  void goToHome() async {
    try {
      await analytics.logEvent(
        name: 'navigate_home_from_history',
        parameters: {'from_screen': 'history'},
      );
      await Get.offAllNamed('/home');
      developer.log('Navigated to Home screen', name: 'Navigation');
    } catch (e) {
      developer.log('Error navigating to home: $e', name: 'Navigation');
    }
  }

  void goToWatch() async {
    try {
      await analytics.logEvent(
        name: 'navigate_watch_from_history',
        parameters: {'from_screen': 'history'},
      );
      await Get.offAllNamed('/home', arguments: {'tab': 1});
      developer.log('Navigated to Watch screen', name: 'Navigation');
    } catch (e) {
      developer.log('Error navigating to watch: $e', name: 'Navigation');
    }
  }

  void onBackPressed() async {
    await logBackButton();
  }

  // ================= REFRESH =================

  Future<void> refreshHistory(DownloadController controller) async {
    try {
      final previousCount = controller.downloadHistory.length;
      await logRefreshHistory(previousCount);
      await controller.fullRefreshHistory(); // Changed to fullRefreshHistory

      Get.snackbar(
        'Success',
        'History refreshed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      developer.log('History refreshed successfully', name: 'Data');
    } catch (e) {
      developer.log('Error refreshing history: $e', name: 'Data');
      Get.snackbar(
        'Error',
        'Failed to refresh history',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // ================= DELETE METHODS =================

  Future<void> deleteVideo(
    Map<String, dynamic> item,
    DownloadController controller,
    int index,
  ) async {
    if (isDeleting.value) return;

    isDeleting.value = true;

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Video'),
          content: Text('Delete "${item['fileName']}"?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await logDeleteConfirmDialog('cancel');
                Get.back(result: false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await logDeleteConfirmDialog('confirm');
                Get.back(result: true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (confirm == true) {
        final remainingCount = controller.downloadHistory.length - 1;
        await logDeleteVideo(
          item['fileName'].toString(),
          item['quality'].toString(),
          remainingCount,
        );

        try {
          final file = File(item['filePath'].toString());
          if (await file.exists()) {
            await file.delete();
            developer.log('File deleted: ${item['fileName']}', name: 'File');
          }
        } catch (e) {
          developer.log('Error deleting file: $e', name: 'File');
        }

        await controller.deleteHistoryItem(item['id'], item['filePath']);

        Get.snackbar(
          'Deleted',
          'Video deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      developer.log('Error in delete video: $e', name: 'Error');
      Get.snackbar(
        'Error',
        'Failed to delete video',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> deleteAllVideos(DownloadController controller) async {
    if (isDeleting.value) return;

    isDeleting.value = true;

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete All Videos'),
          content: Text(
            'Delete all ${controller.downloadHistory.length} videos?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await logDeleteConfirmDialog('cancel_all');
                Get.back(result: false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await logDeleteConfirmDialog('confirm_all');
                Get.back(result: true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (confirm == true) {
        final deletedCount = controller.downloadHistory.length;
        await logDeleteAllVideos(deletedCount);

        int successfullyDeleted = 0;
        for (var item in controller.downloadHistory) {
          try {
            final file = File(item['filePath'].toString());
            if (await file.exists()) {
              await file.delete();
              successfullyDeleted++;
            }
          } catch (e) {
            developer.log('Error deleting file: $e', name: 'File');
          }
        }

        // await controller.deleteAllHistory();

        Get.snackbar(
          'Deleted',
          '$successfullyDeleted videos deleted',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      developer.log('Error deleting all videos: $e', name: 'Error');
      Get.snackbar(
        'Error',
        'Failed to delete videos',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // ================= PLAY VIDEO =================

  Future<void> playVideo(Map<String, dynamic> item, int position) async {
    try {
      await logVideoItemClick(item['fileName'].toString(), position);
      await logPlayVideo(
        item['fileName'].toString(),
        item['quality'].toString(),
        item['fileSize'].toString(),
      );

      final result = await OpenFile.open(item['filePath'].toString());

      if (result.type == ResultType.done) {
        developer.log('Video played: ${item['fileName']}', name: 'Video');
      } else {
        developer.log('Failed to play video: ${result.message}', name: 'Video');
      }
    } catch (e) {
      developer.log('Error playing video: $e', name: 'Error');
      Get.snackbar(
        'Error',
        'Could not play video',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // ================= SHARE VIDEO =================

  Future<void> shareVideo(Map<String, dynamic> item) async {
    try {
      await logShareVideo(
        item['fileName'].toString(),
        item['quality'].toString(),
      );

      Get.snackbar(
        'Share',
        'Share feature coming soon',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      developer.log('Share video: ${item['fileName']}', name: 'Share');
    } catch (e) {
      developer.log('Error sharing video: $e', name: 'Error');
    }
  }

  // ================= VIDEO INFO =================

  void showVideoInfo(Map<String, dynamic> item) async {
    try {
      await logViewVideoInfo(
        item['fileName'].toString(),
        item['quality'].toString(),
        item['fileSize'].toString(),
      );

      Get.dialog(
        AlertDialog(
          title: const Text('Video Information'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('File Name:', item['fileName'].toString()),
              const SizedBox(height: 12),
              _buildInfoRow('Quality:', item['quality'].toString()),
              const SizedBox(height: 12),
              _buildInfoRow('File Size:', item['fileSize'].toString()),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Downloaded:',
                formatDate(item['dateTime'].toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Path:', item['filePath'].toString()),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error showing video info: $e', name: 'Error');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // ================= SORT METHODS =================

  void sortByDateDesc() async {
    await logSortHistory('date_desc');
  }

  void sortByDateAsc() async {
    await logSortHistory('date_asc');
  }

  void sortByNameAsc() async {
    await logSortHistory('name_asc');
  }

  void sortByNameDesc() async {
    await logSortHistory('name_desc');
  }

  void sortBySizeDesc() async {
    await logSortHistory('size_desc');
  }

  void sortBySizeAsc() async {
    await logSortHistory('size_asc');
  }

  // ================= FILTER METHODS =================

  void filterByQuality(String quality) async {
    await logFilterByQuality(quality);
  }

  void clearFilter() async {
    await logClearFilter();
  }

  // ================= SEARCH METHODS =================

  Future<void> performSearch(String query, List historyList) async {
    await logSearchQuery(query, historyList.length);
  }

  void onClearSearch() async {
    await logClearSearch();
  }

  // ================= THUMBNAIL =================

  Future<String?> getThumbnail(String videoPath, String fileName) async {
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
      developer.log('Error generating thumbnail: $e', name: 'Thumbnail');
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

  // ================= BOTTOM NAVIGATION =================

  void onBottomNavTap(int index) {
    String tabName = '';
    switch (index) {
      case 0:
        tabName = 'home';
        goToHome();
        break;
      case 1:
        tabName = 'watch';
        goToWatch();
        break;
      case 2:
        tabName = 'history';
        break;
    }
    if (index != 2) {
      logBottomNavTap(index, tabName);
    }
  }

  // ================= EMPTY STATE =================

  void onEmptyHistoryShown() {
    logEmptyHistory();
  }
}
