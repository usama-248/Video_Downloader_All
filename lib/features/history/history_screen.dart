
// lib/features/history/history_screen.dart (Updated version with full refresh)

import 'package:facebook_video_downloader/controllers/history_controller.dart';
import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:facebook_video_downloader/widgets/history_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:facebook_video_downloader/core/config/admob_config.dart';

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
  final DownloadController controller = Get.find<DownloadController>();
  final HistoryController analyticsController = Get.put(HistoryController());

  final Set<int> _deletingItems = {};
  int _currentBottomNavIndex = 2;
  
  // Add this for refresh state
  bool _isRefreshing = false;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.loadHistory();
    _loadBannerAd();
    _logScreenView();
  }

  void _logScreenView() async {
    await analyticsController.logScreenViewEvent();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          analyticsController.logBannerAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('History Screen BannerAd failed to load: $error');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
          analyticsController.logBannerAdFailed(error.toString());
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
    await analyticsController.logOpenFacebook();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _onBottomNavTap(BuildContext context, int index) {
    final localizations = AppLocalizations.of(context)!;

    String tabName = '';
    if (index == 0) {
      tabName = localizations.home;
      analyticsController.logBottomNavTap(index, tabName);
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else {
        Navigator.pop(context);
      }
    } else if (index == 1) {
      tabName = localizations.watch;
      analyticsController.logBottomNavTap(index, tabName);
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

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteVideo),
        content: Text('${localizations.delete} "${item['fileName']}"?'),
        actions: [
          TextButton(
            onPressed: () {
              analyticsController.logDeleteConfirmDialog('cancel');
              Navigator.pop(context, false);
            },
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              analyticsController.logDeleteConfirmDialog('confirm');
              Navigator.pop(context, true);
            },
            child: Text(
              localizations.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, String dateTimeStr) {
    final localizations = AppLocalizations.of(context)!;

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (diff.inDays > 0) {
        final days = diff.inDays;
        if (days == 1) {
          return localizations.oneDayAgo;
        } else {
          return localizations.daysAgo(days);
        }
      } else if (diff.inHours > 0) {
        final hours = diff.inHours;
        if (hours == 1) {
          return localizations.oneHourAgo;
        } else {
          return localizations.hoursAgo(hours);
        }
      } else if (diff.inMinutes > 0) {
        final minutes = diff.inMinutes;
        if (minutes == 1) {
          return localizations.oneMinuteAgo;
        } else {
          return localizations.minutesAgo(minutes);
        }
      } else {
        return localizations.justNow;
      }
    } catch (e) {
      return localizations.unknownDate;
    }
  }

  // UPDATED: Refresh with loading state and circular indicators
  Future<void> _refreshHistory(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    
    // Show refreshing state
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final previousCount = controller.downloadHistory.length;
      await analyticsController.logRefreshHistory(previousCount);
      
      // This will trigger full rebuild of ALL widgets
      await controller.fullRefreshHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.historyRefreshed),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _playVideo(
    BuildContext context,
    Map<String, dynamic> item,
    int position,
  ) async {
    await analyticsController.logVideoItemClick(
      item['fileName'].toString(),
      position,
    );
    await analyticsController.logPlayVideo(
      item['fileName'].toString(),
      item['quality'].toString(),
      item['fileSize'].toString(),
    );
    await OpenFile.open(item['filePath'].toString());
  }

  Future<void> _deleteVideo(
    BuildContext context,
    Map<String, dynamic> item,
    int itemId,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final remainingCount = controller.downloadHistory.length - 1;
    await analyticsController.logDeleteVideo(
      item['fileName'].toString(),
      item['quality'].toString(),
      remainingCount,
    );

    setState(() {
      _deletingItems.add(itemId);
    });
    await controller.deleteHistoryItem(item['id'], item['filePath']);
    setState(() {
      _deletingItems.remove(itemId);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['fileName']} ${localizations.deleted}')),
      );
    }
  }

  void _goToPremium(BuildContext context) async {
    await analyticsController.logNavigateToPremium();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  void _goToSettings(BuildContext context) async {
    await analyticsController.logNavigateToSettings();
    if (widget.showBottomNav) {
      widget.onBackToHome?.call();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  void _goBack(BuildContext context) async {
    await analyticsController.logBackButton();
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Track empty history if needed
    if (controller.downloadHistory.isEmpty && !_isRefreshing) {
      analyticsController.onEmptyHistoryShown();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.showBottomNav,
        leading: widget.showBottomNav
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _goBack(context),
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations.videoDownloader,
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
          if (AppFeatures.showPremiumScreen)
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
                onPressed: () => _goToPremium(context),
                tooltip: localizations.premium,
              ),
            ),
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
              tooltip: localizations.facebook,
            ),
          ),
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
              onPressed: () => _goToSettings(context),
              tooltip: localizations.settings,
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
            if (_isAdLoaded && _bannerAd != null)
              Container(
                margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
              ),
            Expanded(child: _buildHistoryList(context)),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavigationBar(
              currentIndex: _currentBottomNavIndex,
              onTap: (index) => _onBottomNavTap(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF0066ff),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: const ImageIcon(
                    AssetImage('assets/images/Home.png'),
                    size: 24,
                  ),
                  label: localizations.home,
                ),
                BottomNavigationBarItem(
                  icon: const ImageIcon(
                    AssetImage('assets/images/Watch_Video.png'),
                    size: 24,
                  ),
                  label: localizations.watch,
                ),
                BottomNavigationBarItem(
                  icon: const ImageIcon(
                    AssetImage('assets/images/FileSave.png'),
                    size: 24,
                  ),
                  label: localizations.saved,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final history = controller.downloadHistory;

    // Show loading indicator while refreshing
    if (_isRefreshing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Refreshing history...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/No_media_found.png',
              height: 90,
              width: 90,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.video_library,
                size: 90,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noDownloadsYet,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.downloadFromBrowser,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isRefreshing ? null : () => _refreshHistory(context),
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: Text(
                localizations.refresh,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshHistory(context),
            color: Colors.white,
            backgroundColor: const Color(0xFF0066ff),
            child: ListView.builder(
              key: const PageStorageKey('history_list'),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final itemId = item['id'] as int;

                if (_deletingItems.contains(itemId)) {
                  return const SizedBox.shrink();
                }

                return Dismissible(
                  key: Key('history_item_${itemId}_${item['filePath']}'),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    final shouldDelete = await _showDeleteConfirmationDialog(
                      context,
                      item,
                    );
                    if (shouldDelete == true) {
                      await _deleteVideo(context, item, itemId);
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
                  child: HistoryItemWidget(
                    item: item,
                    index: index,
                    onPlay: () => _playVideo(context, item, index),
                    onDeleteConfirm: () => _showDeleteConfirmationDialog(context, item),
                    onDelete: () => _deleteVideo(context, item, itemId),
                    formatDate: () => _formatDate(context, item['dateTime']),
                    // Pass refresh state to force thumbnail reload
                    forceReload: _isRefreshing,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}