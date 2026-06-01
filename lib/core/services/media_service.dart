


// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/media_metadata.dart';

class HtmlUnescape {
  const HtmlUnescape();

  String convert(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final value = int.tryParse(match.group(1) ?? '');
      if (value == null) return match.group(0) ?? '';
      return String.fromCharCode(value);
    });
  }
}

class MediaService {
  static const _headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Cache-Control': 'no-cache',
    'Referer': 'https://www.facebook.com/',
  };

  String? _sessionCookie;
  WebViewController? _webViewController;

  void setWebViewController(WebViewController controller) {
    _webViewController = controller;
  }

  Future<String?> _getSessionCookie() async {
    if (_sessionCookie != null) return _sessionCookie;
    
    if (_webViewController != null) {
      try {
        final cookies = await _webViewController!.runJavaScriptReturningResult('''
          (function() {
            return document.cookie;
          })();
        ''');
        if (cookies != null && cookies.toString().isNotEmpty) {
          _sessionCookie = cookies.toString();
          return _sessionCookie;
        }
      } catch (e) {
        debugPrint('Failed to get cookies from WebView: $e');
      }
    }
    return null;
  }

  Map<String, String> _getHeadersWithCookies() {
    final headers = Map<String, String>.from(_headers);
    if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
      headers['Cookie'] = _sessionCookie!;
    }
    return headers;
  }

  /// ONLY detects Facebook URLs
  bool isFacebookUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('facebook.com') ||
        lowerUrl.contains('fb.watch') ||
        lowerUrl.contains('fbcdn.net') ||
        lowerUrl.contains('fbsv.com') ||
        lowerUrl.contains('fbcdn');
  }

  Future<MediaMetadata> inspectPublicMedia(String inputUrl) async {
    final uri = Uri.tryParse(inputUrl.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('Please enter a valid HTTP/HTTPS URL.');
    }

    // STRICT CHECK: Only allow Facebook URLs
    if (!isFacebookUrl(inputUrl)) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: MediaPlatform.facebook,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: false,
        downloadPermitted: false,
        legalMessage:
            'This app only supports Facebook video downloads. Please enter a valid Facebook video URL.',
      );
    }

    // Get cookies from WebView first
    await _getSessionCookie();
    
    final response = await _fetchFacebookPage(uri);
    if (response == null || response.statusCode != 200) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: MediaPlatform.facebook,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: false,
        downloadPermitted: false,
        legalMessage:
            'Unable to access this Facebook URL. Please make sure you are logged in to Facebook in the webview.',
      );
    }

    final html = response.body;
    
    // Extract video URL from Facebook page
    final videoUrl = _extractFacebookVideoUrl(html);
    final thumbnailUrl = _extractFacebookThumbnail(html);
    
    if (videoUrl == null) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: MediaPlatform.facebook,
        mediaUrl: null,
        thumbnailUrl: thumbnailUrl,
        type: MediaType.unknown,
        publiclyAccessible: true,
        downloadPermitted: false,
        legalMessage:
            'No video URL found on this Facebook page. Please make sure you are viewing a video post.',
      );
    }

    return MediaMetadata(
      sourceUrl: inputUrl,
      platform: MediaPlatform.facebook,
      mediaUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      type: MediaType.video,
      publiclyAccessible: true,
      downloadPermitted: true,
      legalMessage: 'Facebook video detected. You are responsible for respecting copyright and Facebook\'s Terms of Service.',
    );
  }

  String? _extractFacebookVideoUrl(String html) {
    // Try multiple patterns for Facebook videos
    final patterns = [
      r'"browser_native_hd_url":"([^"]+)"',
      r'"browser_native_sd_url":"([^"]+)"',
      r'"hd_src":"([^"]+)"',
      r'"sd_src":"([^"]+)"',
      r'"playable_url":"([^"]+)"',
      r'"playable_url_quality_hd":"([^"]+)"',
      r'"video_url":"([^"]+)"',
      r'property="og:video"[^>]+content="([^"]+)"',
      r'property="og:video:url"[^>]+content="([^"]+)"',
      r'"video_versions"\s*:\s*\[\{"type":"\d+x\d+","url":"([^"]+)"',
      r'"variants"\s*:\s*\[[^\]]*"url":"([^"]+)"',
    ];
    
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
      if (match != null) {
        final value = _decodeScrapedUrl(match.group(1) ?? '');
        if (value != null && value.startsWith('http')) {
          return value;
        }
      }
    }
    
    return null;
  }

  String? _extractFacebookThumbnail(String html) {
    final patterns = [
      r'property="og:image"[^>]+content="([^"]+)"',
      r'"thumbnail_url":"([^"]+)"',
      r'"thumbnailUrl":"([^"]+)"',
      r'"image":"([^"]+)"',
    ];
    
    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
      if (match != null) {
        final value = _decodeScrapedUrl(match.group(1) ?? '');
        if (value != null && value.startsWith('http')) {
          return value;
        }
      }
    }
    
    return null;
  }

  Future<http.Response?> _fetchFacebookPage(Uri originalUri) async {
    final candidates = <Uri>[originalUri];

    final cleaned = originalUri.replace(queryParameters: {}, fragment: '');
    if (cleaned.toString() != originalUri.toString()) {
      candidates.add(cleaned);
    }

    // Add mobile versions for better access
    candidates.add(cleaned.replace(host: 'mbasic.facebook.com'));
    candidates.add(cleaned.replace(host: 'm.facebook.com'));
    
    final videoId = originalUri.queryParameters['v'];
    if (videoId != null && videoId.isNotEmpty) {
      candidates.add(Uri.parse('https://mbasic.facebook.com/watch?v=$videoId'));
      candidates.add(Uri.parse('https://mbasic.facebook.com/video.php?v=$videoId'));
    }

    for (final candidate in candidates) {
      try {
        final headers = _getHeadersWithCookies();
        headers['Referer'] = 'https://www.facebook.com/';
        
        final response = await http.get(candidate, headers: headers);
        if (response.statusCode == 200) {
          return response;
        }
      } catch (_) {
        // Try next candidate
      }
    }
    return null;
  }

  String? _decodeScrapedUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var decoded = const HtmlUnescape().convert(raw.trim());
    decoded = decoded.replaceAll(r'\/', '/');
    decoded = decoded.replaceAll(r'\u0026', '&');
    decoded = decoded.replaceAll(r'\u002F', '/');
    decoded = decoded.replaceAll(r'\u003D', '=');
    decoded = decoded.replaceAll(r'\u005C', '');
    return decoded;
  }
}