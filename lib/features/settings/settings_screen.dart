// ignore_for_file: unused_element

import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/language_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 111, 226),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n?.settings ?? 'Settings',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Features Section
              _buildSectionHeader(l10n?.topFeatures ?? 'Top Features'),
              _buildFeatureTile(
                icon: Icons.download,
                iconColor: Colors.blue,
                title: l10n?.downloadVideo ?? 'Download Video',
                subtitle:
                    l10n?.downloadSubtitle ?? 'Download your favourite files',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n?.downloadVideo ?? 'Download Video'} - Use the browser to download videos',
                      ),
                    ),
                  );
                },
              ),
              _buildFeatureTile(
                icon: Icons.facebook,
                iconColor: const Color(0xFF0066ff),
                title: l10n?.watchVideo ?? 'Watch Video',
                subtitle:
                    l10n?.watchSubtitle ?? 'Watch videos directly on Facebook',
                onTap: () => _launchFacebook(context),
              ),
              _buildFeatureTile(
                icon: Icons.folder_open,
                iconColor: Colors.green,
                title: l10n?.savedVideos ?? 'Saved videos',
                subtitle: l10n?.savedSubtitle ?? 'Open Downloaded Videos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              _buildFeatureTileWithImage(
                imagePath: 'assets/images/Language.png',
                title: l10n?.languages ?? 'Languages',
                subtitle: l10n?.languagesSubtitle ?? 'Change your languages',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Communications Section
              _buildSectionHeader(l10n?.communications ?? 'Communications'),

              _buildFeatureTile(
                icon: Icons.subscriptions,
                iconColor: Colors.deepPurple,
                title: l10n?.manageSubscription ?? 'Manage Subscription',
                subtitle:
                    l10n?.subscriptionSubtitle ?? 'Manage your Subscription',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
              ),
              _buildFeatureTile(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: l10n?.giveUsReview ?? 'Give Us Review',
                subtitle:
                    l10n?.supportUsWithReview ??
                    'Support us with your valuable review',
                onTap: () => _launchReview(context),
              ),
              _buildFeatureTile(
                icon: Icons.apps_rounded,
                iconColor: Colors.purple,
                title: l10n?.moreApps ?? 'More Apps',
                subtitle:
                    l10n?.discoverOurApps ?? 'Discover our other applications',
                onTap: () => _launchMoreApps(context),
              ),

              _buildFeatureTile(
                icon: Icons.share,
                iconColor: Colors.orange,
                title: l10n?.shareApp ?? 'Share App',
                subtitle:
                    l10n?.shareSubtitle ?? 'Share Video Downloader with others',
                onTap: () => _showShareOptions(context, l10n),
              ),

              _buildFeatureTile(
                icon: Icons.description_outlined,
                iconColor: Colors.indigo,
                title: l10n?.termsOfUse ?? 'Terms of Use',
                subtitle:
                    l10n?.readTermsConditions ?? 'Read our Terms & Conditions',
                onTap: () => _launchTermsOfUse(context),
              ),

              _buildFeatureTile(
                icon: Icons.privacy_tip,
                iconColor: Colors.teal,
                title: l10n?.privacyPolicy ?? 'Privacy Policy',
                subtitle: l10n?.privacySubtitle ?? 'Open app privacy policy',
                onTap: () => _launchPrivacyPolicy(context),
              ),

              _buildFeatureTile(
                icon: Icons.copyright,
                iconColor: Colors.grey,
                title: l10n?.disclaimer ?? 'Disclaimer',
                subtitle:
                    l10n?.disclaimerSubtitle ??
                    'Contents are protected by copyright',
                onTap: () => _showDisclaimerDialog(context, l10n),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== BUILDER WIDGETS ======================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
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
      ),
    );
  }

  Widget _buildFeatureTileWithImage({
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Image.asset(imagePath, width: 24, height: 24),
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
      ),
    );
  }

  // ====================== LAUNCH METHODS ======================

  void _launchURL(BuildContext context, String url, String errorMsg) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  void _launchReview(BuildContext context) {
    const url =
        'https://play.google.com/store/apps/details?id=com.yourcompany.facebook_video_downloader';
    _launchURL(context, url, 'Could not open Play Store for review');
  }

  void _launchMoreApps(BuildContext context) {
    const url =
        'https://play.google.com/store/apps/developer?id=FutureDial+Labs+LLC';
    _launchURL(context, url, 'Could not open More Apps');
  }

  void _launchTermsOfUse(BuildContext context) {
    const url =
        'https://docs.google.com/document/d/12WTnUBG0hlYkg5fRPIwxP4VnNkUhv_gnC19ulCfgHic/edit?tab=t.0#heading=h.yww4ag84enkv';
    _launchURL(context, url, 'Could not open Terms of Use');
  }

  void _launchPrivacyPolicy(BuildContext context) async {
    const url =
        'https://sites.google.com/view/inverter-town-llc/privacy-policy';
    _launchURL(context, url, 'Could not open Privacy Policy');
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _launchFacebook(BuildContext context) {
    const url = 'https://www.facebook.com';
    _launchURL(context, url, 'Could not open Facebook');
  }

  // ====================== SHARE & DIALOG METHODS ======================

  void _showShareOptions(BuildContext context, AppLocalizations? l10n) {
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
            Text(
              l10n?.shareApp ?? 'Share App',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              title: Text(l10n?.shareAppLink ?? 'Share App Link'),
              onTap: () {
                Navigator.pop(context);
                _shareAppLink(context, l10n);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.app_blocking_rounded,
                  color: Colors.blue,
                ),
              ),
              title: Text(l10n?.shareAPKFile ?? 'Share APK File'),
              onTap: () {
                Navigator.pop(context);
                _shareAPKFile(context, l10n);
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
              title: Text(l10n?.shareQRCode ?? 'Share QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareAppLink(BuildContext context, AppLocalizations? l10n) {
    final appLink =
        'https://play.google.com/store/apps/details?id=com.yourcompany.facebook_video_downloader';
    final message =
        '''
📱 Facebook Video Downloader App

${l10n?.downloadNow ?? 'Download now'}: $appLink

${l10n?.appDescription ?? 'Enjoy downloading videos from Facebook easily!'}
    ''';

    Share.share(message);
  }

  Future<void> _shareAPKFile(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    _showShareAlternativeDialog(context, l10n);
  }

  void _showShareAlternativeDialog(
    BuildContext context,
    AppLocalizations? l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.shareApp ?? 'Share App'),
        content: Text(
          l10n?.shareAppLinkMessage ?? 'Share the app link with your friends.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareAppLink(context, l10n);
            },
            child: Text(l10n?.shareLink ?? 'Share Link'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.shareViaQRCode ?? 'Share via QR Code',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.qr_code, size: 150, color: Colors.black),
              const SizedBox(height: 20),
              Text(l10n?.scanToDownload ?? 'Scan to download the app'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n?.close ?? 'Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareAppLink(context, l10n);
                      },
                      child: Text(l10n?.shareLink ?? 'Share Link'),
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

  void _showDisclaimerDialog(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.disclaimerTitle ?? 'Disclaimer'),
        content: SingleChildScrollView(
          child: Text(
            l10n?.disclaimerContent ?? 'Contents are protected by copyright...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.aboutApp ?? 'About App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_library, size: 60, color: Color(0xFF0066ff)),
            const SizedBox(height: 10),
            Text(
              l10n?.appTitle ?? 'Facebook Video Downloader',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${l10n?.version ?? 'Version'} 1.0.0'),
            const SizedBox(height: 15),
            Text(
              l10n?.appDescription ??
                  'Download and save videos from Facebook easily.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }
}
