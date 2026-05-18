import 'dart:io';

import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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

  final Set<int> _deletingItems = {};
  int _currentBottomNavIndex = 2;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.loadHistory();
    _loadBannerAd();
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
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else {
        Navigator.pop(context);
      }
    } else if (index == 1) {
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
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Delete "${item['fileName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  String _formatDate(String dateTimeStr) {
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

  @override
  Widget build(BuildContext context) {
    print('History Screen build...');
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
            'Video Downloader',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              tooltip: 'Premium',
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
              tooltip: 'Facebook',
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
              onPressed: () {
                if (widget.showBottomNav) {
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
              tooltip: 'Settings',
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
            Expanded(child: _buildHistoryList()),
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
                  icon: const ImageIcon(
                    AssetImage('assets/images/Home.png'),
                    size: 24,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const ImageIcon(
                    AssetImage('assets/images/Watch_Video.png'),
                    size: 24,
                  ),
                  label: 'Watch',
                ),
                BottomNavigationBarItem(
                  icon: const ImageIcon(
                    AssetImage('assets/images/FileSave.png'),
                    size: 24,
                  ),
                  label: 'Saved',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHistoryList() {
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
              errorBuilder: (_, __, ___) => const Icon(
                Icons.video_library,
                size: 90,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Download videos from the browser',
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
            child: TextButton(
              onPressed: () async {
                await controller.loadHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                'Refresh',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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

              if (_deletingItems.contains(itemId)) {
                return const SizedBox.shrink();
              }

              return Dismissible(
                key: Key(itemId.toString()),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  final shouldDelete = await _showDeleteConfirmationDialog(
                    context,
                    item,
                  );
                  if (shouldDelete == true) {
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
                      SnackBar(content: Text('${item['fileName']} deleted')),
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
                              borderRadius: BorderRadius.circular(8),
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
                        if (snapshot.hasData && snapshot.data != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(snapshot.data!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                            borderRadius: BorderRadius.circular(8),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quality: ${item['quality']} | Size: ${item['fileSize']}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          _formatDate(item['dateTime']),
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
                        await OpenFile.open(item['filePath']);
                      },
                    ),
                    onLongPress: () async {
                      final shouldDelete = await _showDeleteConfirmationDialog(
                        context,
                        item,
                      );
                      if (shouldDelete == true) {
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
                            content: Text('${item['fileName']} deleted'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
