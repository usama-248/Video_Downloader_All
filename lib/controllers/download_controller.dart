// import 'dart:math';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// import '../features/downloaders/download_service.dart';

// class DownloadController extends ChangeNotifier {
//   final DownloadService _downloadService = DownloadService();

//   Database? _database;

//   // IMPORTANT FIX
//   bool _isDatabaseReady = false;

//   List<DownloadTask> _activeDownloads = [];
//   List<Map<String, dynamic>> _downloadHistory = [];

//   List<DownloadTask> get activeDownloads => _activeDownloads;

//   List<Map<String, dynamic>> get downloadHistory => _downloadHistory;

//   DownloadController() {
//     _initialize();
//   }

//   // INITIALIZE DATABASE + HISTORY
//   Future<void> _initialize() async {
//     await _initDatabase();
//     await loadHistory();
//   }

//   // DATABASE INITIALIZATION
//   Future<void> _initDatabase() async {
//     try {
//       String path = join(await getDatabasesPath(), 'video_downloads.db');

//       _database = await openDatabase(
//         path,
//         version: 3, // Increment version for estimated size column
//         onCreate: (db, version) async {
//           await db.execute('''
//             CREATE TABLE downloads(
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               fileName TEXT,
//               filePath TEXT,
//               videoUrl TEXT,
//               quality TEXT,
//               fileSize TEXT,
//               actualFileSize INTEGER,
//               estimatedSize TEXT,
//               dateTime TEXT
//             )
//           ''');
//         },
//         onUpgrade: (db, oldVersion, newVersion) async {
//           if (oldVersion < 2) {
//             try {
//               await db.execute(
//                 'ALTER TABLE downloads ADD COLUMN actualFileSize INTEGER',
//               );
//             } catch (e) {
//               debugPrint('Migration error (actualFileSize): $e');
//             }
//           }
//           if (oldVersion < 3) {
//             try {
//               await db.execute(
//                 'ALTER TABLE downloads ADD COLUMN estimatedSize TEXT',
//               );
//             } catch (e) {
//               debugPrint('Migration error (estimatedSize): $e');
//             }
//           }
//         },
//       );

//       _isDatabaseReady = true;
//       debugPrint('✅ Database initialized');
//     } catch (e) {
//       debugPrint('❌ Database error: $e');
//     }
//   }

//   // WAIT UNTIL DATABASE READY
//   Future<void> _waitForDatabase() async {
//     while (!_isDatabaseReady) {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   // LOAD HISTORY
//   Future<void> loadHistory() async {
//     try {
//       await _waitForDatabase();

//       final List<Map<String, dynamic>> results = await _database!.query(
//         'downloads',
//         orderBy: 'dateTime DESC',
//       );

//       _downloadHistory = results;
//       notifyListeners();
//       debugPrint('📚 Loaded ${results.length} history items');
//     } catch (e) {
//       debugPrint('❌ Load history error: $e');
//     }
//   }

//   // START DOWNLOAD
//   Future<void> startDownload({
//     required String url,
//     required String quality,
//     required String fileName,
//     String? estimatedSize, // Add estimated size parameter
//   }) async {
//     await _waitForDatabase();

//     final taskId = DateTime.now().millisecondsSinceEpoch.toString();

//     final task = DownloadTask(
//       id: taskId,
//       url: url,
//       fileName: fileName,
//       quality: quality,
//       progress: 0.0,
//       status: DownloadStatus.downloading,
//     );

//     _activeDownloads.add(task);
//     notifyListeners();

//     debugPrint(
//       '🚀 Starting download: $fileName (Estimated size: $estimatedSize)',
//     );

//     final savedPath = await _downloadService.downloadVideo(
//       url: url,
//       fileName: fileName,
//       onProgress: (received, total) {
//         final index = _activeDownloads.indexWhere((t) => t.id == taskId);
//         if (index != -1 && total > 0) {
//           _activeDownloads[index].progress = received / total;
//           notifyListeners();
//         }
//       },
//     );

//     // DOWNLOAD SUCCESS
//     if (savedPath != null) {
//       try {
//         final file = File(savedPath);
//         final actualFileSizeBytes = await file.length();
//         final actualSizeStr = _formatFileSize(actualFileSizeBytes);

//         // Use estimated size if provided, otherwise use actual size
//         final displaySizeStr = estimatedSize ?? actualSizeStr;

//         // SAVE TO DATABASE WITH ACTUAL SIZE AND ESTIMATED SIZE
//         await _database!.insert('downloads', {
//           'fileName': fileName,
//           'filePath': savedPath,
//           'videoUrl': url,
//           'quality': quality,
//           'fileSize':
//               displaySizeStr, // This is the size shown in history (estimated or actual)
//           'actualFileSize': actualFileSizeBytes,
//           'estimatedSize':
//               estimatedSize, // Store the estimated size from options
//           'dateTime': DateTime.now().toIso8601String(),
//         });

//         // RELOAD HISTORY IMMEDIATELY
//         await loadHistory();

//         // REMOVE ACTIVE DOWNLOAD
//         _activeDownloads.removeWhere((t) => t.id == taskId);
//         notifyListeners();

//         debugPrint(
//           '✅ Download saved to history: $fileName (Display size: $displaySizeStr, Actual: $actualSizeStr)',
//         );
//       } catch (e) {
//         debugPrint('❌ Save history error: $e');
//       }
//     } else {
//       // DOWNLOAD FAILED
//       final index = _activeDownloads.indexWhere((t) => t.id == taskId);
//       if (index != -1) {
//         _activeDownloads[index].status = DownloadStatus.failed;
//         notifyListeners();
//       }
//       debugPrint('❌ Download failed: $fileName');
//     }
//   }

//   // DELETE SINGLE ITEM
//   Future<void> deleteHistoryItem(int id, String filePath) async {
//     try {
//       await _downloadService.deleteVideo(filePath);
//       await _database!.delete('downloads', where: 'id = ?', whereArgs: [id]);
//       await loadHistory();
//       debugPrint('🗑️ Deleted history item: $id');
//     } catch (e) {
//       debugPrint('❌ Delete error: $e');
//     }
//   }

//   // CLEAR ALL HISTORY
//   Future<void> clearAllHistory() async {
//     try {
//       for (var item in _downloadHistory) {
//         await _downloadService.deleteVideo(item['filePath']);
//       }
//       await _database!.delete('downloads');
//       await loadHistory();
//       debugPrint('🗑️ Cleared all history');
//     } catch (e) {
//       debugPrint('❌ Clear history error: $e');
//     }
//   }

//   // MANUAL ADD TO HISTORY WITH ACTUAL FILE SIZE AND ESTIMATED SIZE
//   Future<void> addToHistory({
//     required String fileName,
//     required String filePath,
//     required String videoUrl,
//     required String quality,
//     String? estimatedSize, // Estimated size from download options
//     int? actualFileSizeBytes, // Actual file size after download
//   }) async {
//     try {
//       await _waitForDatabase();

//       String displaySizeStr;
//       int actualSize;
//       String? estimatedSizeStr = estimatedSize;

//       if (actualFileSizeBytes != null && actualFileSizeBytes > 0) {
//         actualSize = actualFileSizeBytes;
//         final actualSizeFormatted = _formatFileSize(actualFileSizeBytes);

//         // Use estimated size if provided, otherwise use actual size
//         displaySizeStr = estimatedSize ?? actualSizeFormatted;
//       } else {
//         // Fallback: get size from file
//         final file = File(filePath);
//         if (await file.exists()) {
//           actualSize = await file.length();
//           final actualSizeFormatted = _formatFileSize(actualSize);
//           displaySizeStr = estimatedSize ?? actualSizeFormatted;
//         } else {
//           actualSize = 0;
//           displaySizeStr = estimatedSize ?? 'Unknown';
//         }
//       }

//       await _database!.insert('downloads', {
//         'fileName': fileName,
//         'filePath': filePath,
//         'videoUrl': videoUrl,
//         'quality': quality,
//         'fileSize': displaySizeStr, // This is what shows in history list
//         'actualFileSize': actualSize,
//         'estimatedSize': estimatedSizeStr,
//         'dateTime': DateTime.now().toIso8601String(),
//       });

//       await loadHistory();
//       notifyListeners();
//       debugPrint(
//         '✅ Added to history: $fileName (Display: $displaySizeStr, Estimated: $estimatedSize, Actual: ${_formatFileSize(actualSize)})',
//       );
//     } catch (e) {
//       debugPrint('❌ Add history error: $e');
//     }
//   }

//   // UPDATE HISTORY ITEM WITH ACTUAL SIZE (for backward compatibility)
//   Future<void> updateHistoryWithActualSize(
//     int id,
//     int actualFileSizeBytes, {
//     String? estimatedSize,
//   }) async {
//     try {
//       await _waitForDatabase();

//       final actualSizeStr = _formatFileSize(actualFileSizeBytes);

//       // If estimated size exists and we want to keep it as display, keep it
//       // Otherwise use actual size as display
//       Map<String, dynamic> updateData = {'actualFileSize': actualFileSizeBytes};

//       // If no estimated size was stored, update fileSize to actual size
//       if (estimatedSize == null) {
//         updateData['fileSize'] = actualSizeStr;
//       }

//       await _database!.update(
//         'downloads',
//         updateData,
//         where: 'id = ?',
//         whereArgs: [id],
//       );

//       await loadHistory();
//       debugPrint('✅ Updated history item $id with actual size: $actualSizeStr');
//     } catch (e) {
//       debugPrint('❌ Update history error: $e');
//     }
//   }

//   // GET FILE SIZE FROM STORAGE
//   Future<String> getFileSize(String filePath) async {
//     try {
//       final file = File(filePath);
//       if (await file.exists()) {
//         final size = await file.length();
//         return _formatFileSize(size);
//       }
//     } catch (e) {
//       debugPrint('❌ File size error: $e');
//     }
//     return 'Unknown';
//   }

//   // GET DISPLAY SIZE FOR HISTORY ITEM
//   String getDisplaySizeForHistoryItem(Map<String, dynamic> item) {
//     // If there's an estimated size and it's different from actual, show both
//     final estimatedSize = item['estimatedSize'] as String?;
//     final actualFileSize = item['actualFileSize'] as int?;

//     if (estimatedSize != null && actualFileSize != null) {
//       final actualSizeStr = _formatFileSize(actualFileSize);
//       if (estimatedSize != actualSizeStr) {
//         return '$estimatedSize (Actual: $actualSizeStr)';
//       }
//       return estimatedSize;
//     }

//     // Fallback to stored fileSize
//     return item['fileSize'] as String? ?? 'Unknown';
//   }

//   // FORMAT SIZE
//   String _formatFileSize(int bytes) {
//     if (bytes <= 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB'];
//     var i = (log(bytes) / log(1024)).floor();
//     return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
//   }

//   // CANCEL DOWNLOAD
//   void cancelDownload(String taskId) {
//     _activeDownloads.removeWhere((task) => task.id == taskId);
//     notifyListeners();
//   }
// }

// // DOWNLOAD TASK MODEL
// class DownloadTask {
//   final String id;
//   final String url;
//   final String fileName;
//   final String quality;
//   double progress;
//   DownloadStatus status;

//   DownloadTask({
//     required this.id,
//     required this.url,
//     required this.fileName,
//     required this.quality,
//     required this.progress,
//     required this.status,
//   });
// }

// // DOWNLOAD STATUS
// enum DownloadStatus { downloading, completed, failed }

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../features/downloaders/download_service.dart';

class DownloadController extends GetxController {
  final DownloadService _downloadService = DownloadService();

  Database? _database;

  // DATABASE READY
  final RxBool isDatabaseReady = false.obs;

  // ACTIVE DOWNLOADS
  final RxList<DownloadTask> activeDownloads = <DownloadTask>[].obs;

  // DOWNLOAD HISTORY
  final RxList<Map<String, dynamic>> downloadHistory =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  // INITIALIZE
  Future<void> _initialize() async {
    await _initDatabase();
    await loadHistory();
  }

  // INIT DATABASE
  Future<void> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'video_downloads.db');

      _database = await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE downloads(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fileName TEXT,
            filePath TEXT,
            videoUrl TEXT,
            quality TEXT,
            fileSize TEXT,
            actualFileSize INTEGER,
            estimatedSize TEXT,
            dateTime TEXT
          )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            try {
              await db.execute(
                'ALTER TABLE downloads ADD COLUMN actualFileSize INTEGER',
              );
            } catch (e) {
              debugPrint('Migration error actualFileSize: $e');
            }
          }

          if (oldVersion < 3) {
            try {
              await db.execute(
                'ALTER TABLE downloads ADD COLUMN estimatedSize TEXT',
              );
            } catch (e) {
              debugPrint('Migration error estimatedSize: $e');
            }
          }
        },
      );

      isDatabaseReady.value = true;

      debugPrint('✅ Database initialized');
    } catch (e) {
      debugPrint('❌ Database error: $e');
    }
  }

  // WAIT DATABASE
  Future<void> _waitForDatabase() async {
    while (!isDatabaseReady.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // LOAD HISTORY
  Future<void> loadHistory() async {
    try {
      await _waitForDatabase();

      final results = await _database!.query(
        'downloads',
        orderBy: 'dateTime DESC',
      );

      downloadHistory.assignAll(results);

      debugPrint('📚 Loaded ${results.length} history items');
    } catch (e) {
      debugPrint('❌ Load history error: $e');
    }
  }

  // START DOWNLOAD
  Future<void> startDownload({
    required String url,
    required String quality,
    required String fileName,
    String? estimatedSize,
  }) async {
    await _waitForDatabase();

    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    final task = DownloadTask(
      id: taskId,
      url: url,
      fileName: fileName,
      quality: quality,
      progress: 0.0,
      status: DownloadStatus.downloading,
    );

    activeDownloads.add(task);

    debugPrint('🚀 Starting download: $fileName (Estimated: $estimatedSize)');

    final savedPath = await _downloadService.downloadVideo(
      url: url,
      fileName: fileName,
      onProgress: (received, total) {
        final index = activeDownloads.indexWhere((t) => t.id == taskId);

        if (index != -1 && total > 0) {
          activeDownloads[index].progress = received / total;

          // IMPORTANT FOR GETX
          activeDownloads.refresh();
        }
      },
    );

    // SUCCESS
    if (savedPath != null) {
      try {
        final file = File(savedPath);

        final actualFileSizeBytes = await file.length();

        final actualSizeStr = _formatFileSize(actualFileSizeBytes);

        final displaySizeStr = estimatedSize ?? actualSizeStr;

        await _database!.insert('downloads', {
          'fileName': fileName,
          'filePath': savedPath,
          'videoUrl': url,
          'quality': quality,
          'fileSize': displaySizeStr,
          'actualFileSize': actualFileSizeBytes,
          'estimatedSize': estimatedSize,
          'dateTime': DateTime.now().toIso8601String(),
        });

        await loadHistory();

        activeDownloads.removeWhere((t) => t.id == taskId);

        debugPrint('✅ Download completed and saved to history: $fileName');
      } catch (e) {
        debugPrint('❌ Save history error: $e');
      }
    }
    // FAILED
    else {
      final index = activeDownloads.indexWhere((t) => t.id == taskId);

      if (index != -1) {
        activeDownloads[index].status = DownloadStatus.failed;

        activeDownloads.refresh();
      }

      debugPrint('❌ Download failed: $fileName');
    }
  }

  // DELETE SINGLE ITEM
  Future<void> deleteHistoryItem(int id, String filePath) async {
    try {
      await _downloadService.deleteVideo(filePath);

      await _database!.delete('downloads', where: 'id = ?', whereArgs: [id]);

      await loadHistory();

      debugPrint('🗑️ Deleted history item: $id');
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  // CLEAR ALL HISTORY
  Future<void> clearAllHistory() async {
    try {
      for (var item in downloadHistory) {
        await _downloadService.deleteVideo(item['filePath']);
      }

      await _database!.delete('downloads');

      downloadHistory.clear();

      debugPrint('🗑️ Cleared all history');
    } catch (e) {
      debugPrint('❌ Clear history error: $e');
    }
  }

  // ADD TO HISTORY
  Future<void> addToHistory({
    required String fileName,
    required String filePath,
    required String videoUrl,
    required String quality,
    String? estimatedSize,
    int? actualFileSizeBytes,
  }) async {
    try {
      await _waitForDatabase();

      String displaySizeStr;

      int actualSize;

      String? estimatedSizeStr = estimatedSize;

      if (actualFileSizeBytes != null && actualFileSizeBytes > 0) {
        actualSize = actualFileSizeBytes;

        final actualSizeFormatted = _formatFileSize(actualFileSizeBytes);

        displaySizeStr = estimatedSize ?? actualSizeFormatted;
      } else {
        final file = File(filePath);

        if (await file.exists()) {
          actualSize = await file.length();

          final actualSizeFormatted = _formatFileSize(actualSize);

          displaySizeStr = estimatedSize ?? actualSizeFormatted;
        } else {
          actualSize = 0;

          displaySizeStr = estimatedSize ?? 'Unknown';
        }
      }

      await _database!.insert('downloads', {
        'fileName': fileName,
        'filePath': filePath,
        'videoUrl': videoUrl,
        'quality': quality,
        'fileSize': displaySizeStr,
        'actualFileSize': actualSize,
        'estimatedSize': estimatedSizeStr,
        'dateTime': DateTime.now().toIso8601String(),
      });

      await loadHistory();

      debugPrint('✅ Added to history: $fileName');
    } catch (e) {
      debugPrint('❌ Add history error: $e');
    }
  }

  // UPDATE SIZE
  Future<void> updateHistoryWithActualSize(
    int id,
    int actualFileSizeBytes, {
    String? estimatedSize,
  }) async {
    try {
      await _waitForDatabase();

      final actualSizeStr = _formatFileSize(actualFileSizeBytes);

      Map<String, dynamic> updateData = {'actualFileSize': actualFileSizeBytes};

      if (estimatedSize == null) {
        updateData['fileSize'] = actualSizeStr;
      }

      await _database!.update(
        'downloads',
        updateData,
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadHistory();

      debugPrint('✅ Updated history item');
    } catch (e) {
      debugPrint('❌ Update history error: $e');
    }
  }

  // FILE SIZE
  Future<String> getFileSize(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        final size = await file.length();

        return _formatFileSize(size);
      }
    } catch (e) {
      debugPrint('❌ File size error: $e');
    }

    return 'Unknown';
  }

  // DISPLAY SIZE
  String getDisplaySizeForHistoryItem(Map<String, dynamic> item) {
    final estimatedSize = item['estimatedSize'] as String?;

    final actualFileSize = item['actualFileSize'] as int?;

    if (estimatedSize != null && actualFileSize != null) {
      final actualSizeStr = _formatFileSize(actualFileSize);

      if (estimatedSize != actualSizeStr) {
        return '$estimatedSize (Actual: $actualSizeStr)';
      }

      return estimatedSize;
    }

    return item['fileSize'] as String? ?? 'Unknown';
  }

  // FORMAT SIZE
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];

    var i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // CANCEL DOWNLOAD
  void cancelDownload(String taskId) {
    activeDownloads.removeWhere((task) => task.id == taskId);
  }
}

// DOWNLOAD TASK
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

// STATUS
enum DownloadStatus { downloading, completed, failed }
