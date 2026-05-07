import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'download_service.dart';

class DownloadController extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();

  Database? _database;

  // IMPORTANT FIX
  bool _isDatabaseReady = false;

  List<DownloadTask> _activeDownloads = [];
  List<Map<String, dynamic>> _downloadHistory = [];

  List<DownloadTask> get activeDownloads => _activeDownloads;

  List<Map<String, dynamic>> get downloadHistory => _downloadHistory;

  DownloadController() {
    _initialize();
  }

  // INITIALIZE DATABASE + HISTORY
  Future<void> _initialize() async {
    await _initDatabase();

    await loadHistory();
  }

  // DATABASE INITIALIZATION
  Future<void> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'video_downloads.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
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

      // IMPORTANT
      _isDatabaseReady = true;

      debugPrint('✅ Database initialized');
    } catch (e) {
      debugPrint('❌ Database error: $e');
    }
  }

  // WAIT UNTIL DATABASE READY
  Future<void> _waitForDatabase() async {
    while (!_isDatabaseReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // LOAD HISTORY
  Future<void> loadHistory() async {
    try {
      await _waitForDatabase();

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

  // START DOWNLOAD
  Future<void> startDownload({
    required String url,
    required String quality,
    required String fileName,
  }) async {
    // IMPORTANT FIX
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

    // DOWNLOAD SUCCESS
    if (savedPath != null) {
      try {
        final file = File(savedPath);

        final fileSize = await file.length();

        final sizeStr = _formatFileSize(fileSize);

        // SAVE TO DATABASE
        await _database!.insert('downloads', {
          'fileName': fileName,
          'filePath': savedPath,
          'videoUrl': url,
          'quality': quality,
          'fileSize': sizeStr,
          'dateTime': DateTime.now().toIso8601String(),
        });

        // RELOAD HISTORY IMMEDIATELY
        await loadHistory();

        // REMOVE ACTIVE DOWNLOAD
        _activeDownloads.removeWhere((t) => t.id == taskId);

        notifyListeners();

        debugPrint('✅ Download saved to history: $fileName');
      } catch (e) {
        debugPrint('❌ Save history error: $e');
      }
    } else {
      // DOWNLOAD FAILED
      final index = _activeDownloads.indexWhere((t) => t.id == taskId);

      if (index != -1) {
        _activeDownloads[index].status = DownloadStatus.failed;

        notifyListeners();
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
      for (var item in _downloadHistory) {
        await _downloadService.deleteVideo(item['filePath']);
      }

      await _database!.delete('downloads');

      await loadHistory();

      debugPrint('🗑️ Cleared all history');
    } catch (e) {
      debugPrint('❌ Clear history error: $e');
    }
  }

  // MANUAL ADD TO HISTORY
  Future<void> addToHistory({
    required String fileName,
    required String filePath,
    required String videoUrl,
    required String quality,
  }) async {
    try {
      await _waitForDatabase();

      final sizeStr = await _getFileSize(filePath);

      await _database!.insert('downloads', {
        'fileName': fileName,
        'filePath': filePath,
        'videoUrl': videoUrl,
        'quality': quality,
        'fileSize': sizeStr,
        'dateTime': DateTime.now().toIso8601String(),
      });

      // IMPORTANT
      await loadHistory();

      notifyListeners();

      debugPrint('✅ Added to history and refreshed');
    } catch (e) {
      debugPrint('❌ Add history error: $e');
    }
  }

  // FILE SIZE
  Future<String> _getFileSize(String filePath) async {
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

  // FORMAT SIZE
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];

    var i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // CANCEL DOWNLOAD
  void cancelDownload(String taskId) {
    _activeDownloads.removeWhere((task) => task.id == taskId);

    notifyListeners();
  }
}

// DOWNLOAD TASK MODEL
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

// DOWNLOAD STATUS
enum DownloadStatus { downloading, completed, failed }
