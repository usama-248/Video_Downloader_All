import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:facebook_video_downloader/controllers/webview_controller.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebViewControllerr(url: url), tag: url);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066ff),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Video Downloader Browser',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () => controller.openInChrome(url),
            tooltip: 'Open in Browser',
          ),
          Obx(
            () =>
                controller.detectedVideoUrl.value != null &&
                    !controller.isDownloading.value
                ? Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () => controller.onDownloadTierSelected(
                          '720p',
                          '720p (HD)',
                          null,
                        ),
                        tooltip: 'Download Options',
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
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
            child: WebViewWidget(controller: controller.controller),
          ),
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: Colors.white.withOpacity(0.95),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0066ff),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading video player...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () =>
                controller.isVideoDetected.value &&
                    !controller.isDownloading.value &&
                    !controller.isLoading.value
                ? Positioned(
                    top: 60,
                    right: 10,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: GestureDetector(
                          onTap: () => controller.onDownloadTierSelected(
                            '720p',
                            '720p (HD)',
                            null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Video Detected! Tap to Download',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.isDownloading.value
                ? Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0066ff),
                                            Color(0xFF1f83ff),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.downloading,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller
                                                    .downloadQualityLabel
                                                    .value
                                                    .isNotEmpty
                                                ? controller
                                                      .downloadQualityLabel
                                                      .value
                                                : 'Downloading Video',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (controller
                                                      .selectedDownloadSize
                                                      .value !=
                                                  null &&
                                              controller
                                                  .selectedDownloadSize
                                                  .value!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '~ ${controller.selectedDownloadSize.value}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 2),
                                          Text(
                                            controller.downloadStatus.value,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    controller.totalKnown.value
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0066ff,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0066ff),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    const Color(
                                                      0xFF0066ff,
                                                    ).withOpacity(0.6),
                                                  ),
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.speed,
                                              size: 13,
                                              color: Colors.orange.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              controller.downloadSpeed.value,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      if (controller.totalKnown.value)
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          height: 10,
                                          width:
                                              controller
                                                  .downloadProgress
                                                  .value *
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0066ff),
                                                Color(0xFF00ccff),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF0066ff,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 10,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: _buildIndeterminateBar(),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Builder(
                                      builder: (ctx) {
                                        final Color tintBg;
                                        final Color tintFg;
                                        final IconData qIcon;
                                        if (controller.downloadIsAudio.value) {
                                          tintBg = Colors.green.shade50;
                                          tintFg = Colors.green.shade700;
                                          qIcon = Icons.audiotrack;
                                        } else if (controller
                                            .downloadProgressIsLowQuality
                                            .value) {
                                          tintBg = Colors.grey.shade100;
                                          tintFg = Colors.grey.shade800;
                                          qIcon = Icons.sd_storage;
                                        } else {
                                          tintBg = Colors.blue.shade50;
                                          tintFg = Colors.blue.shade700;
                                          qIcon = Icons.high_quality;
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: tintBg,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                qIcon,
                                                size: 12,
                                                color: tintFg.withOpacity(0.88),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                controller
                                                    .downloadQualityLabel
                                                    .value,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: tintFg,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Active',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndeterminateBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment(value.clamp(-1.0, 1.0), 0.0),
            widthFactor: 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066ff), Color(0xFF00ccff)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
