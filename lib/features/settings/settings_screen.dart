

// ignore_for_file: unused_element

import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/language_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 111, 226),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Settings'.tr,
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
          onPressed: () => Get.back(),
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
              _buildSectionHeader('Top Features'.tr),
              _buildFeatureTile(
                icon: Icons.download,
                iconColor: Colors.blue,
                title: 'Download Video'.tr,
                subtitle: 'Use the browser to download videos'.tr,
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    'Download Video'.tr,
                    'Use the browser to download videos',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildFeatureTile(
                icon: Icons.facebook,
                iconColor: const Color(0xFF0066ff),
                title: 'Watch Video'.tr,
                subtitle: 'Watch Videos'.tr,
                onTap: () => _launchFacebook(),
              ),
              _buildFeatureTile(
                icon: Icons.folder_open,
                iconColor: Colors.green,
                title: 'Saved Videos'.tr,
                subtitle: 'Open Downloaded Videos'.tr,
                onTap: () {
                  Get.to(
                    () => HistoryScreen(
                      showBottomNav: true,
                      onBackToHome: () {
                        Get.back(); // Pop HistoryScreen
                        Get.back(); // Pop SettingsScreen
                      },
                    ),
                  );
                },
              ),
              _buildFeatureTileWithImage(
                imagePath: 'assets/images/Language.png',
                title: 'Languages'.tr,
                subtitle: 'Choose your Language'.tr,
                onTap: () {
                  Get.to(() => const LanguageSelectorScreen());
                },
              ),

              const SizedBox(height: 16),

              // Communications Section
              _buildSectionHeader('Communications'.tr),

              if (AppFeatures.showPremiumScreen)
                _buildFeatureTile(
                  icon: Icons.subscriptions,
                  iconColor: Colors.deepPurple,
                  title: 'Manage Subscription'.tr,
                  subtitle: 'Choose your Plan'.tr,
                  onTap: () {
                    Get.to(() => const PremiumScreen());
                  },
                ),
              _buildFeatureTile(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: 'Give Us Review'.tr,
                subtitle: 'Support Us With Review'.tr,
                onTap: () => _launchReview(),
              ),
              _buildFeatureTile(
                icon: Icons.share,
                iconColor: Colors.orange,
                title: 'Share App'.tr,
                subtitle: 'Share the App with Your Friends'.tr,
                onTap: () => _shareApp(),
              ),
              _buildFeatureTile(
                icon: Icons.apps_rounded,
                iconColor: Colors.purple,
                title: 'More Apps'.tr,
                subtitle: 'Discover Our Apps'.tr,
                onTap: () => _launchMoreApps(),
              ),

              _buildFeatureTile(
                icon: Icons.description_outlined,
                iconColor: Colors.indigo,
                title: 'Terms of Use'.tr,
                subtitle: 'Read Terms and Conditions'.tr,
                onTap: () => _launchTermsOfUse(),
              ),

              _buildFeatureTile(
                icon: Icons.privacy_tip,
                iconColor: Colors.teal,
                title: 'Privacy Policy'.tr,
                subtitle: 'Read Our Privacy Policy'.tr,
                onTap: () => _launchPrivacyPolicy(),
              ),

              _buildFeatureTile(
                backgroundColor: Colors.white.withOpacity(0.95),
                icon: Icons.copyright,
                iconColor: Colors.grey,
                title: 'Disclaimer'.tr,
                subtitle: 'Disclaimer App'.tr,
                onTap: () => _showDisclaimerDialog(),
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
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
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

  Future<void> _launchURL(String url, String errorMsg) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _launchReview() {
    _launchURL(AppEnv.rateUsUrl, 'Could not open Play Store for review');
  }

  void _launchMoreApps() {
    _launchURL(AppEnv.moreAppsUrl, 'Could not open More Apps');
  }

  void _launchTermsOfUse() {
    _launchURL(AppEnv.termsOfUseUrl, 'Could not open Terms of Use');
  }

  void _launchPrivacyPolicy() {
    _launchURL(AppEnv.privacyPolicyUrl, 'Could not open Privacy Policy');
  }

  void _launchFacebook() {
    const String url = 'https://www.facebook.com';
    _launchURL(url, 'Could not open Facebook');
  }

  // ====================== SHARE FUNCTIONALITY ======================

  void _shareApp() {
    Share.share(AppEnv.shareAppUrl);
  }

  void _showDisclaimerDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Disclaimer'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Please get the permissions from the owner before reposting videos.\n Any unauthorized actions (re-uploading or downloading of contents) and/or violations of intellectual property\n rights is the sole responsibility of the user'
                .tr,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('aboutApp'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_library, size: 60, color: Color(0xFF0066ff)),
            const SizedBox(height: 10),
            Text(
              'appTitle'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${'version'.tr} 1.0.0'),
            const SizedBox(height: 15),
            Text('appDescription'.tr, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
        ],
      ),
    );
  }
}
