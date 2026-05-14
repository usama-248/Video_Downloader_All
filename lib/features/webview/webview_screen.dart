

// ignore_for_file: unused_local_variable, unused_element, unnecessary_null_comparison, unused_field
// ignore_for_file: unused_local_variable, unused_element, unnecessary_null_comparison, unused_field
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
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Add your REAL Ad Unit IDs here
const String rewardedAdUnitId =
    'ca-app-pub-3605518487927639/1811413333'; // REAL Rewarded ad unit ID
const String interstitialAdUnitIdForDownload =
    'ca-app-pub-3605518487927639/3124495001'; // REAL Interstitial ad unit ID

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

  // Rewarded Ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  String? _pendingFilePath;
  String? _pendingFileName;
  bool _isAudioPending = false;

  // Interstitial Ad for Download variables
  InterstitialAd? _interstitialAdForDownload;
  bool _isInterstitialAdForDownloadLoaded = false;
  Completer<void>? _interstitialAdCompleter;
  String? _pendingTier;
  String? _pendingHistoryLabel;
  String? _pendingExpectedSize;

  // File sizes for different qualities
  String? _size1080p;
  String? _size720p;
  String? _size480p;
  String? _size360p;
  String? _size144p;
  String? _audioSize128kbps;
  String? _audioSize192kbps;
  String? _audioSize320kbps;
  bool _isFetchingSizes = false;

  // ACTUAL download progress tracking from the real download stream
  int _receivedBytes = 0;
  int _actualTotalBytes = 0;
  bool _totalKnown = false;
  String _downloadSpeed = '0 KB/s';
  String _downloadQualityLabel = '';
  DateTime? _lastSpeedCalcTime;
  int _lastSpeedCalcBytes = 0;
  Timer? _speedTimer;

  // Store the selected download size for consistent display
  String? _selectedDownloadSize;
  String? _selectedDownloadQuality;

  bool _downloadIsAudio = false;
  bool _downloadProgressIsLowQuality = false;

  // Store selected audio bitrate
  String? _selectedAudioBitrate;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initWebView();
    _loadRewardedAd();
    _loadInterstitialAdForDownload();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
              _isRewardedAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
              _isRewardedAdLoaded = false;
              if (_pendingFilePath != null) {
                _navigateToHistory();
              }
            },
          );
          setState(() {});
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  void _loadInterstitialAdForDownload() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitIdForDownload,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAdForDownload = ad;
          _isInterstitialAdForDownloadLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdForDownloadLoaded = false;
              _loadInterstitialAdForDownload();
              // Continue with download after ad is dismissed
              if (_pendingTier != null && _pendingHistoryLabel != null) {
                _continueDownload(
                  _pendingTier!,
                  _pendingHistoryLabel!,
                  _pendingExpectedSize,
                );
                _pendingTier = null;
                _pendingHistoryLabel = null;
                _pendingExpectedSize = null;
              }
              if (_interstitialAdCompleter != null &&
                  !_interstitialAdCompleter!.isCompleted) {
                _interstitialAdCompleter!.complete();
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdForDownloadLoaded = false;
              // Continue with download even if ad fails
              if (_pendingTier != null && _pendingHistoryLabel != null) {
                _continueDownload(
                  _pendingTier!,
                  _pendingHistoryLabel!,
                  _pendingExpectedSize,
                );
                _pendingTier = null;
                _pendingHistoryLabel = null;
                _pendingExpectedSize = null;
              }
              if (_interstitialAdCompleter != null &&
                  !_interstitialAdCompleter!.isCompleted) {
                _interstitialAdCompleter!.complete();
              }
            },
          );
          setState(() {});
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad for download failed to load: $error');
          _isInterstitialAdForDownloadLoaded = false;
        },
      ),
    );
  }

  void _showRewardedAdForHistory(
    String filePath,
    String fileName,
    bool isAudio,
  ) {
    _pendingFilePath = filePath;
    _pendingFileName = fileName;
    _isAudioPending = isAudio;

    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          _navigateToHistory();
        },
      );
    } else {
      print('Rewarded ad not ready, navigating without reward');
      _navigateToHistory();
    }
  }

  Future<void> _showInterstitialAdBeforeDownload(
    String tier,
    String historyLabel,
    String? expectedSize,
  ) async {
    _pendingTier = tier;
    _pendingHistoryLabel = historyLabel;
    _pendingExpectedSize = expectedSize;

    if (_isInterstitialAdForDownloadLoaded &&
        _interstitialAdForDownload != null) {
      _interstitialAdCompleter = Completer<void>();
      _interstitialAdForDownload!.show();
      await _interstitialAdCompleter!.future;
    } else {
      // If ad not loaded, continue download directly
      await _continueDownload(tier, historyLabel, expectedSize);
    }
  }

  Future<void> _continueDownload(
    String tier,
    String historyLabel,
    String? expectedSize,
  ) async {
    if (tier.startsWith('Audio_')) {
      final bitrate = tier.split('_')[1];
      await _extractAndDownloadAudio(historyLabel, expectedSize, bitrate);
    } else {
      await _downloadVideo(tier, historyLabel, expectedSize);
    }
  }

  void _navigateToHistory() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    }
    _pendingFilePath = null;
    _pendingFileName = null;
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _rewardedAd?.dispose();
    _interstitialAdForDownload?.dispose();
    super.dispose();
  }

  // ✅ FIXED: Removed MANAGE_EXTERNAL_STORAGE permission
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await Permission.photos.status.isDenied ||
          await Permission.videos.status.isDenied) {
        await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
      }

      // For older Android versions (API 32 and below)
      if (await Permission.storage.status.isDenied) {
        await Permission.storage.request();
      }
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
              _size1080p = null;
              _size720p = null;
              _size480p = null;
              _size360p = null;
              _size144p = null;
              _audioSize128kbps = null;
              _audioSize192kbps = null;
              _audioSize320kbps = null;
              _selectedDownloadSize = null;
              _selectedDownloadQuality = null;
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

          final estimatedDurationSeconds = bytes / 437500;

          setState(() {
            _size1080p = _formatFileSize(bytes);
            _size720p = _formatFileSize((bytes * 0.7).round());
            _size480p = _formatFileSize((bytes * 0.45).round());
            _size360p = _formatFileSize((bytes * 0.3).round());
            _size144p = _formatFileSize((bytes * 0.12).round());

            final audioSize128Bytes =
                (estimatedDurationSeconds * 128 * 1024 / 8).round();
            final audioSize320Bytes =
                (estimatedDurationSeconds * 320 * 1024 / 8).round();

            _audioSize128kbps = _formatFileSize(audioSize128Bytes);
            _audioSize320kbps = _formatFileSize(audioSize320Bytes);
          });
        } else {
          _setDefaultSizes();
        }
      } catch (e) {
        debugPrint('Error fetching file sizes: $e');
        _setDefaultSizes();
      }
    } catch (e) {
      debugPrint('Error fetching file sizes: $e');
      _setDefaultSizes();
    } finally {
      setState(() => _isFetchingSizes = false);
    }
  }

  void _setDefaultSizes() {
    setState(() {
      _size1080p = '~50 MB';
      _size720p = '~35 MB';
      _size480p = '~22 MB';
      _size360p = '~15 MB';
      _size144p = '~6 MB';
      _audioSize128kbps = '~5 MB';
      _audioSize320kbps = '~12 MB';
    });
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

  void _updateProgress(int received, int total) {
    _receivedBytes = received;

    if (total > 0 && total != -1) {
      _actualTotalBytes = total;
      _totalKnown = true;
      _downloadProgress = (received / total).clamp(0.0, 1.0);

      String statusText = '';
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
          size1080p: _size1080p,
          size720p: _size720p,
          size480p: _size480p,
          size360p: _size360p,
          size144p: _size144p,
          audioSize128kbps: _audioSize128kbps,
          audioSize192kbps: _audioSize192kbps,
          audioSize320kbps: _audioSize320kbps,
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

    // Store the selected quality and expected size for display
    setState(() {
      _selectedDownloadQuality = historyQualityLabel;
      _selectedDownloadSize = expectedSize;
    });

    // Show interstitial ad before starting download
    await _showInterstitialAdBeforeDownload(
      tier,
      historyQualityLabel,
      expectedSize,
    );
  }

  Future<void> _extractAndDownloadAudio(
    String historyQualityLabel,
    String? audioSize,
    String bitrate,
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

    final fileName =
        'audio_${DateTime.now().millisecondsSinceEpoch}_${bitrate}kbps.mp3';

    try {
      final savePath = await _downloadAudioFile(
        detectedVideoUrl!,
        fileName,
        historyQualityLabel,
        bitrate,
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

  // ✅ FIXED: Save audio to app's documents directory
  Future<String?> _downloadAudioFile(
    String url,
    String fileName,
    String historyQualityLabel,
    String bitrate,
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

      // Download to temp directory first
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
          _downloadStatus = localizations?.extracting ?? 'Converting to MP3...';
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

      String audioQuality;
      switch (bitrate) {
        case '320':
          audioQuality = '0';
          break;
        case '128':
          audioQuality = '4';
          break;
        default:
          audioQuality = '4';
      }

      // Create temp audio file path
      final tempAudioPath = path.join(tempDir.path, fileName);

      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        tempVideoPath,
        '-vn',
        '-acodec',
        'libmp3lame',
        '-q:a',
        audioQuality,
        tempAudioPath,
      ]);
      final returnCode = await session.getReturnCode();

      // Clean up temp video
      try {
        final tmp = File(tempVideoPath);
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}

      if (!ReturnCode.isSuccess(returnCode)) {
        try {
          final out = File(tempAudioPath);
          if (await out.exists()) await out.delete();
        } catch (_) {}
        debugPrint(
          'FFmpeg MP3 conversion failed: ${await session.getOutput()}',
        );
        return null;
      }

      if (!mounted) return null;

      // ✅ Save to app's documents directory (no special permissions needed)
      final documentsDir = await getApplicationDocumentsDirectory();
      final savedPath = path.join(documentsDir.path, fileName);
      await File(tempAudioPath).copy(savedPath);

      // Clean up temp audio
      try {
        await File(tempAudioPath).delete();
      } catch (_) {}

      final downloadController = context.read<DownloadController>();
      final savedFile = File(savedPath);
      final actualSizeBytes = await savedFile.length();

      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savedPath,
        videoUrl: url,
        quality: historyQualityLabel,
        actualFileSizeBytes: actualSizeBytes,
        estimatedSize: _selectedDownloadSize,
      );
      await downloadController.loadHistory();

      debugPrint('✅ Audio saved to: $savedPath');
      return savedPath;
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

    bool isLowQuality = quality == '144p' || quality == '360p';
    _resetProgressState(
      historyQualityLabel,
      expectedSize: expectedSize,
      isLowQuality: isLowQuality,
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

      final qualityUrl = await _findQualityVideo(quality);
      if (qualityUrl.isNotEmpty && qualityUrl.startsWith('http')) {
        videoUrl = qualityUrl;
        setState(() {
          _downloadStatus = '${quality} version found! Downloading...';
        });
      } else {
        setState(() {
          _downloadStatus =
              localizations?.not_available_message ??
              '$quality not available, downloading best available...';
        });
      }

      final savePath = await _downloadFile(
        videoUrl,
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

  void _resetProgressState(
    String qualityLabel, {
    String? expectedSize,
    bool isAudio = false,
    bool isLowQuality = false,
  }) {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadQualityLabel = qualityLabel;
      _downloadIsAudio = isAudio;
      _downloadProgressIsLowQuality = isLowQuality && !isAudio;
      _selectedDownloadSize = expectedSize;
      _receivedBytes = 0;
      _actualTotalBytes = 0;
      _totalKnown = false;
      _downloadSpeed = '0 KB/s';
    });
  }

  Future<String> _findQualityVideo(String quality) async {
    String bestUrl = '';

    try {
      final qualityNum = quality.replaceAll('p', '');

      final jsResult = await _controller.runJavaScriptReturningResult('''
        (function() {
          let bestMatchUrl = '';
          let qualityScore = 0;
          const targetQuality = $qualityNum;

          const videos = document.querySelectorAll('video');
          for (const video of videos) {
            if (video.src && video.src.startsWith('http')) {
              let q = 0;
              if (video.src.includes('1080') || video.src.includes('original')) q = 1080;
              else if (video.src.includes('720')) q = 720;
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

            const sources = video.querySelectorAll('source');
            for (const source of sources) {
              if (source.src && source.src.startsWith('http')) {
                let q = 0;
                if (source.src.includes('1080')) q = 1080;
                else if (source.src.includes('720')) q = 720;
                else if (source.src.includes('480')) q = 480;
                else if (source.src.includes('360')) q = 360;
                else if (source.src.includes('240')) q = 240;
                else if (source.src.includes('144')) q = 144;
                
                if (q === targetQuality) return source.src;
                if (q > 0 && (bestMatchUrl === '' || Math.abs(q - targetQuality) < Math.abs(qualityScore - targetQuality))) {
                  bestMatchUrl = source.src;
                  qualityScore = q;
                }
              }
            }
          }

          const qualitySelectors = {
            '1080': ['[data-1080p-url]', '[data-uhd-url]', '[data-fhd-url]'],
            '720': ['[data-720p-url]', '[data-hd-url]'],
            '480': ['[data-480p-url]', '[data-sd-url]'],
            '360': ['[data-360p-url]'],
            '144': ['[data-144p-url]']
          };
          
          const selectors = qualitySelectors[targetQuality.toString()] || [];
          for (const selector of selectors) {
            const elements = document.querySelectorAll(selector);
            for (const element of elements) {
              const url = element.getAttribute(selector.replace(/[\[\]]/g, ''));
              if (url && url.startsWith('http')) return url;
            }
          }

          return bestMatchUrl;
        })();
      ''');

      if (jsResult != null &&
          jsResult.toString().isNotEmpty &&
          jsResult.toString() != 'null' &&
          jsResult.toString() != '') {
        String foundUrl = jsResult.toString();
        if (foundUrl.startsWith('http')) {
          debugPrint('Found $quality URL: $foundUrl');
          return foundUrl;
        }
      }
    } catch (e) {
      debugPrint('Error finding $quality quality video: $e');
    }

    return bestUrl.isEmpty ? detectedVideoUrl! : bestUrl;
  }

  // ✅ FIXED: Save video to app's documents directory
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

      // Save to app's documents directory (no special permissions needed)
      final documentsDir = await getApplicationDocumentsDirectory();
      final savePath = path.join(documentsDir.path, fileName);

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          _updateProgress(received, total);
        },
      );

      if (!mounted) return null;

      final savedFile = File(savePath);
      final actualSizeBytes = await savedFile.length();

      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: historyQualityLabel,
        actualFileSizeBytes: actualSizeBytes,
        estimatedSize: _selectedDownloadSize,
      );

      await downloadController.loadHistory();

      debugPrint(
        '✅ Download completed: $fileName (Actual size: ${_formatFileSize(actualSizeBytes)})',
      );

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
  }) async {
    final localizations = AppLocalizations.of(context);

    // Get actual file size
    final actualFile = File(filePath);
    final actualSizeBytes = await actualFile.length();
    final actualSizeStr = _formatFileSize(actualSizeBytes);

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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Size:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _selectedDownloadSize ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Actual Size:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            actualSizeStr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066ff),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                              'Saved to:',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'App Documents Folder',
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
                        onPressed: () {
                          Navigator.pop(context);
                          // Show rewarded ad on OK button
                          _showRewardedAdForHistory(
                            filePath,
                            fileName,
                            isAudio,
                          );
                        },
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
                          // Show rewarded ad on History button
                          _showRewardedAdForHistory(
                            filePath,
                            fileName,
                            isAudio,
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
                                      if (_selectedDownloadSize != null &&
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
                                    } else if (_downloadProgressIsLowQuality) {
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

typedef _DownloadTierChosen =
    Future<void> Function(
      String tier,
      String historyQualityLabel,
      String? expectedSize,
    );

class _DownloadQualityBottomSheet extends StatefulWidget {
  final AppLocalizations? localizations;
  final bool isFetchingSizes;
  final String? size1080p;
  final String? size720p;
  final String? size480p;
  final String? size360p;
  final String? size144p;
  final String? audioSize128kbps;
  final String? audioSize192kbps;
  final String? audioSize320kbps;
  final VoidCallback onWatch;
  final _DownloadTierChosen onDownloadTier;

  const _DownloadQualityBottomSheet({
    required this.localizations,
    required this.isFetchingSizes,
    required this.size1080p,
    required this.size720p,
    required this.size480p,
    required this.size360p,
    required this.size144p,
    required this.audioSize128kbps,
    required this.audioSize192kbps,
    required this.audioSize320kbps,
    required this.onWatch,
    required this.onDownloadTier,
  });

  @override
  State<_DownloadQualityBottomSheet> createState() =>
      _DownloadQualityBottomSheetState();
}

class _DownloadQualityBottomSheetState
    extends State<_DownloadQualityBottomSheet> {
  static const String _k1080p = '1080p';
  static const String _k720p = '720p';
  static const String _k480p = '480p';
  static const String _k360p = '360p';
  static const String _k144p = '144p';
  static const String _kAudio128 = 'Audio_128';
  static const String _kAudio320 = 'Audio_320';

  String? _picked;

  String _historyLabel(String tier) {
    final l = widget.localizations;
    switch (tier) {
      case _k1080p:
        return '1080p (Full HD)';
      case _k720p:
        return '720p (HD)';
      case _k480p:
        return '480p (SD)';
      case _k360p:
        return '360p';
      case _k144p:
        return '144p';
      case _kAudio128:
        return 'MP3 128kbps';
      case _kAudio320:
        return 'MP3 320kbps';
      default:
        return tier;
    }
  }

  String? _estimateForTier(String tier) {
    switch (tier) {
      case _k1080p:
        return widget.size1080p;
      case _k720p:
        return widget.size720p;
      case _k480p:
        return widget.size480p;
      case _k360p:
        return widget.size360p;
      case _k144p:
        return widget.size144p;
      case _kAudio128:
        return widget.audioSize128kbps;
      case _kAudio320:
        return widget.audioSize320kbps;
      default:
        return null;
    }
  }

  bool _isSelected(String tier) => _picked == tier;

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

            // Video Quality Section Title
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.video_settings,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Video Quality',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

            _DownloadTierOptionCard(
              title: '1080p',
              subtitle: 'Full HD • Best Quality',
              size: widget.size1080p ?? 'Calculating...',
              icon: Icons.high_quality,
              gradient: const LinearGradient(
                colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              ),
              color: Colors.blue,
              isLoading: widget.isFetchingSizes && widget.size1080p == null,
              isSelected: _isSelected(_k1080p),
              onTap: () => setState(() => _picked = _k1080p),
            ),
            const SizedBox(height: 12),

            _DownloadTierOptionCard(
              title: '720p',
              subtitle: 'HD • High Quality',
              size: widget.size720p ?? 'Calculating...',
              icon: Icons.high_quality,
              gradient: const LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              ),
              color: Colors.cyan,
              isLoading: widget.isFetchingSizes && widget.size720p == null,
              isSelected: _isSelected(_k720p),
              onTap: () => setState(() => _picked = _k720p),
            ),
            const SizedBox(height: 12),

            _DownloadTierOptionCard(
              title: '480p',
              subtitle: 'SD • Medium Quality',
              size: widget.size480p ?? 'Calculating...',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
              ),
              color: Colors.grey,
              isLoading: widget.isFetchingSizes && widget.size480p == null,
              isSelected: _isSelected(_k480p),
              onTap: () => setState(() => _picked = _k480p),
            ),
            const SizedBox(height: 12),

            _DownloadTierOptionCard(
              title: '360p',
              subtitle: 'Low Quality • Good for slow connections',
              size: widget.size360p ?? 'Calculating...',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 69, 86, 99), Color(0xFFEEF2F3)],
              ),
              color: const Color.fromARGB(255, 69, 86, 99),
              isLoading: widget.isFetchingSizes && widget.size360p == null,
              isSelected: _isSelected(_k360p),
              onTap: () => setState(() => _picked = _k360p),
            ),
            const SizedBox(height: 12),

            _DownloadTierOptionCard(
              title: '144p',
              subtitle: 'Very Low Quality • Smallest size',
              size: widget.size144p ?? 'Calculating...',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFFB9937A), Color(0xFFD4C5B0)],
              ),
              color: Colors.brown,
              isLoading: widget.isFetchingSizes && widget.size144p == null,
              isSelected: _isSelected(_k144p),
              onTap: () => setState(() => _picked = _k144p),
            ),
            const SizedBox(height: 20),

            // Audio Quality Section Title
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.audio_file,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Audio Quality (MP3)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            _DownloadTierOptionCard(
              title: 'MP3 128kbps',
              subtitle: 'Good Quality • Balanced file size',
              size: widget.audioSize128kbps ?? 'Calculating...',
              icon: Icons.audiotrack,
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              color: Colors.green,
              isLoading:
                  widget.isFetchingSizes && widget.audioSize128kbps == null,
              isSelected: _isSelected(_kAudio128),
              onTap: () => setState(() => _picked = _kAudio128),
            ),
            const SizedBox(height: 12),

            _DownloadTierOptionCard(
              title: 'MP3 320kbps',
              subtitle: 'Best Quality • Largest file size',
              size: widget.audioSize320kbps ?? 'Calculating...',
              icon: Icons.audiotrack,
              gradient: const LinearGradient(
                colors: [Color(0xFF0b5e0b), Color(0xFF2e7d32)],
              ),
              color: Colors.green,
              isLoading:
                  widget.isFetchingSizes && widget.audioSize320kbps == null,
              isSelected: _isSelected(_kAudio320),
              onTap: () => setState(() => _picked = _kAudio320),
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
                            await widget.onDownloadTier(tier, label, hint);
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
  final String subtitle;
  final String size;
  final IconData icon;
  final Gradient gradient;
  final Color color;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback onTap;

  const _DownloadTierOptionCard({
    required this.title,
    required this.subtitle,
    required this.size,
    required this.icon,
    required this.gradient,
    required this.color,
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color.withOpacity(0.6),
                        ),
                      ),
                    )
                  else
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: 14,
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
                      color: isSelected ? color : color.withOpacity(0.1),
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
