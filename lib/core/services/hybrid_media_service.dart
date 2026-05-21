// ignore_for_file: invalid_null_aware_operator

import 'package:webview_flutter/webview_flutter.dart';
import '../../models/media_metadata.dart';
import 'media_service.dart';

class HybridMediaService {
  final MediaService _mediaService = MediaService();
  
  void setWebViewController(WebViewController controller) {
    _mediaService.setWebViewController(controller);
  }
  
  Future<MediaMetadata?> inspectMedia(String url, WebViewController? webController) async {
    if (webController != null) {
      _mediaService.setWebViewController(webController);
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
    
    // Fallback to direct JS extraction
    if (webController != null) {
      try {
        final jsUrl = await _extractFromWebView(webController);
        if (jsUrl != null && jsUrl.isNotEmpty && jsUrl.startsWith('http')) {
          return MediaMetadata(
            sourceUrl: url,
            platform: _mediaService.detectPlatform(Uri.parse(url)),
            mediaUrl: jsUrl,
            thumbnailUrl: null,
            type: MediaType.video,
            publiclyAccessible: true,
            downloadPermitted: true,
            legalMessage: 'Video detected via webview extraction',
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
          // Try multiple extraction methods
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
          
          // Check for data attributes
          const elements = document.querySelectorAll('[data-video-url], [data-hd-url], [data-sd-url]');
          for (const el of elements) {
            const url = el.getAttribute('data-video-url') || 
                       el.getAttribute('data-hd-url') || 
                       el.getAttribute('data-sd-url');
            if (url && url.startsWith('http')) return url;
          }
          
          return null;
        })();
      ''');
      return result?.toString();
    } catch (e) {
      return null;
    }
  }
  
  Future<String?> findQualityVideo(WebViewController controller, String quality) async {
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
              if (video.src.includes('1080')) q = 1080;
              else if (video.src.includes('720')) q = 720;
              else if (video.src.includes('480')) q = 480;
              else if (video.src.includes('360')) q = 360;
              
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
}