import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/controllers/home_controller.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const _BrowserScreen(),
            const _WatchScreenWithAd(),
            const HistoryScreen(),
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
              label: 'Home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/images/Watch_Video.png'),
                size: 24,
              ),
              label: 'Watch'.tr,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/images/FileSave.png'),
                size: 24,
              ),
              label: 'Saved'.tr,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Video Downloader'.tr,
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
              'premium'.tr,
            ),
          _buildIconButton(
            'assets/images/Facebookicon.png',
            () => controller.openInChrome('https://facebook.com'),
            'facebook'.tr,
          ),
          _buildIconButton(
            'assets/images/Settingicon.png',
            controller.goToSettings,
            'settings'.tr,
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
                _buildUrlInputSection(),
                const SizedBox(height: 20),
                Obx(
                  () => controller.showVideoPreview.value
                      ? _buildVideoPreview()
                      : _buildMrecAd(),
                ),
                const SizedBox(height: 16),
                _buildInstructionsSection(),
                const SizedBox(height: 16),
                _buildTipSection(),
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
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildUrlInputSection() {
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
                hintText: 'Paste your video link here'.tr,
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
                  onPressed: controller.pasteLink,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066ff),
                    side: const BorderSide(color: Color(0xFF0066ff)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Paste Link'.tr),
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
                          : controller.fetchVideo,
                      child: controller.isFetching.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Fetch Video'),
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

  Widget _buildMrecAd() {
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
                ? AdWidget(ad: controller.mrecAd!)
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
                        'Enter URL & tap Fetch Video',
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

  Widget _buildVideoPreview() {
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
                                      _defaultThumbnail(),
                                )
                              : _defaultThumbnail(),
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
                          controller.videoTitle ?? 'video'.tr,
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
                    onPressed: controller.navigateToWebView,
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('Download'.tr),
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

  Widget _defaultThumbnail() {
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
                'video_ready'.tr,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
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
            'How to Download'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Open app and copy video link'.tr),
          const SizedBox(height: 8),
          _buildStep(
            '2',
            'Paste the link in Fast Video Downloader and Fetch'.tr,
          ),
          const SizedBox(height: 8),
          _buildStep('3', 'Select download quality and start download'.tr),
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

  Widget _buildTipSection() {
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
                'Try videos.com for more'.tr,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Video Downloader'.tr,
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
              'premium'.tr,
            ),
          _buildIconButton(
            'assets/images/Facebookicon.png',
            controller.openFacebook,
            'facebook'.tr,
          ),
          _buildIconButton(
            'assets/images/Settingicon.png',
            controller.goToSettings,
            'settings'.tr,
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
                Obx(
                  () =>
                      controller.isWatchBannerLoaded.value &&
                          controller.watchBannerAd != null
                      ? Container(
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
                      _buildHeroSection(),
                      const SizedBox(height: 20),
                      _buildHowToSection(),
                      const SizedBox(height: 20),
                      _buildProTipsSection(),
                      const SizedBox(height: 20),
                      _buildHelpButton(),
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
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildHeroSection() {
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
              errorBuilder: (_, __, ___) => const Icon(
                Icons.play_circle_filled,
                size: 60,
                color: Color(0xFF0066ff),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Watch Videos'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap Below to Open'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.openFacebook,
              label: Text('Open App'.tr, style: const TextStyle(fontSize: 16)),
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

  Widget _buildHowToSection() {
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
                    'How to Download Videos'.tr,
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
                  'Find & Share',
                  'Watch videos which u like'.tr,
                  Icons.looks_one,
                  const Color(0xFF1877F2),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  'Copy Link',
                  'Select "Copy Link" from the share options',
                  Icons.looks_two,
                  const Color(0xFF34A853),
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  'Paste & Download',
                  'Paste the link in Fast Video Downloader Fetch and Download it'
                      .tr,
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

  Widget _buildProTipsSection() {
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
              const Expanded(
                child: Text(
                  'Pro Tips for Best Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipRow('🎯', 'Open app Choose Video which u like'.tr),
          const SizedBox(height: 12),
          _buildTipRow('📱', 'Make sure you have a stable internet connection'),
          const SizedBox(height: 12),
          _buildTipRow('💾', 'Saved videos are stored in your gallery'),
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

  Widget _buildHelpButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.showHelpGuide,
        icon: const Icon(Icons.support_agent, color: Colors.transparent),
        label: Text(
          'need_help'.tr,
          style: const TextStyle(fontSize: 14, color: Colors.transparent),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.transparent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
