// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/controllers/home_controller.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Permanent controller to survive tab changes and rebuilds
    final controller = Get.put(HomeController(), permanent: true);
    final localizations = AppLocalizations.of(context)!;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            _BrowserScreen(),
            _WatchScreenWithAd(),
            HistoryScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
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
        ),
      );
    });
  }
}

// ==================== BROWSER SCREEN ====================
class _BrowserScreen extends GetView<HomeController> {
  const _BrowserScreen();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        elevation: 0,
        actions: [
          if (AppFeatures.showPremiumScreen)
            _buildIconButton(
              'assets/images/Crown.png',
              controller.goToPremium,
              localizations.premium,
            ),
          _buildIconButton(
            'assets/images/Facebookicon.png',
            () => controller.openInChrome('https://facebook.com'),
            localizations.facebook,
          ),
          _buildIconButton(
            'assets/images/Settingicon.png',
            controller.goToSettings,
            localizations.settings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Banner Ad
                Obx(
                  () =>
                      controller.isBannerLoaded.value &&
                          controller.bannerAd != null
                      ? Container(
                          key: ValueKey(
                            'banner_${controller.bannerAd!.hashCode}',
                          ),
                          margin: const EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                          ),
                          height: 50,
                          child: AdWidget(ad: controller.bannerAd!),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                _buildUrlInputSection(context),
                const SizedBox(height: 20),
                Obx(
                  () => controller.showVideoPreview.value
                      ? _buildVideoPreview(context)
                      : _buildMrecAd(context),
                ),
                const SizedBox(height: 16),
                _buildInstructionsSection(context),
                const SizedBox(height: 16),
                _buildTipSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String asset, VoidCallback onTap, String tooltip) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Image.asset(
          asset,
          width: 30,
          height: 30,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.star, color: Colors.white, size: 22),
        ),
        onPressed: () {
          if (Get.isRegistered<HomeController>()) onTap();
        },
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildUrlInputSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 230, 230).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 233, 230, 230),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 170, 166, 166),
              ),
            ),
            child: TextField(
              controller: controller.urlController,
              decoration: InputDecoration(
                hintText: localizations.pasteYourVideoLinkHere,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: Image.asset(
                  'assets/images/coy',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.link, size: 20, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (Get.isRegistered<HomeController>()) {
                      controller.pasteLink();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066ff),
                    side: const BorderSide(color: Color(0xFF0066ff)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(localizations.pasteLink),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066ff), Color(0xFF1f83ff)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      onPressed: controller.isFetching.value
                          ? null
                          : () {
                              if (Get.isRegistered<HomeController>()) {
                                controller.fetchVideo();
                              }
                            },
                      child: controller.isFetching.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(localizations.fetchVideo),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMrecAd(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: Container(
            width: 336,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: controller.isMrecLoaded.value && controller.mrecAd != null
                ? AdWidget(
                    key: ValueKey('mrec_${controller.mrecAd!.hashCode}'),
                    ad: controller.mrecAd!,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.enterUrlAndTapFetchVideo,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Obx(
      () => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: controller.isFetching.value
                  ? SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          controller.thumbnailUrl != null
                              ? Image.network(
                                  controller.thumbnailUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _defaultThumbnail(context),
                                )
                              : _defaultThumbnail(context),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.play_circle_filled,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.videoTitle ?? localizations.video,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '720p • MP4',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Get.isRegistered<HomeController>()) {
                        controller.navigateToWebView();
                      }
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(localizations.download),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066ff),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultThumbnail(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.videoReady,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.howToDownload,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildStep('1', localizations.step1),
          const SizedBox(height: 8),
          _buildStep('2', localizations.step2),
          const SizedBox(height: 8),
          _buildStep('3', localizations.step3),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0066ff).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF0066ff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildTipSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0066ff).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.tryVideosCom,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== WATCH SCREEN ====================
class _WatchScreenWithAd extends GetView<HomeController> {
  const _WatchScreenWithAd();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        elevation: 0,
        actions: [
          if (AppFeatures.showPremiumScreen)
            _buildIconButton(
              'assets/images/Crown.png',
              controller.goToPremium,
              localizations.premium,
            ),
          _buildIconButton(
            'assets/images/Facebookicon.png',
            controller.openFacebook,
            localizations.facebook,
          ),
          _buildIconButton(
            'assets/images/Settingicon.png',
            controller.goToSettings,
            localizations.settings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Watch Banner Ad
                Obx(
                  () =>
                      controller.isWatchBannerLoaded.value &&
                          controller.watchBannerAd != null
                      ? Container(
                          key: ValueKey(
                            'watch_banner_${controller.watchBannerAd!.hashCode}',
                          ),
                          margin: const EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                          ),
                          height: 50,
                          child: AdWidget(ad: controller.watchBannerAd!),
                        )
                      : const SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeroSection(context),
                      const SizedBox(height: 20),
                      _buildHowToSection(context),
                      const SizedBox(height: 20),
                      _buildProTipsSection(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String asset, VoidCallback onTap, String tooltip) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Image.asset(
          asset,
          width: 30,
          height: 30,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.star, color: Colors.white, size: 22),
        ),
        onPressed: () {
          if (Get.isRegistered<HomeController>()) onTap();
        },
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0066ff).withOpacity(0.9),
            const Color(0xFF1f83ff).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066ff).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Image.asset(
              'assets/images/Watch_Video.png',
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.watchVideos,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.tapBelowToOpen,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (Get.isRegistered<HomeController>())
                  controller.openFacebook();
              },
              icon: const Icon(Icons.open_in_browser),
              label: Text(
                localizations.openApp,
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0066ff),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066ff), Color(0xFF1f83ff)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download_for_offline,
                    color: Color(0xFF0066ff),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.howToDownloadVideos,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStepCard(
                  localizations.findAndShare,
                  localizations.watchVideosYouLike,
                  Icons.looks_one,
                  const Color(0xFF1877F2),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  localizations.copyLink,
                  localizations.copyLinkDescription,
                  Icons.looks_two,
                  const Color(0xFF34A853),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  localizations.pasteAndDownload,
                  localizations.pasteAndDownloadDescription,
                  Icons.looks_3,
                  const Color(0xFF0066ff),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipsSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066ff).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066ff).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Color(0xFF0066ff),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.proTips,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipRow('🎯', localizations.watchVideosYouLike),
          const SizedBox(height: 12),
          _buildTipRow('📱', localizations.tipStableInternet),
          const SizedBox(height: 12),
          _buildTipRow('💾', localizations.tipSavedVideos),
        ],
      ),
    );
  }

  Widget _buildTipRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  
}
