
// ignore_for_file: invalid_null_aware_operator

import 'package:webview_flutter/webview_flutter.dart';
import '../../models/media_metadata.dart';
import 'media_service.dart';

class HybridMediaService {
  final MediaService _mediaService = MediaService();

  void setWebViewController(WebViewController controller) {
    _mediaService.setWebViewController(controller);
  }

  /// Check if URL is Facebook URL
  bool _isFacebookUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('facebook.com') ||
        lowerUrl.contains('fb.watch') ||
        lowerUrl.contains('fbcdn.net') ||
        lowerUrl.contains('fbsv.com') ||
        lowerUrl.contains('fbcdn');
  }

  Future<MediaMetadata?> inspectMedia(
    String url,
    WebViewController? webController,
  ) async {
    if (webController != null) {
      _mediaService.setWebViewController(webController);
    }

    // Strict check - Only allow Facebook URLs
    if (!_isFacebookUrl(url)) {
      print('Non-Facebook URL rejected: $url');
      return MediaMetadata(
        sourceUrl: url,
        platform: MediaPlatform.unsupported,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: false,
        downloadPermitted: false,
        legalMessage: 'This app only supports Facebook video downloads.',
      );
    }

    // Try to extract using MediaService with cookies
    try {
      final result = await _mediaService.inspectPublicMedia(url);
      if (result.mediaUrl != null && result.mediaUrl!.isNotEmpty) {
        return result;
      }
    } catch (e) {
      print('MediaService extraction failed: $e');
    }

    // Fallback to direct JS extraction for Facebook
    if (webController != null && _isFacebookUrl(url)) {
      try {
        final jsUrl = await _extractFromWebView(webController);
        if (jsUrl != null && jsUrl.isNotEmpty && jsUrl.startsWith('http')) {
          return MediaMetadata(
            sourceUrl: url,
            platform: MediaPlatform.facebook,
            mediaUrl: jsUrl,
            thumbnailUrl: null,
            type: MediaType.video,
            publiclyAccessible: true,
            downloadPermitted: true,
            legalMessage:
                'Facebook video detected via webview extraction. You are responsible for respecting copyright.',
          );
        }
      } catch (e) {
        print('WebView extraction failed: $e');
      }
    }

    return null;
  }

  Future<String?> _extractFromWebView(WebViewController controller) async {
    try {
      final result = await controller.runJavaScriptReturningResult('''
        (function() {
          // Try multiple extraction methods for Facebook
          const videos = document.querySelectorAll('video');
          for (const video of videos) {
            if (video.src && video.src.startsWith('http')) {
              return video.src;
            }
            const sources = video.querySelectorAll('source');
            for (const source of sources) {
              if (source.src && source.src.startsWith('http')) {
                return source.src;
              }
            }
          }
          
          // Check for Facebook data attributes
          const elements = document.querySelectorAll('[data-video-url], [data-hd-url], [data-sd-url], [data-video]');
          for (const el of elements) {
            const url = el.getAttribute('data-video-url') || 
                       el.getAttribute('data-hd-url') || 
                       el.getAttribute('data-sd-url') ||
                       el.getAttribute('data-video');
            if (url && url.startsWith('http')) return url;
          }
          
          // Check for video URLs in page source
          const allElements = document.querySelectorAll('*');
          for (const el of allElements) {
            const attrs = el.attributes;
            for (let i = 0; i < attrs.length; i++) {
              const value = attrs[i].value;
              if (value && value.startsWith('http') && 
                  (value.includes('.mp4') || value.includes('video') || value.includes('fbcdn'))) {
                return value;
              }
            }
          }
          
          return null;
        })();
      ''');
      return result?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<String?> findQualityVideo(
    WebViewController controller,
    String quality,
  ) async {
    try {
      final result = await controller.runJavaScriptReturningResult('''
        (function() {
          let bestMatchUrl = '';
          let qualityScore = 0;
          const targetQuality = ${quality.replaceAll('p', '')};
          
          const videos = document.querySelectorAll('video');
          for (const video of videos) {
            if (video.src && video.src.startsWith('http')) {
              let q = 0;
              if (video.src.includes('1080') || video.src.includes('original')) q = 1080;
              else if (video.src.includes('720') || video.src.includes('hd')) q = 720;
              else if (video.src.includes('480')) q = 480;
              else if (video.src.includes('360')) q = 360;
              else if (video.src.includes('240')) q = 240;
              else if (video.src.includes('144')) q = 144;
              
              if (q === targetQuality) return video.src;
              if (q > 0 && (bestMatchUrl === '' || Math.abs(q - targetQuality) < Math.abs(qualityScore - targetQuality))) {
                bestMatchUrl = video.src;
                qualityScore = q;
              }
            }
          }
          return bestMatchUrl;
        })();
      ''');
      return result?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Check if URL contains Facebook video
  Future<bool> isFacebookVideo(String url) async {
    if (!_isFacebookUrl(url)) return false;

    try {
      final metadata = await inspectMedia(url, null);
      return metadata != null && metadata.mediaUrl != null;
    } catch (e) {
      return false;
    }
  }
}
