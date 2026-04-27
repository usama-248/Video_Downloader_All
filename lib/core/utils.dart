



import 'dart:io';
import 'dart:math';
import 'package:facebook_video_downloader/core/constants.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<String> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    final directory = await getDownloadsDirectory();
    return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    String fileName = path.split('/').last;
    if (!fileName.contains('.')) {
      fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    }
    return fileName;
  }

  static bool isVideoUrl(String url) {
    String lowerUrl = url.toLowerCase();
    return Constants.videoExtensions.any((ext) => lowerUrl.contains(ext));
  }
}