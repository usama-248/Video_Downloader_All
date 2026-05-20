import 'package:facebook_video_downloader/controllers/quality_selector_controller.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils.dart';

class QualitySelector extends StatelessWidget {
  final String videoUrl;
  final Function(String quality, String videoUrl) onDownload;
  
  const QualitySelector({
    Key? key,
    required this.videoUrl,
    required this.onDownload,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // Initialize controller with parameters
    Get.put(QualitySelectorController(
      videoUrl: videoUrl,
      onDownload: onDownload,
    ));
    
    return GetBuilder<QualitySelectorController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.selectVideoQuality,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              ...controller.qualities.entries.map((entry) {
                return Obx(() => RadioListTile<String>(
                  title: Text(entry.value.label),
                  subtitle: Text(Utils.formatFileSize(entry.value.size)),
                  value: entry.key,
                  groupValue: controller.selectedQuality.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectQuality(value);
                    }
                  },
                ));
              }),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: controller.download,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(localizations.downloadNow),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}