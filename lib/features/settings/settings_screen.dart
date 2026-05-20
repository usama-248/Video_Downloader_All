

// ignore_for_file: unused_element

import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/language_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 111, 226),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations.settings,
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
              _buildSectionHeader(context, localizations.topFeatures),
              _buildFeatureTile(
                context,
                icon: Icons.download,
                iconColor: Colors.blue,
                title: localizations.downloadVideo,
                subtitle: localizations.useBrowserToDownloadVideos,
                onTap: () {
                  Get.back();
                },
              ),
              _buildFeatureTile(
                context,
                icon: Icons.facebook,
                iconColor: const Color(0xFF0066ff),
                title: localizations.watchVideo,
                subtitle: localizations.watchVideos,
                onTap: () => _launchFacebook(context),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.folder_open,
                iconColor: Colors.green,
                title: localizations.savedVideos,
                subtitle: localizations.openDownloadedVideos,
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
                context,
                imagePath: 'assets/images/Language.png',
                title: localizations.languages,
                subtitle: localizations.chooseYourLanguage,
                onTap: () {
                  Get.to(() => const LanguageSelectorScreen());
                },
              ),

              const SizedBox(height: 16),

              // Communications Section
              _buildSectionHeader(context, localizations.communications),

              if (AppFeatures.showPremiumScreen)
                _buildFeatureTile(
                  context,
                  icon: Icons.subscriptions,
                  iconColor: Colors.deepPurple,
                  title: localizations.manageSubscription,
                  subtitle: localizations.chooseYourPlan,
                  onTap: () {
                    Get.to(() => const PremiumScreen());
                  },
                ),
              _buildFeatureTile(
                context,
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: localizations.giveUsReview,
                subtitle: localizations.supportUsWithReview,
                onTap: () => _launchReview(context),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.share,
                iconColor: Colors.orange,
                title: localizations.shareApp,
                subtitle: localizations.shareAppWithFriends,
                onTap: () => _shareApp(),
              ),
              _buildFeatureTile(
                context,
                icon: Icons.apps_rounded,
                iconColor: Colors.purple,
                title: localizations.moreApps,
                subtitle: localizations.discoverOurApps,
                onTap: () => _launchMoreApps(context),
              ),

              _buildFeatureTile(
                context,
                icon: Icons.description_outlined,
                iconColor: Colors.indigo,
                title: localizations.termsOfUse,
                subtitle: localizations.readTermsAndConditions,
                onTap: () => _launchTermsOfUse(context),
              ),

              _buildFeatureTile(
                context,
                icon: Icons.privacy_tip,
                iconColor: Colors.teal,
                title: localizations.privacyPolicy,
                subtitle: localizations.readOurPrivacyPolicy,
                onTap: () => _launchPrivacyPolicy(context),
              ),

              _buildFeatureTile(
                context,
                backgroundColor: Colors.white.withOpacity(0.95),
                icon: Icons.copyright,
                iconColor: Colors.grey,
                title: localizations.disclaimer,
                subtitle: localizations.disclaimerApp,
                onTap: () => _showDisclaimerDialog(context),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== BUILDER WIDGETS ======================
  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildFeatureTile(
    BuildContext context, {
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

  Widget _buildFeatureTileWithImage(
    BuildContext context, {
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

  Future<void> _launchURL(
    BuildContext context,
    String url,
    String errorMsg,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      Get.snackbar(
        localizations.error,
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _launchReview(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _launchURL(
      context,
      AppEnv.rateUsUrl,
      localizations.couldNotOpenPlayStoreForReview,
    );
  }

  void _launchMoreApps(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _launchURL(context, AppEnv.moreAppsUrl, localizations.couldNotOpenMoreApps);
  }

  void _launchTermsOfUse(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _launchURL(
      context,
      AppEnv.termsOfUseUrl,
      localizations.couldNotOpenTermsOfUse,
    );
  }

  void _launchPrivacyPolicy(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _launchURL(
      context,
      AppEnv.privacyPolicyUrl,
      localizations.couldNotOpenPrivacyPolicy,
    );
  }

  void _launchFacebook(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    const String url = 'https://www.facebook.com';
    _launchURL(context, url, localizations.couldNotOpenFacebook);
  }

  // ====================== SHARE FUNCTIONALITY ======================

  void _shareApp() {
    Share.share(AppEnv.shareAppUrl);
  }

  void _showDisclaimerDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          localizations.disclaimer,
          style: const TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Text(
            localizations.disclaimerText,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              localizations.ok,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        title: Text(localizations.aboutApp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_library, size: 60, color: Color(0xFF0066ff)),
            const SizedBox(height: 10),
            Text(
              localizations.appTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('${localizations.version} 1.0.0'),
            const SizedBox(height: 15),
            Text(localizations.appDescription, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }
}
