// import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
// import 'package:facebook_video_downloader/features/settings/language_screen.dart';
// import 'package:facebook_video_downloader/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           l10n.settings,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top Features Section
//             _buildSectionHeader(l10n.topFeatures),
//             _buildFeatureTile(
//               icon: Icons.download,
//               iconColor: Colors.blue,
//               title: l10n.downloadVideo,
//               subtitle: l10n.downloadSubtitle,
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${l10n.downloadVideo}...')),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.play_circle_filled,
//               iconColor: Colors.red,
//               title: l10n.watchVideo,
//               subtitle: l10n.watchSubtitle,
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${l10n.watchVideo}...')),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.folder_open,
//               iconColor: Colors.green,
//               title: l10n.savedVideos,
//               subtitle: l10n.savedSubtitle,
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${l10n.savedVideos}...')),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.language,
//               iconColor: Colors.purple,
//               title: l10n.languages,
//               subtitle: l10n.languagesSubtitle,
//               onTap: () {
//                 // Navigate to Language Screen instead of showing dialog
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LanguageScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 16),

//             // Communications Section
//             _buildSectionHeader(l10n.communications),
//             _buildFeatureTile(
//               icon: Icons.share,
//               iconColor: Colors.orange,
//               title: l10n.shareApp,
//               subtitle: l10n.shareSubtitle,
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${l10n.shareApp}...')),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.privacy_tip,
//               iconColor: Colors.teal,
//               title: l10n.privacyPolicy,
//               subtitle: l10n.privacySubtitle,
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${l10n.privacyPolicy}...')),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.subscriptions,
//               iconColor: Colors.deepPurple,
//               title: l10n.manageSubscription,
//               subtitle: l10n.subscriptionSubtitle,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const PremiumScreen()),
//                 );
//               },
//             ),
//             _buildFeatureTile(
//               icon: Icons.copyright,
//               iconColor: Colors.grey,
//               title: l10n.disclaimer,
//               subtitle: l10n.disclaimerSubtitle,
//               onTap: () {
//                 _showDisclaimerDialog(context);
//               },
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureTile({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         width: 45,
//         height: 45,
//         decoration: BoxDecoration(
//           color: iconColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: iconColor,
//           size: 24,
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontSize: 13,
//           color: Colors.grey[600],
//         ),
//       ),
//       trailing: const Icon(
//         Icons.chevron_right,
//         color: Colors.grey,
//       ),
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//     );
//   }

//   void _showDisclaimerDialog(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(l10n.disclaimerTitle),
//           content: Text(l10n.disclaimerContent),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text(l10n.ok),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// features/settings/settings_screen.dart
import 'dart:io';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/language_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Features Section
            _buildSectionHeader(l10n.topFeatures),
            _buildFeatureTile(
              icon: Icons.download,
              iconColor: Colors.blue,
              title: l10n.downloadVideo,
              subtitle: l10n.downloadSubtitle,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${l10n.downloadVideo} - Use the browser to download videos',
                    ),
                  ),
                );
              },
            ),
            _buildFeatureTile(
              icon: Icons.play_circle_filled,
              iconColor: Colors.red,
              title: l10n.watchVideo,
              subtitle: l10n.watchSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            _buildFeatureTile(
              icon: Icons.folder_open,
              iconColor: Colors.green,
              title: l10n.savedVideos,
              subtitle: l10n.savedSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            _buildFeatureTile(
              icon: Icons.language,
              iconColor: Colors.purple,
              title: l10n.languages,
              subtitle: l10n.languagesSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Communications Section
            _buildSectionHeader(l10n.communications),
            _buildFeatureTile(
              icon: Icons.share,
              iconColor: Colors.orange,
              title: l10n.shareApp,
              subtitle: 'Share app APK with friends',
              onTap: () => _showShareOptions(context),
            ),
            _buildFeatureTile(
              icon: Icons.privacy_tip,
              iconColor: Colors.teal,
              title: l10n.privacyPolicy,
              subtitle: l10n.privacySubtitle,
              onTap: () => _launchPrivacyPolicy(context),
            ),
            _buildFeatureTile(
              icon: Icons.subscriptions,
              iconColor: Colors.deepPurple,
              title: l10n.manageSubscription,
              subtitle: l10n.subscriptionSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
            ),
            _buildFeatureTile(
              icon: Icons.copyright,
              iconColor: Colors.grey,
              title: l10n.disclaimer,
              subtitle: l10n.disclaimerSubtitle,
              onTap: () {
                _showDisclaimerDialog(context);
              },
            ),
            _buildFeatureTile(
              icon: Icons.info_outline,
              iconColor: Colors.blueGrey,
              title: 'About App',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share, color: Colors.green),
              ),
              title: const Text('Share App Link'),
              subtitle: const Text('Share app store link or direct download'),
              onTap: () {
                Navigator.pop(context);
                _shareAppLink(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.app_blocking_rounded, color: Colors.blue),
              ),
              title: const Text('Share APK File'),
              subtitle: const Text('Share the app APK file directly'),
              onTap: () {
                Navigator.pop(context);
                _shareAPKFile(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code, color: Colors.orange),
              ),
              title: const Text('Share QR Code'),
              subtitle: const Text('Generate QR code for easy sharing'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _shareAppLink(BuildContext context) {
    final appLink =
        'https://play.google.com/store/apps/details?id=com.yourcompany.facebook_video_downloader';
    final message =
        '''
📱 Facebook Video Downloader App

Features:
✓ Download videos from Facebook
✓ Save videos in HD quality
✓ Watch offline anytime
✓ Built-in video player
✓ Download history
✓ Beautiful and easy to use

Download now: $appLink

Share this amazing app with your friends!
    ''';

    Share.share(message);
  }

  Future<void> _shareAPKFile(BuildContext context) async {
    // Request storage permission if needed
    if (await Permission.storage.isDenied) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission required to share APK'),
          ),
        );
        return;
      }
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Preparing APK file...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // First, try to find if APK exists in app's installation directory
      String? apkPath = await _findAPKFile();

      if (apkPath == null) {
        // If APK not found, create a shareable information file
        await _createShareableInfoFile(context);
      } else {
        // Share the APK file
        await Share.shareXFiles(
          [XFile(apkPath)],
          text:
              'Check out this Facebook Video Downloader App!\n\nInstall and enjoy downloading videos from Facebook.',
        );
      }

      Navigator.pop(context); // Close loading dialog
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      // Show error and offer alternative
      _showShareAlternativeDialog(context);
    }
  }

  Future<String?> _findAPKFile() async {
    try {
      // Try to find APK in app's installation directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final apkDir = Directory('${appDocDir.path}/apk');

      if (await apkDir.exists()) {
        final files = apkDir.listSync();
        for (var file in files) {
          if (file.path.endsWith('.apk')) {
            return file.path;
          }
        }
      }

      // Check in app's source directory
      final sourceDir = Directory('/data/app');
      if (await sourceDir.exists()) {
        final packages = sourceDir.listSync();
        for (var package in packages) {
          if (package.path.contains('facebook_video_downloader') &&
              package.path.endsWith('.apk')) {
            return package.path;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error finding APK: $e');
      return null;
    }
  }

  Future<void> _createShareableInfoFile(BuildContext context) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/share_app_info.txt';
      final file = File(filePath);

      final content = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 FACEBOOK VIDEO DOWNLOADER APP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ FEATURES:
• Download videos from Facebook easily
• Save videos in multiple qualities (HD/SD)
• Watch downloaded videos offline
• Built-in video player
• Download history management
• Beautiful and intuitive UI
• Lightweight and fast

💡 HOW TO USE:
1. Open Facebook in browser
2. Find a video you want to download
3. Tap the download button
4. Select quality and download
5. Watch anytime from saved videos

📥 DOWNLOAD LINK:
You can download the APK from:
https://www.mediafire.com/file/your-apk-link

Or search "Facebook Video Downloader" on Google Play Store

🎯 WHY CHOOSE OUR APP:
✓ 100% Free
✓ No watermark
✓ High-speed downloads
✓ Regular updates
✓ Privacy focused

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Share this app with your friends! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      ''';

      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'Facebook Video Downloader App - Download videos from Facebook easily!\n\nCheck out this amazing app!',
      );

      // Clean up temp file
      await file.delete();
    } catch (e) {
      throw Exception('Failed to create shareable file');
    }
  }

  void _showShareAlternativeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            const Text(
              'APK file not found on device',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can share the app link with your friends instead.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('Alternative ways to share:'),
                  SizedBox(height: 5),
                  Text('1. Share app link', style: TextStyle(fontSize: 12)),
                  Text('2. Share QR code', style: TextStyle(fontSize: 12)),
                  Text('3. Share instructions', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareAppLink(context);
            },
            child: const Text('Share Link'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share via QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code, size: 150, color: Colors.black),
                    const SizedBox(height: 10),
                    Text(
                      'Scan to download',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'App Download Link:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  'https://www.facebook-video-downloader.com/download',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareAppLink(context);
                      },
                      child: const Text('Share Link'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchPrivacyPolicy(BuildContext context) async {
    const url = 'https://your-privacy-policy-url.com';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch privacy policy')),
      );
    }
  }

  void _showDisclaimerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.disclaimerTitle),
          content: SingleChildScrollView(child: Text(l10n.disclaimerContent)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library, size: 60, color: Colors.blue),
              const SizedBox(height: 10),
              const Text(
                'Facebook Video Downloader',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text('Version 1.0.0'),
              const SizedBox(height: 10),
              const Text(
                'Download and save videos from Facebook easily.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text('📹 HD Quality Downloads'),
                    SizedBox(height: 5),
                    Text('💾 Save to Device Storage'),
                    SizedBox(height: 5),
                    Text('▶️ Built-in Video Player'),
                    SizedBox(height: 5),
                    Text('📂 Download History'),
                    SizedBox(height: 5),
                    Text('🔄 Regular Updates'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _shareAppLink(context);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share App'),
            ),
          ],
        );
      },
    );
  }
}
