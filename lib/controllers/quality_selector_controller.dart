import 'package:get/get.dart';

class QualitySelectorController extends GetxController {
  var selectedQuality = '720p'.obs;
  
  final String videoUrl;
  final Function(String quality, String videoUrl) onDownload;
  
  QualitySelectorController({
    required this.videoUrl,
    required this.onDownload,
  });
  
  final Map<String, VideoQualityData> qualities = {
    '1080p': VideoQualityData(label: '1080p', size: 50 * 1024 * 1024, urlSuffix: 'hd'),
    '720p': VideoQualityData(label: '720p', size: 30 * 1024 * 1024, urlSuffix: 'hd'),
    '480p': VideoQualityData(label: '480p', size: 20 * 1024 * 1024, urlSuffix: 'sd'),
    '360p': VideoQualityData(label: '360p', size: 10 * 1024 * 1024, urlSuffix: 'sd'),
  };
  
  void selectQuality(String quality) {
    selectedQuality.value = quality;
  }
  
  void download() {
    onDownload(selectedQuality.value, videoUrl);
    Get.back();
  }
}

class VideoQualityData {
  final String label;
  final int size;
  final String urlSuffix;
  
  VideoQualityData({
    required this.label,
    required this.size,
    required this.urlSuffix,
  });
}