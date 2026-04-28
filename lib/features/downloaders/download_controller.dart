// import 'package:flutter/material.dart';
// import 'download_service.dart';
// import '../../core/constants.dart';

// class DownloadController extends ChangeNotifier {
//   bool isDownloading = false;
//   double progress = 0.0;
//   String message = "";

//   Future<void> startDownload(String url, BuildContext context) async {
//     isDownloading = true;
//     progress = 0;
//     message = AppConstants.downloadStarted;
//     notifyListeners();

//     final result = await DownloadService.downloadVideo(
//       url,
//       (p) {
//         progress = p;
//         notifyListeners();
//       },
//     );

//     isDownloading = false;

//     if (result != null) {
//       message = AppConstants.downloadComplete;
//       _showSnack(context, message);
//     } else {
//       message = AppConstants.downloadFailed;
//       _showSnack(context, message);
//     }

//     notifyListeners();
//   }

//   void _showSnack(BuildContext context, String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'download_service.dart';

// class DownloadController extends ChangeNotifier {
//   bool isDownloading = false;
//   double progress = 0;

//   Future<void> startDownload(String url, BuildContext context) async {
//     isDownloading = true;
//     progress = 0;
//     notifyListeners();

//     final result = await DownloadService.downloadVideo(
//       url,
//       (p) {
//         progress = p;
//         notifyListeners();
//       },
//     );

//     isDownloading = false;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           result != null ? "Download Complete" : "Download Failed",
//         ),
//       ),
//     );

//     notifyListeners();
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'download_service.dart';

// class DownloadController extends ChangeNotifier {
//   final DownloadService _downloadService = DownloadService();

//   List<DownloadTask> _activeDownloads = [];
//   VideoInfo? _currentVideoInfo;
//   bool _isExtracting = false;
//   String? _error;
//   DownloadQuality? _selectedQuality;

//   List<DownloadTask> get activeDownloads => _activeDownloads;
//   VideoInfo? get currentVideoInfo => _currentVideoInfo;
//   bool get isExtracting => _isExtracting;
//   String? get error => _error;
//   DownloadQuality? get selectedQuality => _selectedQuality;

//   Future<void> extractVideoInfo(String url) async {
//     _isExtracting = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _currentVideoInfo = await _downloadService.extractVideoInfo(url);
//       if (_currentVideoInfo != null && _currentVideoInfo!.qualities.isNotEmpty) {
//         _selectedQuality = DownloadQuality(
//           quality: _currentVideoInfo!.qualities.first.quality,
//           url: _currentVideoInfo!.qualities.first.url,
//           size: _currentVideoInfo!.qualities.first.size,
//         );
//       }
//     } catch (e) {
//       _error = 'Failed to extract video info: $e';
//     } finally {
//       _isExtracting = false;
//       notifyListeners();
//     }
//   }

//   void selectQuality(DownloadQuality quality) {
//     _selectedQuality = quality;
//     notifyListeners();
//   }

//   Future<void> startDownload({
//     required String url,
//     required String quality,
//     required String fileName,
//     required String title,
//   }) async {
//     try {
//       final task = DownloadTask(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         url: url,
//         fileName: fileName,
//         title: title,
//         quality: quality,
//         progress: 0.0,
//         status: DownloadTaskStatus.downloading,
//         downloadedBytes: 0,
//         totalBytes: 0,
//         speed: 0,
//       );

//       _activeDownloads.add(task);
//       notifyListeners();

//       await _downloadService.downloadVideoWithQuality(
//         videoUrl: url,
//         quality: quality,
//         fileName: fileName,
//         onProgress: (received, total) {
//           final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//           if (index != -1) {
//             _activeDownloads[index].progress = received / total;
//             _activeDownloads[index].downloadedBytes = received;
//             _activeDownloads[index].totalBytes = total;
//             _activeDownloads[index].speed = _calculateSpeed(received, total);
//             notifyListeners();
//           }
//         },
//       );

//       final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         _activeDownloads[index].status = DownloadTaskStatus.completed;
//         _activeDownloads[index].progress = 1.0;
//         notifyListeners();
//       }
//     } catch (e) {
//       final index = _activeDownloads.indexWhere((t) => t.url == url);
//       if (index != -1) {
//         _activeDownloads[index].status = DownloadTaskStatus.failed;
//         _activeDownloads[index].error = e.toString();
//         notifyListeners();
//       }
//     }
//   }

//   double _calculateSpeed(int received, int total) {
//     // Simplified speed calculation
//     return received / (DateTime.now().millisecondsSinceEpoch / 1000);
//   }

//   void cancelDownload(String taskId) {
//     _activeDownloads.removeWhere((task) => task.id == taskId);
//     notifyListeners();
//   }

//   void clearCompletedDownloads() {
//     _activeDownloads.removeWhere((task) =>
//       task.status == DownloadTaskStatus.completed ||
//       task.status == DownloadTaskStatus.failed
//     );
//     notifyListeners();
//   }
// }

// class DownloadTask {
//   final String id;
//   final String url;
//   final String fileName;
//   final String title;
//   final String quality;
//   double progress;
//   DownloadTaskStatus status;
//   int downloadedBytes;
//   int totalBytes;
//   double speed;
//   String? error;

//   DownloadTask({
//     required this.id,
//     required this.url,
//     required this.fileName,
//     required this.title,
//     required this.quality,
//     required this.progress,
//     required this.status,
//     required this.downloadedBytes,
//     required this.totalBytes,
//     required this.speed,
//     this.error,
//   });
// }

// enum DownloadTaskStatus {
//   pending,
//   downloading,
//   paused,
//   completed,
//   failed,
// }

// class DownloadQuality {
//   final String quality;
//   final String url;
//   final int size;

//   DownloadQuality({
//     required this.quality,
//     required this.url,
//     required this.size,
//   });
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'download_service.dart';
// import 'dart:io';

// class DownloadController extends ChangeNotifier {
//   final DownloadService _downloadService = DownloadService();

//   List<DownloadTask> _activeDownloads = [];
//   List<DownloadTask> _downloadHistory = [];

//   List<DownloadTask> get activeDownloads => _activeDownloads;
//   List<DownloadTask> get downloadHistory => _downloadHistory;

//   Future<void> startDownload({
//     required String url,
//     required String quality,
//     required String fileName,
//     required String title,
//   }) async {
//     // Check if already downloading
//     if (_activeDownloads.any((task) => task.url == url)) {
//       debugPrint('Already downloading this video');
//       return;
//     }

//     final task = DownloadTask(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       url: url,
//       fileName: fileName,
//       title: title,
//       quality: quality,
//       progress: 0.0,
//       status: DownloadTaskStatus.downloading,
//       downloadedBytes: 0,
//       totalBytes: 0,
//       speed: 0,
//       filePath: null,
//     );

//     _activeDownloads.add(task);
//     notifyListeners();

//     try {
//       bool success = await _downloadService.downloadVideo(
//         url: url,
//         fileName: fileName,
//         onProgress: (received, total) {
//           final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//           if (index != -1) {
//             _activeDownloads[index].progress = received / total;
//             _activeDownloads[index].downloadedBytes = received;
//             _activeDownloads[index].totalBytes = total;
//             notifyListeners();
//           }
//         },
//       );

//       final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         if (success) {
//           _activeDownloads[index].status = DownloadTaskStatus.completed;
//           _activeDownloads[index].progress = 1.0;
//           _activeDownloads[index].filePath = await _downloadService.getDownloadedFilePath(fileName);

//           // Move to history
//           final completedTask = _activeDownloads[index];
//           _downloadHistory.insert(0, completedTask);
//           _activeDownloads.removeAt(index);
//           debugPrint('Download completed successfully: ${completedTask.filePath}');
//         } else {
//           _activeDownloads[index].status = DownloadTaskStatus.failed;
//           _activeDownloads[index].error = 'Download failed - Video URL might be protected';
//         }
//         notifyListeners();
//       }
//     } catch (e) {
//       final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         _activeDownloads[index].status = DownloadTaskStatus.failed;
//         _activeDownloads[index].error = e.toString();
//         notifyListeners();
//       }
//     }
//   }

//   void cancelDownload(String taskId) {
//     _activeDownloads.removeWhere((task) => task.id == taskId);
//     notifyListeners();
//   }

//   void clearHistory() {
//     _downloadHistory.clear();
//     notifyListeners();
//   }

//   Future<void> deleteDownloadedFile(DownloadTask task) async {
//     if (task.filePath != null) {
//       final deleted = await _downloadService.deleteDownloadedFile(task.filePath!);
//       if (deleted) {
//         _downloadHistory.removeWhere((t) => t.id == task.id);
//         notifyListeners();
//       }
//     }
//   }

//   void retryDownload(DownloadTask failedTask) async {
//     // Remove failed task
//     _downloadHistory.removeWhere((t) => t.id == failedTask.id);
//     notifyListeners();

//     // Restart download
//     await startDownload(
//       url: failedTask.url,
//       quality: failedTask.quality,
//       fileName: failedTask.fileName,
//       title: failedTask.title,
//     );
//   }
// }

// class DownloadTask {
//   final String id;
//   final String url;
//   final String fileName;
//   final String title;
//   final String quality;
//   double progress;
//   DownloadTaskStatus status;
//   int downloadedBytes;
//   int totalBytes;
//   double speed;
//   String? error;
//   String? filePath;

//   DownloadTask({
//     required this.id,
//     required this.url,
//     required this.fileName,
//     required this.title,
//     required this.quality,
//     required this.progress,
//     required this.status,
//     required this.downloadedBytes,
//     required this.totalBytes,
//     required this.speed,
//     this.error,
//     this.filePath,
//   });
// }

// enum DownloadTaskStatus {
//   pending,
//   downloading,
//   paused,
//   completed,
//   failed,
// }

// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'download_service.dart';
// import '../../core/database_helper.dart';
// import 'dart:io';

// class DownloadController extends ChangeNotifier {
//   final DownloadService _downloadService = DownloadService();
//   final DatabaseHelper _dbHelper = DatabaseHelper();

//   List<DownloadTask> _activeDownloads = [];
//   List<DownloadHistoryItem> _downloadHistory = [];

//   List<DownloadTask> get activeDownloads => _activeDownloads;
//   List<DownloadHistoryItem> get downloadHistory => _downloadHistory;

//   DownloadController() {
//     _loadHistory();
//   }

//   Future<void> _loadHistory() async {
//     final history = await _dbHelper.getDownloads();
//     _downloadHistory = history.map((item) => DownloadHistoryItem.fromMap(item)).toList();
//     notifyListeners();
//   }

//   Future<void> startDownload({
//     required String url,
//     required String quality,
//     required String fileName,
//     required String title,
//   }) async {
//     final task = DownloadTask(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       url: url,
//       fileName: fileName,
//       title: title,
//       quality: quality,
//       progress: 0.0,
//       status: DownloadTaskStatus.downloading,
//       downloadedBytes: 0,
//       totalBytes: 0,
//     );

//     _activeDownloads.add(task);
//     notifyListeners();

//     try {
//       bool success = await _downloadService.downloadVideo(
//         url: url,
//         fileName: fileName,
//         onProgress: (received, total) {
//           final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//           if (index != -1) {
//             _activeDownloads[index].progress = received / total;
//             _activeDownloads[index].downloadedBytes = received;
//             _activeDownloads[index].totalBytes = total;
//             notifyListeners();
//           }
//         },
//         onComplete: (savedPath) async {
//           // Save to database
//           await _dbHelper.insertDownload({
//             'fileName': fileName,
//             'filePath': savedPath,
//             'videoUrl': url,
//             'quality': quality,
//             'size': _formatFileSize(task.totalBytes),
//             'dateTime': DateTime.now().toIso8601String(),
//             'thumbnail': '',
//           });

//           await _loadHistory();

//           final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//           if (index != -1) {
//             _activeDownloads.removeAt(index);
//             notifyListeners();
//           }
//         },
//       );

//       if (!success) {
//         final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//         if (index != -1) {
//           _activeDownloads[index].status = DownloadTaskStatus.failed;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       final index = _activeDownloads.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         _activeDownloads[index].status = DownloadTaskStatus.failed;
//         notifyListeners();
//       }
//     }
//   }

//   String _formatFileSize(int bytes) {
//     if (bytes <= 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB'];
//     var i = (bytes.log / 1024.log).floor();
//     return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
//   }

//   void cancelDownload(String taskId) {
//     _activeDownloads.removeWhere((task) => task.id == taskId);
//     notifyListeners();
//   }

//   Future<void> deleteHistoryItem(int id, String filePath) async {
//     try {
//       final file = File(filePath);
//       if (await file.exists()) {
//         await file.delete();
//       }
//       await _dbHelper.deleteDownload(id);
//       await _loadHistory();
//     } catch (e) {
//       debugPrint('Delete error: $e');
//     }
//   }

//   Future<void> clearAllHistory() async {
//     for (var item in _downloadHistory) {
//       final file = File(item.filePath);
//       if (await file.exists()) {
//         await file.delete();
//       }
//     }
//     await _dbHelper.deleteAllDownloads();
//     await _loadHistory();
//   }
// }

// extension on int {
//   get log => null;
// }

// class DownloadTask {
//   final String id;
//   final String url;
//   final String fileName;
//   final String title;
//   final String quality;
//   double progress;
//   DownloadTaskStatus status;
//   int downloadedBytes;
//   int totalBytes;

//   DownloadTask({
//     required this.id,
//     required this.url,
//     required this.fileName,
//     required this.title,
//     required this.quality,
//     required this.progress,
//     required this.status,
//     required this.downloadedBytes,
//     required this.totalBytes,
//   });
// }

// class DownloadHistoryItem {
//   final int id;
//   final String fileName;
//   final String filePath;
//   final String videoUrl;
//   final String quality;
//   final String size;
//   final DateTime dateTime;
//   final String thumbnail;

//   DownloadHistoryItem({
//     required this.id,
//     required this.fileName,
//     required this.filePath,
//     required this.videoUrl,
//     required this.quality,
//     required this.size,
//     required this.dateTime,
//     required this.thumbnail,
//   });

//   factory DownloadHistoryItem.fromMap(Map<String, dynamic> map) {
//     return DownloadHistoryItem(
//       id: map['id'],
//       fileName: map['fileName'],
//       filePath: map['filePath'],
//       videoUrl: map['videoUrl'],
//       quality: map['quality'],
//       size: map['size'],
//       dateTime: DateTime.parse(map['dateTime']),
//       thumbnail: map['thumbnail'] ?? '',
//     );
//   }
// }

// enum DownloadTaskStatus {
//   pending,
//   downloading,
//   completed,
//   failed,
// }






// //all working

import 'dart:math';
import 'package:flutter/material.dart';
import 'download_service.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DownloadController extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  Database? _database;

  List<DownloadTask> _activeDownloads = [];
  List<Map<String, dynamic>> _downloadHistory = [];

  List<DownloadTask> get activeDownloads => _activeDownloads;
  List<Map<String, dynamic>> get downloadHistory => _downloadHistory;

  DownloadController() {
    _initDatabase();
    loadHistory();
  }

  Future<void> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'video_downloads.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute('''
            CREATE TABLE downloads(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fileName TEXT,
              filePath TEXT,
              videoUrl TEXT,
              quality TEXT,
              fileSize TEXT,
              dateTime TEXT
            )
          ''');
        },
      );
      debugPrint('✅ Database initialized');
    } catch (e) {
      debugPrint('❌ Database error: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      if (_database == null) return;
      final List<Map<String, dynamic>> results = await _database!.query(
        'downloads',
        orderBy: 'dateTime DESC',
      );
      _downloadHistory = results;
      notifyListeners();
      debugPrint('📚 Loaded ${results.length} history items');
    } catch (e) {
      debugPrint('❌ Load history error: $e');
    }
  }

  Future<void> startDownload({
    required String url,
    required String quality,
    required String fileName,
  }) async {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    final task = DownloadTask(
      id: taskId,
      url: url,
      fileName: fileName,
      quality: quality,
      progress: 0.0,
      status: DownloadStatus.downloading,
    );

    _activeDownloads.add(task);
    notifyListeners();

    debugPrint('🚀 Starting download: $fileName');

    final savedPath = await _downloadService.downloadVideo(
      url: url,
      fileName: fileName,
      onProgress: (received, total) {
        final index = _activeDownloads.indexWhere((t) => t.id == taskId);
        if (index != -1 && total > 0) {
          _activeDownloads[index].progress = received / total;
          notifyListeners();
        }
      },
    );

    if (savedPath != null && _database != null) {
      final file = File(savedPath);
      final fileSize = await file.length();
      final sizeStr = _formatFileSize(fileSize);

      await _database!.insert('downloads', {
        'fileName': fileName,
        'filePath': savedPath,
        'videoUrl': url,
        'quality': quality,
        'fileSize': sizeStr,
        'dateTime': DateTime.now().toIso8601String(),
      });

      await loadHistory();

      _activeDownloads.removeWhere((t) => t.id == taskId);
      notifyListeners();

      debugPrint('✅ Download saved to history: $fileName');
    } else {
      final index = _activeDownloads.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _activeDownloads[index].status = DownloadStatus.failed;
        notifyListeners();
      }
      debugPrint('❌ Download failed: $fileName');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> deleteHistoryItem(int id, String filePath) async {
    try {
      await _downloadService.deleteVideo(filePath);
      if (_database != null) {
        await _database!.delete('downloads', where: 'id = ?', whereArgs: [id]);
      }
      await loadHistory();
      debugPrint('🗑️ Deleted history item: $id');
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      for (var item in _downloadHistory) {
        await _downloadService.deleteVideo(item['filePath']);
      }
      if (_database != null) {
        await _database!.delete('downloads');
      }
      await loadHistory();
      debugPrint('🗑️ Cleared all history');
    } catch (e) {
      debugPrint('❌ Clear history error: $e');
    }
  }

  // Add this method to add to history
  Future<void> addToHistory({
    required String fileName,
    required String filePath,
    required String videoUrl,
    required String quality,
  }) async {
    if (_database != null) {
      final sizeStr = await _getFileSize(filePath);
      await _database!.insert('downloads', {
        'fileName': fileName,
        'filePath': filePath,
        'videoUrl': videoUrl,
        'quality': quality,
        'fileSize': sizeStr,
        'dateTime': DateTime.now().toIso8601String(),
      });
      await loadHistory();
      debugPrint('✅ Added to history: $fileName');
    }
  }

  Future<String> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        return _formatFileSize(size);
      }
    } catch (e) {}
    return 'Unknown';
  }

  void cancelDownload(String taskId) {
    _activeDownloads.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
}

class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final String quality;
  double progress;
  DownloadStatus status;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.quality,
    required this.progress,
    required this.status,
  });
}

enum DownloadStatus { downloading, completed, failed } //filllllllllllllllllllllllllllyyyyyyyyyyyyyyyyyyy functional
