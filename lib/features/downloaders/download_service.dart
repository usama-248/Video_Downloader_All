// // ignore_for_file: unused_import

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';

// import '../../core/utils.dart';
// import '../permissions/permission_service.dart';

// class DownloadService {
//   static Future<String?> downloadVideo(
//     String url,
//     Function(double)? onProgress,
//   ) async {
//     try {
//       // Permission
//       bool granted = await PermissionService.requestStoragePermission();
//       if (!granted) return null;

//       // Directory
//       final dir = await getTemporaryDirectory();

//       // File
//       final fileName = Utils.generateFileName();
//       final filePath = "${dir.path}/$fileName";

//       // Download
//       await Dio().download(
//         url,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1 && onProgress != null) {
//             double progress = received / total;
//             onProgress(progress);
//           }
//         },
//       );

//       // Save to gallery
//       await GallerySaver.saveVideo(filePath);

//       return filePath;
//     } catch (e) {
//       print("Download error: $e");
//       return null;
//     }
//   }
// }

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';

// class DownloadService {
//   static Future<String?> downloadVideo(
//     String url,
//     Function(double) onProgress,
//   ) async {
//     try {
//       final dir = await getTemporaryDirectory();
//       final filePath = "${dir.path}/video.mp4";

//       await Dio().download(
//         url,
//         filePath,
//         onReceiveProgress: (rec, total) {
//           if (total != -1) {
//             onProgress(rec / total);
//           }
//         },
//       );

//       await GallerySaver.saveVideo(filePath);

//       return filePath;
//     } catch (e) {
//       print("Download error: $e");
//       return null;
//     }
//   }
// }

//workingggggggggggggggggggggggggggggggggggggggggggggg  database
// import 'dart:io';
// import 'dart:math';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/foundation.dart';

// class DownloadService {
//   final Dio _dio = Dio();

//   Future<String?> downloadVideo({
//     required String url,
//     required String fileName,
//     Function(int received, int total)? onProgress,
//   }) async {
//     try {
//       debugPrint('📥 Starting download: $url');

//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           debugPrint('❌ Storage permission denied');
//           return null;
//         }
//       }

//       String savePath;
//       if (Platform.isAndroid) {
//         final moviesDir = Directory('/storage/emulated/0/Movies');
//         if (await moviesDir.exists()) {
//           savePath = '${moviesDir.path}/$fileName';
//         } else {
//           final downloadsDir = Directory('/storage/emulated/0/Download');
//           savePath = '${downloadsDir.path}/$fileName';
//         }
//       } else {
//         final directory = await getApplicationDocumentsDirectory();
//         savePath = '${directory.path}/$fileName';
//       }

//       debugPrint('💾 Saving to: $savePath');

//       await _dio.download(
//         url,
//         savePath,
//         onReceiveProgress: onProgress,
//         options: Options(
//           headers: {
//             'User-Agent':
//                 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
//             'Accept': '*/*',
//           },
//         ),
//       );

//       final file = File(savePath);
//       if (await file.exists()) {
//         final size = await file.length();
//         debugPrint('✅ Download complete: ${_formatFileSize(size)}');
//         return savePath;
//       }

//       return null;
//     } catch (e) {
//       debugPrint('❌ Download error: $e');
//       return null;
//     }
//   }

//   String _formatFileSize(int bytes) {
//     if (bytes <= 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB'];
//     var i = (bytes / 1024).floor();
//     return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
//   }

//   Future<bool> deleteVideo(String filePath) async {
//     try {
//       final file = File(filePath);
//       if (await file.exists()) {
//         await file.delete();
//         debugPrint('🗑️ Deleted: $filePath');
//         return true;
//       }
//       return false;
//     } catch (e) {
//       debugPrint('❌ Delete error: $e');
//       return false;
//     }
//   }de
// }

//working gallery
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String?> downloadVideo({
    required String url,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      debugPrint('📥 Starting download: $url');

      // Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          debugPrint('❌ Storage permission denied');
          return null;
        }
      }

      // Create app folder in Pictures directory
      String savePath;
      if (Platform.isAndroid) {
        final appFolder = Directory(
          '/storage/emulated/0/Pictures/VideoDownloaderApp',
        );
        if (!await appFolder.exists()) {
          await appFolder.create(recursive: true);
          debugPrint('📁 Created folder: ${appFolder.path}');
        }
        savePath = '${appFolder.path}/$fileName';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }

      debugPrint('💾 Saving to: $savePath');

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': '*/*',
          },
        ),
      );

      final file = File(savePath);
      if (await file.exists()) {
        final size = await file.length();
        debugPrint('✅ Download complete: ${_formatFileSize(size)}');
        debugPrint('📍 Video saved to: $savePath');

        // Try to notify gallery (this works inside the app)
        await _notifyGallery(savePath);

        return savePath;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }

  Future<void> _notifyGallery(String filePath) async {
    try {
      // This tries to tell Android to scan the file
      // It may fail on some devices but the file is still saved
      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath',
      ]);
      debugPrint('📸 Gallery notification sent');
    } catch (e) {
      // If this fails, the file is still saved correctly
      debugPrint('⚠️ Could not notify gallery, but file is saved');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes / 1024).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<bool> deleteVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return false;
    }
  }
}
