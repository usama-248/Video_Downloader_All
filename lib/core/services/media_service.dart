// ignore_for_file: unnecessary_null_comparison

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
        // Try to get cookies from WebView
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
        print('Failed to get cookies from WebView: $e');
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

  MediaPlatform detectPlatform(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host.contains('facebook.com') || host.contains('fb.watch')) {
      return MediaPlatform.facebook;
    }
    if (host.contains('instagram.com')) {
      return MediaPlatform.instagram;
    }
    if (host.contains('twitter.com') || host.contains('x.com')) {
      return MediaPlatform.twitter;
    }
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return MediaPlatform.youtube;
    }
    if (host.contains('tiktok.com')) {
      return MediaPlatform.tiktok;
    }
    return MediaPlatform.unsupported;
  }

  Future<MediaMetadata> inspectPublicMedia(String inputUrl) async {
    final uri = Uri.tryParse(inputUrl.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('Please enter a valid HTTP/HTTPS URL.');
    }

    final platform = detectPlatform(uri);
    if (platform == MediaPlatform.unsupported) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: platform,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: false,
        downloadPermitted: false,
        legalMessage:
            'This platform is not supported. Only public Facebook, Instagram, Twitter, YouTube, and TikTok URLs are accepted.',
      );
    }

    // Get cookies from WebView first
    await _getSessionCookie();
    
    final response = await _fetchPublicPage(uri, platform);
    if (response == null || response.statusCode != 200) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: platform,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: false,
        downloadPermitted: false,
        legalMessage:
            'Unable to access this URL. Please make sure you are logged in to $platform in the webview.',
      );
    }

    final html = response.body;
    final ogVideo = _extractMeta(html, 'og:video:url') ??
        _extractMeta(html, 'og:video:secure_url') ??
        _extractMeta(html, 'og:video') ??
        _extractMeta(html, 'twitter:player:stream') ??
        _extractFromJson(html, const [
          r'"browser_native_hd_url":"([^"]+)"',
          r'"browser_native_sd_url":"([^"]+)"',
          r'"hd_src":"([^"]+)"',
          r'"sd_src":"([^"]+)"',
          r'"video_url":"([^"]+)"',
          r'"video_info"\s*:\s*\{[^}]*"variants"\s*:\s*\[[^\]]*"url":"([^"]+)"',
          r'"variants"\s*:\s*\[[^\]]*"content_type":"video\/mp4","url":"([^"]+)"',
          r'"video_versions"\s*:\s*\[\{"type":"\d+x\d+","url":"([^"]+)"',
          r'"playAddr":"([^"]+)"',
          r'"downloadAddr":"([^"]+)"',
          r'"contentUrl"\s*:\s*"([^"]+)"',
          r'"playable_url":"([^"]+)"',
          r'"playable_url_quality_hd":"([^"]+)"',
        ]);
    final ogImage = _extractMeta(html, 'og:image') ??
        _extractFromJson(html, const [
          r'"display_url":"([^"]+)"',
          r'"display_resources"\s*:\s*\[\{"src":"([^"]+)"',
          r'"thumbnailUrl"\s*:\s*"([^"]+)"',
        ]);
    final isVideoIntentUrl =
        _isVideoIntentUrl(uri, platform) || _looksLikeVideoPage(html, platform);
    final mediaUrl = isVideoIntentUrl ? ogVideo : (ogVideo ?? ogImage);
    final type = ogVideo != null
        ? MediaType.video
        : (!isVideoIntentUrl && ogImage != null
            ? MediaType.image
            : MediaType.unknown);

    if (mediaUrl == null) {
      return MediaMetadata(
        sourceUrl: inputUrl,
        platform: platform,
        mediaUrl: null,
        thumbnailUrl: null,
        type: MediaType.unknown,
        publiclyAccessible: true,
        downloadPermitted: false,
        legalMessage:
            'No video URL found. Please make sure you are logged in and the video is accessible.',
      );
    }

    return MediaMetadata(
      sourceUrl: inputUrl,
      platform: platform,
      mediaUrl: mediaUrl,
      thumbnailUrl: ogImage,
      type: type,
      publiclyAccessible: true,
      downloadPermitted: true,
      legalMessage: 'Video detected successfully. You are responsible for rights compliance.',
    );
  }

  Future<http.Response?> _fetchPublicPage(
    Uri originalUri,
    MediaPlatform platform,
  ) async {
    final candidates = <Uri>[originalUri];

    final cleaned = originalUri.replace(queryParameters: {}, fragment: '');
    if (cleaned.toString() != originalUri.toString()) {
      candidates.add(cleaned);
    }

    // Add mobile versions for better access
    if (platform == MediaPlatform.facebook) {
      candidates.add(cleaned.replace(host: 'mbasic.facebook.com'));
      candidates.add(cleaned.replace(host: 'm.facebook.com'));
      
      final videoId = originalUri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        candidates.add(Uri.parse('https://mbasic.facebook.com/watch?v=$videoId'));
        candidates.add(Uri.parse('https://mbasic.facebook.com/video.php?v=$videoId'));
      }
    }

    if (platform == MediaPlatform.instagram) {
      candidates.add(cleaned.replace(host: 'www.instagram.com'));
      // Add JSON endpoint for Instagram
      candidates.add(
        cleaned.replace(queryParameters: {'__a': '1', '__d': 'dis'}),
      );
    }

    for (final candidate in candidates) {
      try {
        final headers = _getHeadersWithCookies();
        // Add platform-specific referers
        if (platform == MediaPlatform.facebook) {
          headers['Referer'] = 'https://www.facebook.com/';
        } else if (platform == MediaPlatform.instagram) {
          headers['Referer'] = 'https://www.instagram.com/';
        }
        
        final response = await http.get(candidate, headers: headers);
        if (response.statusCode == 200) {
          return response;
        }
      } catch (_) {
        // Try next candidate.
      }
    }
    return null;
  }

  String? _extractMeta(String html, String property) {
    final propertyThenContent = RegExp(
      '<meta[^>]*(?:property|name)=["\']$property["\'][^>]*content=["\']([^"\']+)["\'][^>]*>',
      caseSensitive: false,
    );
    final contentThenProperty = RegExp(
      '<meta[^>]*content=["\']([^"\']+)["\'][^>]*(?:property|name)=["\']$property["\'][^>]*>',
      caseSensitive: false,
    );
    final match =
        propertyThenContent.firstMatch(html) ?? contentThenProperty.firstMatch(html);
    if (match == null) return null;
    return _decodeScrapedUrl(match.group(1) ?? '');
  }

  String? _extractFromJson(String html, List<String> patterns) {
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

  String? _decodeScrapedUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var decoded = const HtmlUnescape().convert(raw.trim());
    decoded = decoded.replaceAll(r'\/', '/');
    decoded = decoded.replaceAll(r'\u0026', '&');
    decoded = decoded.replaceAll(r'\u002F', '/');
    decoded = decoded.replaceAll(r'\u003D', '=');
    return decoded;
  }

  bool _isVideoIntentUrl(Uri uri, MediaPlatform platform) {
    final path = uri.path.toLowerCase();
    if (platform == MediaPlatform.facebook) {
      return path.contains('/watch') ||
          path.contains('/reel') ||
          path.contains('/videos/') ||
          uri.queryParameters.containsKey('v');
    }
    if (platform == MediaPlatform.instagram) {
      return path.contains('/reel/') || path.contains('/tv/') || path.contains('/p/');
    }
    if (platform == MediaPlatform.twitter) {
      return path.contains('/status/');
    }
    if (platform == MediaPlatform.youtube) {
      return path.contains('/watch') ||
          path.contains('/shorts/') ||
          path.contains('/embed/') ||
          uri.queryParameters.containsKey('v');
    }
    if (platform == MediaPlatform.tiktok) {
      return path.contains('/video/') ||
          path.contains('/@') ||
          uri.host.contains('vm.tiktok.com') ||
          uri.host.contains('vt.tiktok.com');
    }
    return false;
  }

  bool _looksLikeVideoPage(String html, MediaPlatform platform) {
    final lower = html.toLowerCase();
    if (platform == MediaPlatform.facebook) {
      return lower.contains('"is_video":true') ||
          lower.contains('"videoid"') ||
          lower.contains('"browser_native_hd_url"') ||
          lower.contains('"playable_url"') ||
          lower.contains('property="og:video"');
    }
    if (platform == MediaPlatform.instagram) {
      return lower.contains('"is_video":true') ||
          lower.contains('"video_versions"') ||
          lower.contains('property="og:video"');
    }
    if (platform == MediaPlatform.twitter) {
      return lower.contains('property="og:video"') ||
          lower.contains('"video_info"') ||
          lower.contains('"video_url"');
    }
    if (platform == MediaPlatform.youtube) {
      return lower.contains('property="og:video"') ||
          lower.contains('"streamingdata"') ||
          lower.contains('"formats"');
    }
    if (platform == MediaPlatform.tiktok) {
      return lower.contains('property="og:video"') ||
          lower.contains('"downloadaddr"') ||
          lower.contains('"playaddr"');
    }
    return false;
  }
}