// ignore_for_file: unnecessary_null_comparison, unused_field
import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/core/config/app_env.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  String? detectedVideoUrl;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _isVideoDetected = false;
  String? _lastDownloadedFilePath;
  String? _lastDownloadedFileName;
  bool _showAutoPopup = true;

  // File sizes for popup cards (estimated from HEAD request)
  String? _sdSize;
  String? _hdSize;
  String? _audioSize;
  bool _isFetchingSizes = false;

  // ACTUAL download progress tracking from the real download stream
  int _receivedBytes = 0;
  int _actualTotalBytes = 0; // real total from server during download
  bool _totalKnown = false; // whether server sent Content-Length
  String _downloadSpeed = '0 KB/s';
  String _downloadQualityLabel = '';
  DateTime? _lastSpeedCalcTime;
  int _lastSpeedCalcBytes = 0;
  Timer? _speedTimer;

  // Store the selected download size for consistent display (estimate on sheet / progress)
  String? _selectedDownloadSize;

  bool _downloadIsAudio = false;

  /// SD / low-quality video download (for progress UI icon tint).
  bool _downloadProgressIsSdVideo = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initWebView();
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'VideoChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _onVideoDetected(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
              _isVideoDetected = false;
              detectedVideoUrl = null;
              _sdSize = null;
              _hdSize = null;
              _audioSize = null;
              _selectedDownloadSize = null;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectJS();

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted &&
                  detectedVideoUrl != null &&
                  _showAutoPopup &&
                  !_isDownloading) {
                _showDownloadOptionsPopup();
              }
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load page';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('intent://') ||
                request.url.startsWith('fb://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUrl());
  }

  Future<void> _loadUrl() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final uri = Uri.parse(widget.url);
      await _controller.loadRequest(uri);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading: ${widget.url}';
      });
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${localizations?.download_failed ?? 'Failed to load'}: ${widget.url}',
            ),
          ),
        );
      }
    }
  }

  void _injectJS() {
    _controller.runJavaScript('''
      function findVideoUrls() {
        const urls = [];
        const videos = document.querySelectorAll('video');
        for (const video of videos) {
          if (video.src && video.src.startsWith('http')) {
            urls.push(video.src);
            VideoChannel.postMessage(video.src);
          }
          const sources = video.querySelectorAll('source');
          for (const source of sources) {
            if (source.src && source.src.startsWith('http')) {
              urls.push(source.src);
              VideoChannel.postMessage(source.src);
            }
          }
        }
        const iframes = document.querySelectorAll('iframe');
        for (const iframe of iframes) {
          if (iframe.src && (iframe.src.includes('.mp4') || iframe.src.includes('video'))) {
            urls.push(iframe.src);
            VideoChannel.postMessage(iframe.src);
          }
        }

        const allElements = document.querySelectorAll('[src*=".mp4"], [data-video-url], [data-hd-url], [data-sd-url]');
        for (const element of allElements) {
          const src = element.getAttribute('src');
          const dataVideoUrl = element.getAttribute('data-video-url');
          const dataHdUrl = element.getAttribute('data-hd-url');
          const dataSdUrl = element.getAttribute('data-sd-url');
          if (src && src.includes('.mp4') && src.startsWith('http')) {
            urls.push(src);
            VideoChannel.postMessage(src);
          }
          if (dataVideoUrl && dataVideoUrl.startsWith('http')) {
            urls.push(dataVideoUrl);
            VideoChannel.postMessage(dataVideoUrl);
          }
          if (dataHdUrl && dataHdUrl.startsWith('http')) {
            urls.push(dataHdUrl);
            VideoChannel.postMessage(dataHdUrl);
          }
          if (dataSdUrl && dataSdUrl.startsWith('http')) {
            urls.push(dataSdUrl);
            VideoChannel.postMessage(dataSdUrl);
          }
        }
        return urls.length;
      }
      findVideoUrls();
      setInterval(findVideoUrls, 3000);
    ''');
  }

  void _onVideoDetected(String url) {
    if (detectedVideoUrl == url) return;

    setState(() {
      detectedVideoUrl = url;
      _isVideoDetected = true;
    });

    _fetchFileSizes(url);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isVideoDetected && !_isDownloading) {
        setState(() => _isVideoDetected = false);
      }
    });
  }

  // Only used for the popup card estimates, NOT for download progress
  Future<void> _fetchFileSizes(String videoUrl) async {
    setState(() => _isFetchingSizes = true);

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Referer': AppEnv.facebookReferer,
      };

      try {
        final response = await dio.head(videoUrl);
        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          final bytes = int.parse(contentLength);
          setState(() {
            _hdSize = _formatFileSize(bytes);
            _sdSize = _formatFileSize((bytes * 0.5).round());
          });
        }
      } catch (e) {
        debugPrint('Error fetching HD size: $e');
      }

      if (_hdSize != null) {
        setState(() {
          _audioSize = _formatFileSize(
            (_parseSizeToBytes(_hdSize!) * 0.12).round(),
          );
        });
      }

      try {
        final jsResult = await _controller.runJavaScriptReturningResult('''
          (function() {
            const elements = document.querySelectorAll('[data-sd-url], [data-quality-sd], [data-video-sd]');
            for (const element of elements) {
              const sdUrl = element.getAttribute('data-sd-url') ||
                           element.getAttribute('data-quality-sd') ||
                           element.getAttribute('data-video-sd');
              if (sdUrl && sdUrl.startsWith('http')) {
                return sdUrl;
              }
            }
            return '';
          })();
        ''');

        if (jsResult != null &&
            jsResult.toString().isNotEmpty &&
            jsResult.toString() != 'null' &&
            jsResult.toString() != '' &&
            jsResult.toString().startsWith('http')) {
          final sdResponse = await dio.head(jsResult.toString());
          final sdContentLength = sdResponse.headers.value('content-length');
          if (sdContentLength != null) {
            setState(() {
              _sdSize = _formatFileSize(int.parse(sdContentLength));
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching SD size: $e');
      }
    } catch (e) {
      debugPrint('Error fetching file sizes: $e');
      setState(() {
        _hdSize = null;
        _sdSize = null;
        _audioSize = null;
      });
    } finally {
      setState(() => _isFetchingSizes = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  int _parseSizeToBytes(String sizeStr) {
    final regex = RegExp(r'([\d.]+)\s*(B|KB|MB|GB)');
    final match = regex.firstMatch(sizeStr);
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(2);
      switch (unit) {
        case 'B':
          return value.round();
        case 'KB':
          return (value * 1024).round();
        case 'MB':
          return (value * 1024 * 1024).round();
        case 'GB':
          return (value * 1024 * 1024 * 1024).round();
      }
    }
    return 0;
  }

  void _startSpeedTimer() {
    _lastSpeedCalcTime = DateTime.now();
    _lastSpeedCalcBytes = _receivedBytes;
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final now = DateTime.now();
      final elapsed = now.difference(_lastSpeedCalcTime!).inMilliseconds;
      if (elapsed > 0) {
        final bytesDiff = _receivedBytes - _lastSpeedCalcBytes;
        final speedBytesPerSec = (bytesDiff / (elapsed / 1000)).round();
        String speedStr;
        if (speedBytesPerSec < 1024) {
          speedStr = '$speedBytesPerSec B/s';
        } else if (speedBytesPerSec < 1024 * 1024) {
          speedStr = '${(speedBytesPerSec / 1024).toStringAsFixed(1)} KB/s';
        } else {
          speedStr =
              '${(speedBytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
        }
        setState(() {
          _downloadSpeed = speedStr;
        });
      }
      _lastSpeedCalcTime = now;
      _lastSpeedCalcBytes = _receivedBytes;
    });
  }

  void _stopSpeedTimer() {
    _speedTimer?.cancel();
    _speedTimer = null;
  }

  /// Uses ONLY actual bytes from the download stream, never estimated card sizes
  void _updateProgress(int received, int total) {
    _receivedBytes = received;

    // Only trust the total if server actually sent Content-Length (> 0 and not -1)
    if (total > 0 && total != -1) {
      _actualTotalBytes = total;
      _totalKnown = true;
      _downloadProgress = (received / total).clamp(0.0, 1.0);

      // Build status text showing ETA only, no file size
      String statusText = '';

      // Calculate ETA
      final remaining = _actualTotalBytes - _receivedBytes;
      if (remaining > 0 &&
          _downloadSpeed != '0 KB/s' &&
          _downloadSpeed != '0 B/s') {
        final speedBytes = _parseSpeedToBytes(_downloadSpeed);
        if (speedBytes > 0) {
          final remainingSecs = remaining / speedBytes;
          final mins = (remainingSecs / 60).floor();
          final secs = (remainingSecs % 60).floor();
          if (mins > 0) {
            statusText = '${mins}m ${secs}s left';
          } else {
            statusText = '${secs}s left';
          }
        }
      }

      setState(() {
        _downloadStatus = statusText;
      });
    } else {
      // Server didn't send Content-Length — total is unknown
      _totalKnown = false;
      setState(() {
        _downloadStatus = 'Downloading...';
      });
    }
  }

  int _parseSpeedToBytes(String speedStr) {
    final regex = RegExp(r'([\d.]+)\s*(B/s|KB/s|MB/s)');
    final match = regex.firstMatch(speedStr);
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(2);
      switch (unit) {
        case 'B/s':
          return value.round();
        case 'KB/s':
          return (value * 1024).round();
        case 'MB/s':
          return (value * 1024 * 1024).round();
      }
    }
    return 0;
  }

  void _showDownloadOptionsPopup() {
    final localizations = AppLocalizations.of(context);

    if (detectedVideoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.extract_video_id_error ??
                'No video detected yet. Please wait.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext sheetContext) {
        return _DownloadQualityBottomSheet(
          localizations: localizations,
          isFetchingSizes: _isFetchingSizes,
          hdSize: _hdSize,
          sdSize: _sdSize,
          audioSize: _audioSize,
          onWatch: () => Navigator.pop(sheetContext),
          onDownloadTier: _onDownloadTierSelected,
        );
      },
    );
  }

  Future<void> _onDownloadTierSelected(
    String tier,
    String historyQualityLabel,
    String? expectedSize,
  ) async {
    if (!mounted) return;
    if (tier == 'Audio') {
      await _extractAndDownloadAudio(historyQualityLabel, expectedSize);
    } else {
      await _downloadVideo(tier, historyQualityLabel, expectedSize);
    }
  }

  Future<void> _extractAndDownloadAudio(
    String historyQualityLabel,
    String? audioSize,
  ) async {
    final localizations = AppLocalizations.of(context);

    if (detectedVideoUrl == null) return;

    _resetProgressState(
      historyQualityLabel,
      expectedSize: audioSize,
      isAudio: true,
    );
    setState(() {
      _downloadStatus =
          localizations?.extracting_audio ?? 'Extracting audio from video...';
    });
    _startSpeedTimer();

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

    try {
      final savePath = await _downloadAudioFile(
        detectedVideoUrl!,
        fileName,
        historyQualityLabel,
      );
      _stopSpeedTimer();

      if (savePath != null && mounted) {
        setState(() {
          _isDownloading = false;
          _lastDownloadedFilePath = savePath;
          _lastDownloadedFileName = fileName;
        });
        _showSuccessDialog(fileName, savePath, isAudio: true);
      } else {
        throw Exception('Audio extraction failed');
      }
    } catch (e) {
      _stopSpeedTimer();
      setState(() => _isDownloading = false);
      _showErrorDialog(
        '${localizations?.download_failed ?? 'Audio extraction failed'}: ${e.toString().substring(0, 100)}',
      );
    }
  }

  Future<String?> _downloadAudioFile(
    String url,
    String fileName,
    String historyQualityLabel,
  ) async {
    final localizations = AppLocalizations.of(context);

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Referer': AppEnv.facebookReferer,
      };

      final String savePath;
      if (Platform.isAndroid) {
        final musicDir = Directory('/storage/emulated/0/Music');
        if (await musicDir.exists()) {
          savePath = path.join(musicDir.path, fileName);
        } else {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          savePath = path.join(downloadsDir.path, fileName);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = path.join(directory.path, fileName);
      }

      final tempDir = await getTemporaryDirectory();
      final tempVideoPath = path.join(
        tempDir.path,
        'vd_audio_src_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await dio.download(
        url,
        tempVideoPath,
        onReceiveProgress: (received, total) {
          _updateProgress(received, total);
        },
      );

      if (mounted) {
        setState(() {
          _downloadProgress = 0.0;
          _totalKnown = false;
          _downloadStatus =
              localizations?.extracting ?? 'Converting to MP3...';
        });
      }

      if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
        debugPrint(
          'Audio extraction: FFmpeg is only bundled for Android, iOS, and macOS.',
        );
        try {
          await File(tempVideoPath).delete();
        } catch (_) {}
        return null;
      }

      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        tempVideoPath,
        '-vn',
        '-acodec',
        'libmp3lame',
        '-q:a',
        '4',
        savePath,
      ]);
      final returnCode = await session.getReturnCode();

      try {
        final tmp = File(tempVideoPath);
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}

      if (!ReturnCode.isSuccess(returnCode)) {
        try {
          final out = File(savePath);
          if (await out.exists()) await out.delete();
        } catch (_) {}
        debugPrint(
          'FFmpeg MP3 conversion failed: ${await session.getOutput()}',
        );
        return null;
      }

      if (!mounted) return null;
      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: historyQualityLabel,
      );
      await downloadController.loadHistory();

      return savePath;
    } catch (e) {
      debugPrint('Audio extraction error: $e');
      return null;
    }
  }

  Future<void> _downloadVideo(
    String quality,
    String historyQualityLabel,
    String? expectedSize,
  ) async {
    final localizations = AppLocalizations.of(context);

    if (detectedVideoUrl == null) return;

    _resetProgressState(
      historyQualityLabel,
      expectedSize: expectedSize,
      isSdVideo: quality == 'SD',
    );
    setState(() {
      _downloadStatus =
          localizations?.processing_link ?? 'Preparing download...';
    });
    _startSpeedTimer();

    String fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}_$quality.mp4';

    try {
      String videoUrl = detectedVideoUrl!;

      if (quality == 'HD') {
        setState(() {
          _downloadStatus =
              localizations?.processing_video ?? 'Searching for HD version...';
        });

        final betterUrl = await _findBestQualityVideo();
        if (betterUrl != videoUrl) {
          videoUrl = betterUrl;
          setState(() {
            _downloadStatus =
                localizations?.video_ready ??
                'HD version found! Downloading...';
          });
        } else {
          setState(() {
            _downloadStatus =
                localizations?.not_available_message ??
                'HD not available, downloading best available...';
          });
        }
      } else if (quality == 'SD') {
        setState(() {
          _downloadStatus =
              localizations?.processing_video ?? 'Searching for SD version...';
        });

        final sdUrl = await _findSdQualityVideo();
        if (sdUrl.isNotEmpty && sdUrl.startsWith('http')) {
          videoUrl = sdUrl;
          if (mounted) {
            setState(() {
              _downloadStatus = sdUrl == detectedVideoUrl
                  ? (localizations?.not_available_message ??
                      'No separate SD link; downloading detected stream...')
                  : ((localizations?.video_ready) ?? 'SD version found! Downloading...');
            });
          }
        } else {
          setState(() {
            _downloadStatus =
                localizations?.not_available_message ??
                'SD not available, downloading best available...';
          });
        }
      }

      final savePath =
          await _downloadFile(videoUrl, fileName, historyQualityLabel);
      _stopSpeedTimer();

      if (savePath != null && mounted) {
        setState(() {
          _isDownloading = false;
          _lastDownloadedFilePath = savePath;
          _lastDownloadedFileName = fileName;
        });
        _showSuccessDialog(fileName, savePath);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      _stopSpeedTimer();
      setState(() => _isDownloading = false);
      _showErrorDialog(
        '${localizations?.download_failed ?? 'Download failed'}: ${e.toString().substring(0, 100)}',
      );
    }
  }

  /// Reset all progress trackers to zero — no estimated sizes leak through
  void _resetProgressState(
    String qualityLabel, {
    String? expectedSize,
    bool isAudio = false,
    bool isSdVideo = false,
  }) {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadQualityLabel = qualityLabel;
      _downloadIsAudio = isAudio;
      _downloadProgressIsSdVideo = isSdVideo && !isAudio;
      _selectedDownloadSize = expectedSize;
      // ACTUAL download state — all zeroed
      _receivedBytes = 0;
      _actualTotalBytes = 0;
      _totalKnown = false;
      _downloadSpeed = '0 KB/s';
    });
  }

  Future<String> _findBestQualityVideo() async {
    String bestUrl = detectedVideoUrl!;

    try {
      final jsResult = await _controller.runJavaScriptReturningResult('''
        (function() {
          let bestUrl = '';
          let bestQuality = 0;

          const videos = document.querySelectorAll('video');
          for (const video of videos) {
            if (video.src && video.src.startsWith('http')) {
              let quality = 0;
              if (video.src.includes('1080') || video.src.includes('hd') ||
                  video.src.includes('high') || video.src.includes('original')) {
                quality = 1080;
              } else if (video.src.includes('720')) {
                quality = 720;
              } else if (video.src.includes('480')) {
                quality = 480;
              } else if (video.src.includes('360')) {
                quality = 360;
              } else {
                quality = 480;
              }

              if (quality > bestQuality) {
                bestQuality = quality;
                bestUrl = video.src;
              }
            }

            const sources = video.querySelectorAll('source');
            for (const source of sources) {
              if (source.src && source.src.startsWith('http')) {
                let quality = 0;
                if (source.src.includes('1080') || source.src.includes('hd')) {
                  quality = 1080;
                } else if (source.src.includes('720')) {
                  quality = 720;
                } else if (source.src.includes('480')) {
                  quality = 480;
                } else if (source.src.includes('360')) {
                  quality = 360;
                }

                if (quality > bestQuality) {
                  bestQuality = quality;
                  bestUrl = source.src;
                }
              }
            }
          }

          const elements = document.querySelectorAll('[data-hd-url], [data-quality-hd], [data-video-hd]');
          for (const element of elements) {
            const hdUrl = element.getAttribute('data-hd-url') ||
                         element.getAttribute('data-quality-hd') ||
                         element.getAttribute('data-video-hd');
            if (hdUrl && hdUrl.startsWith('http')) {
              return hdUrl;
            }
          }

          return bestUrl || '';
        })();
      ''');

      if (jsResult != null &&
          jsResult.toString().isNotEmpty &&
          jsResult.toString() != 'null' &&
          jsResult.toString() != '') {
        String foundUrl = jsResult.toString();
        if (foundUrl.startsWith('http')) {
          debugPrint('Found better quality URL: $foundUrl');
          return foundUrl;
        }
      }
    } catch (e) {
      debugPrint('Error finding better quality: $e');
    }

    return bestUrl;
  }

  /// Resolves a lower-bitrate URL when the page exposes SD data attributes or
  /// multiple [video]/[source] URLs (picks the lowest scored candidate).
  Future<String> _findSdQualityVideo() async {
    final fallback = detectedVideoUrl ?? '';

    try {
      final jsResult = await _controller.runJavaScriptReturningResult('''
        (function() {
          const sdElements = document.querySelectorAll('[data-sd-url], [data-quality-sd], [data-video-sd]');
          for (const element of sdElements) {
            const sdUrl = element.getAttribute('data-sd-url') ||
                         element.getAttribute('data-quality-sd') ||
                         element.getAttribute('data-video-sd');
            if (sdUrl && sdUrl.startsWith('http')) return sdUrl;
          }

          function qualityScore(url) {
            if (!url || !url.startsWith('http')) return -1;
            const u = url.toLowerCase();
            if (u.includes('144')) return 144;
            if (u.includes('240')) return 240;
            if (u.includes('270')) return 270;
            if (u.includes('360')) return 360;
            if (u.includes('sd') && u.includes('low')) return 350;
            if (u.includes('low')) return 400;
            if (u.includes('480')) return 480;
            if (u.includes('540')) return 540;
            if (u.includes('576')) return 576;
            if (u.includes('720')) return 720;
            if (u.includes('1080')) return 1080;
            if (u.includes('hd')) return 650;
            return 500;
          }

          let bestScore = 999999;
          let bestUrl = '';

          const videos = document.querySelectorAll('video');
          for (const video of videos) {
            const candidates = [];
            if (video.src && video.src.startsWith('http')) candidates.push(video.src);
            const sources = video.querySelectorAll('source');
            for (const source of sources) {
              if (source.src && source.src.startsWith('http')) candidates.push(source.src);
            }
            for (const u of candidates) {
              const s = qualityScore(u);
              if (s >= 0 && s < bestScore) {
                bestScore = s;
                bestUrl = u;
              }
            }
          }
          return bestUrl || '';
        })();
      ''');

      if (jsResult != null) {
        final s = jsResult.toString();
        if (s.isNotEmpty && s != 'null' && s.startsWith('http')) {
          return s;
        }
      }
    } catch (e) {
      debugPrint('Error finding SD quality: $e');
    }

    return fallback;
  }

  Future<String?> _downloadFile(
    String url,
    String fileName,
    String historyQualityLabel,
  ) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Referer': AppEnv.facebookReferer,
      };

      String savePath;
      if (Platform.isAndroid) {
        final moviesDir = Directory('/storage/emulated/0/Movies');
        if (await moviesDir.exists()) {
          savePath = '${moviesDir.path}/$fileName';
        } else {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          savePath = '${downloadsDir.path}/$fileName';
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath = '${directory.path}/$fileName';
      }

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          _updateProgress(received, total);
        },
      );

      if (!mounted) return null;
      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: historyQualityLabel,
      );

      await downloadController.loadHistory();

      debugPrint('✅ Download completed and saved to history: $fileName');

      return savePath;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  void _showSuccessDialog(
    String fileName,
    String filePath, {
    bool isAudio = false,
  }) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isAudio
                        ? const LinearGradient(
                            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAudio ? Icons.audiotrack : Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isAudio
                      ? (localizations?.download_success_audio ??
                            'Audio Extracted!')
                      : (localizations?.download_success_video ??
                            'Download Complete!'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fileName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAudio ? Icons.music_note : Icons.folder,
                        color: const Color(0xFF0066ff),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAudio
                                  ? (localizations?.saved_to_music ??
                                        'Saved to:')
                                  : (localizations?.saved_to_movies ??
                                        'Saved to:'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Platform.isAndroid
                                  ? (isAudio
                                        ? (localizations?.saved_to_music ??
                                              'Music folder')
                                        : (localizations?.saved_to_movies ??
                                              'Movies folder'))
                                  : 'Documents',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0066ff)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(localizations?.ok ?? 'Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          localizations?.view_in_history ?? 'History',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    color: Colors.red.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.download_failed ?? 'Download Failed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066ff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations?.ok ?? 'OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openInChrome(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final percentage = (_downloadProgress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066ff),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations?.appTitle ?? 'Video Downloader Browser',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () => openInChrome(widget.url),
            tooltip: localizations?.open_app ?? 'Open in Browser',
          ),
          if (detectedVideoUrl != null && !_isDownloading)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: _showDownloadOptionsPopup,
                  tooltip:
                      localizations?.download_options ?? 'Download Options',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0066ff),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations?.loading_video_player ??
                                'Loading video player...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isVideoDetected && !_isDownloading && !_isLoading)
            Positioned(
              top: 60,
              right: 10,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: _showDownloadOptionsPopup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localizations?.video_detected ??
                                  'Video Detected! Tap to Download',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_isDownloading)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row 1: Icon + Title + Percentage
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0066ff),
                                        Color(0xFF1f83ff),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.downloading,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _downloadQualityLabel.isNotEmpty
                                            ? _downloadQualityLabel
                                            : (localizations
                                                      ?.downloading_video ??
                                                  'Downloading Video'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (_selectedDownloadSize !=
                                          null &&
                                          _selectedDownloadSize!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '~ ${_selectedDownloadSize!}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 2),
                                      Text(
                                        _downloadStatus,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Percentage — real from stream, or spinner if unknown
                                _totalKnown
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF0066ff,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '$percentage%',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0066ff),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                const Color(
                                                  0xFF0066ff,
                                                ).withOpacity(0.6),
                                              ),
                                        ),
                                      ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Row 2: Speed only - no file size information
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.speed,
                                          size: 13,
                                          color: Colors.orange.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _downloadSpeed,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Row 3: Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  if (_totalKnown)
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      height: 10,
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: _downloadProgress.clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0066ff),
                                                Color(0xFF00ccff),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF0066ff,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    // Indeterminate shimmer bar when total unknown
                                    Container(
                                      height: 10,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: _buildIndeterminateBar(),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Row 4: Quality badge + Active
                            Row(
                              children: [
                                Builder(
                                  builder: (ctx) {
                                    final Color tintBg;
                                    final Color tintFg;
                                    final IconData qIcon;
                                    if (_downloadIsAudio) {
                                      tintBg = Colors.green.shade50;
                                      tintFg = Colors.green.shade700;
                                      qIcon = Icons.audiotrack;
                                    } else if (_downloadProgressIsSdVideo) {
                                      tintBg = Colors.grey.shade100;
                                      tintFg = Colors.grey.shade800;
                                      qIcon = Icons.sd_storage;
                                    } else {
                                      tintBg = Colors.blue.shade50;
                                      tintFg = Colors.blue.shade700;
                                      qIcon = Icons.high_quality;
                                    }
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tintBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            qIcon,
                                            size: 12,
                                            color: tintFg.withOpacity(0.88),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _downloadQualityLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: tintFg,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        localizations?.active ?? 'Active',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Animated indeterminate progress bar for when total size is unknown
  Widget _buildIndeterminateBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment(value.clamp(-1.0, 1.0), 0.0),
            widthFactor: 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066ff), Color(0xFF00ccff)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isDownloading && !_totalKnown) {
          setState(() {});
        }
      },
    );
  }
}

typedef _DownloadTierChosen = Future<void> Function(
  String tier,
  String historyQualityLabel,
  String? expectedSize,
);

class _DownloadQualityBottomSheet extends StatefulWidget {
  final AppLocalizations? localizations;
  final bool isFetchingSizes;
  final String? hdSize;
  final String? sdSize;
  final String? audioSize;
  final VoidCallback onWatch;
  final _DownloadTierChosen onDownloadTier;

  const _DownloadQualityBottomSheet({
    required this.localizations,
    required this.isFetchingSizes,
    required this.hdSize,
    required this.sdSize,
    required this.audioSize,
    required this.onWatch,
    required this.onDownloadTier,
  });

  @override
  State<_DownloadQualityBottomSheet> createState() =>
      _DownloadQualityBottomSheetState();
}

class _DownloadQualityBottomSheetState extends State<_DownloadQualityBottomSheet> {
  static const String _kHd = 'HD';
  static const String _kSd = 'SD';
  static const String _kAudio = 'Audio';

  String? _picked;

  String _historyLabel(String tier) {
    final l = widget.localizations;
    switch (tier) {
      case _kHd:
        return l?.high_quality ?? 'High Quality';
      case _kSd:
        return l?.low_quality ?? 'Low Quality';
      case _kAudio:
        return l?.audio_only_title ?? 'Audio Only';
      default:
        return tier;
    }
  }

  String? _estimateForTier(String tier) {
    switch (tier) {
      case _kHd:
        return widget.hdSize;
      case _kSd:
        return widget.sdSize;
      case _kAudio:
        return widget.audioSize;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.localizations;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: Color(0xFF0066ff),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n?.download_options ?? 'Download Video',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.video_library,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.video_detected_message ??
                          'Video detected! Choose download option',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _DownloadTierOptionCard(
              title: l10n?.high_quality ?? 'High Quality',
              size: widget.hdSize ?? 'Calculating...',
              icon: Icons.high_quality,
              gradient: const LinearGradient(
                colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              ),
              color: Colors.blue,
              description:
                  l10n?.full_hd_best_quality ?? 'High Definition',
              isLoading: widget.isFetchingSizes && widget.hdSize == null,
              isSelected: _picked == _kHd,
              onTap: () => setState(() => _picked = _kHd),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: l10n?.low_quality ?? 'Low Quality',
              size: widget.sdSize ?? 'Calculating...',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
              ),
              color: Colors.grey,
              description:
                  l10n?.standard_quality ?? 'Standard Definition',
              isLoading: widget.isFetchingSizes && widget.sdSize == null,
              isSelected: _picked == _kSd,
              onTap: () => setState(() => _picked = _kSd),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: l10n?.audio_only_title ?? 'Audio Only',
              size: widget.audioSize ?? 'Calculating...',
              icon: Icons.audiotrack,
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              color: Colors.green,
              description: '${l10n?.mp3_128kbps ?? 'MP3'} • '
                  '${l10n?.audio_only_title ?? 'Audio Only'}',
              isLoading:
                  widget.isFetchingSizes && widget.audioSize == null,
              isSelected: _picked == _kAudio,
              onTap: () => setState(() => _picked = _kAudio),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onWatch,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: Text(
                      l10n?.watchVideo ?? 'Watch',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0066ff),
                      side: const BorderSide(
                        color: Color(0xFF0066ff),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isFetchingSizes || _picked == null
                        ? null
                        : () async {
                            final tier = _picked!;
                            final label = _historyLabel(tier);
                            final hint = _estimateForTier(tier);
                            Navigator.pop(context);
                            await widget.onDownloadTier(
                              tier,
                              label,
                              hint,
                            );
                          },
                    icon: const Icon(
                      Icons.download,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: Text(
                      _picked == null
                          ? 'Select quality'
                          : '${l10n?.download ?? 'Download'} '
                                '${_historyLabel(_picked!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066ff),
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DownloadTierOptionCard extends StatelessWidget {
  final String title;
  final String size;
  final IconData icon;
  final Gradient gradient;
  final Color color;
  final String description;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback onTap;

  const _DownloadTierOptionCard({
    required this.title,
    required this.size,
    required this.icon,
    required this.gradient,
    required this.color,
    required this.description,
    required this.isLoading,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          color.withOpacity(0.6),
                        ),
                      ),
                    )
                  else
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: color, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isSelected ? Colors.white : color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSelected ? 'Selected' : 'Select',
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
