// lib/widgets/history_item_widget.dart (Updated with force reload support)
import 'dart:io';
import 'package:facebook_video_downloader/core/services/thumbnail_cache_service.dart';
import 'package:flutter/material.dart';

class HistoryItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final VoidCallback onPlay;
  final Future<bool?> Function() onDeleteConfirm;
  final Future<void> Function() onDelete;
  final String Function() formatDate;
  final bool forceReload; // Add this parameter

  const HistoryItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.onPlay,
    required this.onDeleteConfirm,
    required this.onDelete,
    required this.formatDate,
    this.forceReload = false, // Default to false
  });

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget> {
  late final ThumbnailCacheService _thumbnailCache;
  
  // Store thumbnail permanently once loaded
  String? _cachedThumbnail;
  bool _isLoadingThumbnail = false;
  bool _thumbnailLoaded = false;

  @override
  void initState() {
    super.initState();
    _thumbnailCache = ThumbnailCacheService();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(HistoryItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Force reload when refresh is triggered
    if (widget.forceReload && !oldWidget.forceReload) {
      // Clear cache for this video to force thumbnail regeneration
      _thumbnailCache.removeFromCache(widget.item['id'].toString());
      _thumbnailLoaded = false;
      _cachedThumbnail = null;
      _loadThumbnail();
    }
    // Only reload if the video path changed
    else if (oldWidget.item['filePath'] != widget.item['filePath']) {
      _thumbnailLoaded = false;
      _cachedThumbnail = null;
      _loadThumbnail();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    if (_thumbnailLoaded) return;
    
    // Don't load if no file path
    final filePath = widget.item['filePath'] as String?;
    if (filePath == null || filePath.isEmpty) {
      setState(() {
        _isLoadingThumbnail = false;
        _thumbnailLoaded = true;
      });
      return;
    }
    
    // Check if file exists
    final file = File(filePath);
    if (!await file.exists()) {
      setState(() {
        _isLoadingThumbnail = false;
        _thumbnailLoaded = true;
      });
      return;
    }
    
    setState(() {
      _isLoadingThumbnail = true;
    });
    
    final videoId = widget.item['id'].toString();
    final thumbnail = await _thumbnailCache.getThumbnail(filePath, videoId);
    
    if (mounted) {
      setState(() {
        _cachedThumbnail = thumbnail;
        _isLoadingThumbnail = false;
        _thumbnailLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: _buildThumbnail(),
        title: Text(
          widget.item['fileName'] ?? 'Unknown',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality: ${widget.item['quality'] ?? 'Unknown'} | Size: ${widget.item['fileSize'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              widget.formatDate(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.play_arrow,
            color: Color.fromARGB(255, 48, 172, 85),
          ),
          onPressed: widget.onPlay,
        ),
        onLongPress: () async {
          final shouldDelete = await widget.onDeleteConfirm();
          if (shouldDelete == true) {
            await widget.onDelete();
          }
        },
      ),
    );
  }

  Widget _buildThumbnail() {
    // Show loading indicator during refresh
    if (widget.forceReload && _isLoadingThumbnail) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    
    // Show permanent thumbnail if loaded
    if (_thumbnailLoaded && _cachedThumbnail != null && _cachedThumbnail!.isNotEmpty) {
      final thumbnailFile = File(_cachedThumbnail!);
      if (thumbnailFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            thumbnailFile,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );
      }
    }
    
    // Show loading indicator during initial load
    if (_isLoadingThumbnail) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    
    // Default placeholder
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Icon(
        Icons.video_file,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}