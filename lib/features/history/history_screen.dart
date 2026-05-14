import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart';
import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';

// Add your AdMob ad unit ID for history screen - USING REAL AD UNIT ID
const String historyScreenBannerAdUnitId =
    'ca-app-pub-3605518487927639/8115755781'; // Your real banner ad unit ID

class HistoryScreen extends StatefulWidget {
  final bool showBottomNav;
  final VoidCallback? onBackToHome;

  const HistoryScreen({
    super.key,
    this.showBottomNav = false,
    this.onBackToHome,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Track items that are being deleted to prevent multiple deletions
  final Set<int> _deletingItems = {};
  int _currentBottomNavIndex = 2; // Start on Saved tab

  // Banner Ad variables
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Firebase Analytics
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _logScreenView();
  }

  // Log screen view when screen opens
  Future<void> _logScreenView() async {
    await _analytics.logScreenView(
      screenName: 'HistoryScreen',
      screenClass: 'HistoryScreen',
    );
  }

  // Log when user views a video from history
  Future<void> _logPlayVideo(String fileName, String quality, String fileSize) async {
    await _analytics.logEvent(
      name: 'play_video_from_history',
      parameters: {
        'file_name': fileName,
        'quality': quality,
        'file_size': fileSize,
      },
    );
  }

  // Log when user deletes a video
  Future<void> _logDeleteVideo(String fileName, String quality, int historyCount) async {
    await _analytics.logEvent(
      name: 'delete_video_from_history',
      parameters: {
        'file_name': fileName,
        'quality': quality,
        'remaining_videos': historyCount - 1,
      },
    );
  }

  // Log when user refreshes history
  Future<void> _logRefreshHistory(int historyCount) async {
    await _analytics.logEvent(
      name: 'refresh_history',
      parameters: {
        'total_videos': historyCount,
      },
    );
  }

  // Log when user navigates to premium from history
  Future<void> _logNavigateToPremium() async {
    await _analytics.logEvent(
      name: 'navigate_to_premium_from_history',
      parameters: {},
    );
  }

  // Log when user navigates to settings from history
  Future<void> _logNavigateToSettings() async {
    await _analytics.logEvent(
      name: 'navigate_to_settings_from_history',
      parameters: {},
    );
  }

  // Log when user navigates to Facebook
  Future<void> _logOpenFacebook() async {
    await _analytics.logEvent(
      name: 'open_facebook_from_history',
      parameters: {},
    );
  }

  // Log bottom navigation taps
  Future<void> _logBottomNavTap(int index, String tabName) async {
    await _analytics.logEvent(
      name: 'bottom_nav_tap',
      parameters: {
        'from_screen': 'HistoryScreen',
        'target_tab': tabName,
        'tab_index': index,
      },
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: historyScreenBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('History Screen BannerAd failed to load: $error');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> openInChrome(String url) async {
    await _logOpenFacebook();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      _logBottomNavTap(index, 'Home');
      // Navigate back to main Home tab
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else {
        Navigator.pop(context);
      }
    } else if (index == 1) {
      _logBottomNavTap(index, 'Watch');
      // Navigate back to main Watch tab
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _currentBottomNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    print("HISTORY SCREEN REBUILD...");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.showBottomNav,
        leading: widget.showBottomNav
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations?.appTitle ?? 'Video Downloader',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Premium Crown Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Crown.png',
                width: 35,
                height: 35,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.star, color: Colors.white, size: 22),
              ),
              onPressed: () {
                _logNavigateToPremium();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              tooltip: localizations?.premium ?? 'Premium',
            ),
          ),
          // Facebook Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Facebookicon.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.facebook, color: Colors.white, size: 22),
              ),
              onPressed: () {
                openInChrome(AppEnv.facebookBaseUrl);
              },
              tooltip: localizations?.facebook ?? 'Facebook',
            ),
          ),
          // Settings Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Settingicon.png',
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.settings, color: Colors.white, size: 22),
              ),
              onPressed: () {
                _logNavigateToSettings();
                if (widget.showBottomNav) {
                  // If we're in bottom nav mode, navigate back to main settings
                  widget.onBackToHome?.call();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }
              },
              tooltip: localizations?.settings ?? 'Settings',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Banner Ad below the app bar
            if (_isAdLoaded && _bannerAd != null)
              Container(
                margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
              ),

            // Main content
            Expanded(
              child: Consumer<DownloadController>(
                builder: (context, controller, child) {
                  final history = controller.downloadHistory;

                  if (history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/No_media_found.png',
                            height: 90,
                            width: 90,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations?.noDownloads ?? 'No downloads yet',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations?.historyHint ??
                                'Download videos from the browser',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Refresh Button outside AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message:
                                localizations?.history ?? 'Refresh History',
                            child: TextButton(
                              child: Text(
                                localizations?.refresh ?? 'Refresh',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await _logRefreshHistory(history.length);
                                await controller.loadHistory();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      localizations?.historyHint ??
                                          'History refreshed',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final itemId = item['id'] as int;

                            // Don't show if it's currently being deleted
                            if (_deletingItems.contains(itemId)) {
                              return const SizedBox.shrink();
                            }

                            return Dismissible(
                              key: Key(itemId.toString()),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                // Show popup and wait for user decision
                                final shouldDelete =
                                    await _showDeleteConfirmationDialog(
                                      context,
                                      item,
                                      localizations,
                                    );

                                if (shouldDelete == true) {
                                  // Log delete event
                                  await _logDeleteVideo(
                                    item['fileName'],
                                    item['quality'],
                                    history.length,
                                  );
                                  
                                  // Actually delete
                                  setState(() {
                                    _deletingItems.add(itemId);
                                  });
                                  await controller.deleteHistoryItem(
                                    item['id'],
                                    item['filePath'],
                                  );
                                  setState(() {
                                    _deletingItems.remove(itemId);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item['fileName']} ${localizations?.deleted ?? 'deleted'}',
                                      ),
                                    ),
                                  );
                                }

                                return shouldDelete;
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              child: Card(
                                margin: const EdgeInsets.all(8),
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: FutureBuilder<String?>(
                                    future: _getThumbnail(item['filePath']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Colors.grey[200],
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(snapshot.data!),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          ),
                                        );
                                      }

                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[200],
                                        ),
                                        child: const Icon(
                                          Icons.video_file,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                  title: Text(
                                    item['fileName'],
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${localizations?.quality ?? 'Quality'}: ${item['quality']} | '
                                        'Size: ${item['fileSize']}', // Shows popup/estimated size
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(
                                          item['dateTime'],
                                          localizations,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      color: Color.fromARGB(255, 48, 172, 85),
                                    ),
                                    onPressed: () async {
                                      // Log play video event
                                      await _logPlayVideo(
                                        item['fileName'],
                                        item['quality'],
                                        item['fileSize'],
                                      );
                                      OpenFile.open(item['filePath']);
                                    },
                                  ),
                                  onLongPress: () => _deleteItem(
                                    context,
                                    controller,
                                    item,
                                    localizations,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavigationBar(
              currentIndex: _currentBottomNavIndex,
              onTap: _onBottomNavTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF0066ff),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    const AssetImage('assets/images/Home.png'),
                    size: 24,
                  ),
                  label: localizations?.browserTab ?? 'Home',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    const AssetImage('assets/images/Watch_Video.png'),
                    size: 24,
                  ),
                  label: localizations?.watchTab ?? 'Watch',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    const AssetImage('assets/images/FileSave.png'),
                    size: 24,
                  ),
                  label: localizations?.savedTab ?? 'Saved',
                ),
              ],
            )
          : null,
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> item,
    AppLocalizations? localizations,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations?.delete_video ?? 'Delete Video'),
        content: Text(
          '${localizations?.delete_video_confirm ?? 'Delete'} "${item['fileName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations?.delete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getThumbnail(String videoPath) async {
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

  String _formatDate(String dateTimeStr, AppLocalizations? localizations) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (diff.inDays > 0) {
        final days = diff.inDays;
        if (days == 1) {
          return '$days ${localizations?.day ?? 'day'} ${localizations?.ago ?? 'ago'}';
        } else {
          return '$days ${localizations?.days ?? 'days'} ${localizations?.ago ?? 'ago'}';
        }
      } else if (diff.inHours > 0) {
        final hours = diff.inHours;
        if (hours == 1) {
          return '$hours ${localizations?.hour ?? 'hour'} ${localizations?.ago ?? 'ago'}';
        } else {
          return '$hours ${localizations?.hours ?? 'hours'} ${localizations?.ago ?? 'ago'}';
        }
      } else if (diff.inMinutes > 0) {
        final minutes = diff.inMinutes;
        if (minutes == 1) {
          return '$minutes ${localizations?.minute ?? 'minute'} ${localizations?.ago ?? 'ago'}';
        } else {
          return '$minutes ${localizations?.minutes ?? 'minutes'} ${localizations?.ago ?? 'ago'}';
        }
      } else {
        return localizations?.just_now ?? 'Just now';
      }
    } catch (e) {
      return localizations?.unknown_date ?? 'Unknown date';
    }
  }

  void _deleteItem(
    BuildContext context,
    DownloadController controller,
    Map<String, dynamic> item,
    AppLocalizations? localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.delete_video ?? 'Delete Video'),
        content: Text(
          '${localizations?.delete_video_confirm ?? 'Delete'} "${item['fileName']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _logDeleteVideo(
                item['fileName'],
                item['quality'],
                controller.downloadHistory.length,
              );
              await controller.deleteHistoryItem(item['id'], item['filePath']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${item['fileName']} ${localizations?.deleted ?? 'deleted'}',
                  ),
                ),
              );
            },
            child: Text(
              localizations?.delete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}