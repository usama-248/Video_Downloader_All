// lib/services/thumbnail_cache_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailCacheService {
  static final ThumbnailCacheService _instance = ThumbnailCacheService._internal();
  factory ThumbnailCacheService() => _instance;
  ThumbnailCacheService._internal();

  final Map<String, String> _cache = {};
  final Map<String, Future<String?>> _pendingFutures = {};

  Future<String?> getThumbnail(String videoPath, String videoId) async {
    final cacheKey = videoId;
    
    // Return from cache if available
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }
    
    // Return existing future if already generating
    if (_pendingFutures.containsKey(cacheKey)) {
      return _pendingFutures[cacheKey];
    }
    
    // Generate new thumbnail
    final future = _generateAndCache(videoPath, cacheKey);
    _pendingFutures[cacheKey] = future;
    
    return future;
  }
  
  Future<String?> _generateAndCache(String videoPath, String cacheKey) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      
      if (thumbnail != null) {
        _cache[cacheKey] = thumbnail;
      }
      
      return thumbnail;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    } finally {
      _pendingFutures.remove(cacheKey);
    }
  }
  
  void clearCache() {
    _cache.clear();
    _pendingFutures.clear();
  }
  
  void removeFromCache(String videoId) {
    final cacheKey = videoId;
    final cachedPath = _cache.remove(cacheKey);
    if (cachedPath != null) {
      // Optionally delete temp file
      try {
        File(cachedPath).delete();
      } catch (_) {}
    }
    _pendingFutures.remove(cacheKey);
  }
}