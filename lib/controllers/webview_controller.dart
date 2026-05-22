
// ignore_for_file: deprecated_member_use, empty_catches, avoid_print, unnecessary_null_comparison, unused_field

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gal/gal.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:facebook_video_downloader/controllers/download_controller.dart';
import 'package:facebook_video_downloader/core/config/admob_config.dart';

class WebViewControllerr extends GetxController {
  var detectedVideoUrl = Rx<String?>(null);
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var downloadStatus = ''.obs;
  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);
  var isVideoDetected = false.obs;
  var lastDownloadedFilePath = Rx<String?>(null);
  var lastDownloadedFileName = Rx<String?>(null);
  var showAutoPopup = true.obs;

  var size1080p = Rx<String?>(null);
  var size720p = Rx<String?>(null);
  var size480p = Rx<String?>(null);
  var size360p = Rx<String?>(null);
  var size144p = Rx<String?>(null);
  var audioSize128kbps = Rx<String?>(null);
  var audioSize192kbps = Rx<String?>(null);
  var audioSize320kbps = Rx<String?>(null);
  var isFetchingSizes = false.obs;

  var receivedBytes = 0.obs;
  var actualTotalBytes = 0.obs;
  var totalKnown = false.obs;
  var downloadSpeed = '0 KB/s'.obs;
  var downloadQualityLabel = ''.obs;
  var selectedDownloadSize = Rx<String?>(null);
  var selectedDownloadQuality = Rx<String?>(null);
  var downloadIsAudio = false.obs;
  var downloadProgressIsLowQuality = false.obs;

  // Progress tracking variables for UI
  var animatedProgress = 0.0.obs;
  var etaTime = ''.obs;
  var downloadedSize = '0 MB'.obs;
  var totalSize = '0 MB'.obs;
  var downloadPercentage = 0.obs;

  late WebViewController webController;
  String? _pendingFilePath;
  String? _pendingFileName;
  bool _isAudioPending = false;
  String? _pendingTier;
  String? _pendingHistoryLabel;
  String? _pendingExpectedSize;
  Completer<void>? _interstitialAdCompleter;

  RewardedAd? _rewardedAd;
  var isRewardedAdLoaded = false.obs;
  InterstitialAd? _interstitialAdForDownload;
  var isInterstitialAdForDownloadLoaded = false.obs;

  DateTime? _lastSpeedCalcTime;
  int _lastSpeedCalcBytes = 0;
  Timer? _speedTimer;
  Timer? _animationTimer;

  final String url;

  final Set<String> _capturedVideoUrls = {};
  Timer? _captureTimer;
  var isShowingDownloadPopup = false.obs;
  bool _popupShownForCurrentVideo = false;

  WebViewControllerr({required this.url});

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
    _initWebView();
    _loadRewardedAd();
    _loadInterstitialAdForDownload();
  }

  @override
  void onClose() {
    _speedTimer?.cancel();
    _animationTimer?.cancel();
    _captureTimer?.cancel();
    _rewardedAd?.dispose();
    _interstitialAdForDownload?.dispose();
    super.onClose();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.status.isDenied ||
          await Permission.videos.status.isDenied) {
        await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
      }
      if (await Permission.storage.status.isDenied) {
        await Permission.storage.request();
      }
    }
  }

  void _initWebView() {
    webController = WebViewController()
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
            isLoading.value = true;
            errorMessage.value = null;
            isVideoDetected.value = false;
            detectedVideoUrl.value = null;
            _popupShownForCurrentVideo = false;
            _resetFileSizes();
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            _injectJS();
            _startNetworkCapture();

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (detectedVideoUrl.value != null &&
                  showAutoPopup.value &&
                  !isDownloading.value &&
                  !isShowingDownloadPopup.value &&
                  !_popupShownForCurrentVideo) {
                _popupShownForCurrentVideo = true;
                _showDownloadOptionsPopup();
              }
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.errorCode == -2 ||
                error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              return;
            }
            isLoading.value = false;
            if (!error.description.contains('URL scheme')) {
              errorMessage.value = 'Failed to load page';
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith('fb://') ||
                url.startsWith('intent://') ||
                url.startsWith('tel:') ||
                url.startsWith('sms:') ||
                url.startsWith('mailto:')) {
              return NavigationDecision.prevent;
            }
            _checkUrlForVideo(url);
            return NavigationDecision.navigate;
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUrl());
  }

  void _startNetworkCapture() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!isLoading.value &&
          !isDownloading.value &&
          !_popupShownForCurrentVideo) {
        _scanForVideos();
      }
    });
  }

  void _scanForVideos() {
    webController.runJavaScript('''
      (function() {
        const videos = [];
        document.querySelectorAll('video').forEach(video => {
          if (video.src && video.src.startsWith('http')) {
            videos.push(video.src);
          }
          video.querySelectorAll('source').forEach(source => {
            if (source.src && source.src.startsWith('http')) {
              videos.push(source.src);
            }
          });
        });
        document.querySelectorAll('iframe').forEach(iframe => {
          if (iframe.src && (iframe.src.includes('.mp4') || iframe.src.includes('video'))) {
            videos.push(iframe.src);
          }
        });
        document.querySelectorAll('[data-video-url], [data-hd-url], [data-sd-url], [data-video]').forEach(el => {
          const url = el.getAttribute('data-video-url') || 
                     el.getAttribute('data-hd-url') || 
                     el.getAttribute('data-sd-url') ||
                     el.getAttribute('data-video');
          if (url && url.startsWith('http')) {
            videos.push(url);
          }
        });
        if (videos.length > 0 && videos[0]) {
          VideoChannel.postMessage(videos[0]);
        }
      })();
    ''');
  }

  void _checkUrlForVideo(String url) {
    if (!url.startsWith('http') && !url.startsWith('https')) {
      return;
    }
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.m3u8') ||
        lowerUrl.contains('/video/') ||
        lowerUrl.contains('/reel/') ||
        lowerUrl.contains('/watch')) {
      if (!_capturedVideoUrls.contains(url)) {
        _capturedVideoUrls.add(url);
        _onVideoDetected(url);
      }
    }
  }

  void _resetFileSizes() {
    size1080p.value = null;
    size720p.value = null;
    size480p.value = null;
    size360p.value = null;
    size144p.value = null;
    audioSize128kbps.value = null;
    audioSize192kbps.value = null;
    audioSize320kbps.value = null;
    selectedDownloadSize.value = null;
    selectedDownloadQuality.value = null;
    isFetchingSizes.value = false;
  }

  Future<void> _loadUrl() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final uri = Uri.parse(url);
      await webController.loadRequest(uri);
    } catch (e) {
      isLoading.value = false;
      if (!e.toString().contains('URL scheme')) {
        errorMessage.value = 'Error loading: $url';
      }
    }
  }

  void _injectJS() {
    webController.runJavaScript('''
      function findAllVideoUrls() {
        const urls = [];
        const videos = document.querySelectorAll('video');
        for (const video of videos) {
          if (video.src && video.src.startsWith('http')) {
            urls.push(video.src);
          }
          if (video.currentSrc && video.currentSrc.startsWith('http')) {
            urls.push(video.currentSrc);
          }
          const sources = video.querySelectorAll('source');
          for (const source of sources) {
            if (source.src && source.src.startsWith('http')) {
              urls.push(source.src);
            }
          }
        }
        const metaTags = document.querySelectorAll('meta[property="og:video"], meta[property="og:video:url"], meta[name="twitter:player:stream"]');
        for (const meta of metaTags) {
          const content = meta.getAttribute('content');
          if (content && content.startsWith('http')) {
            urls.push(content);
          }
        }
        if (urls.length > 0 && urls[0]) {
          VideoChannel.postMessage(urls[0]);
        }
      }
      findAllVideoUrls();
      setInterval(findAllVideoUrls, 2000);
    ''');
  }

  void _onVideoDetected(String url) {
    if (!url.contains('.mp4') &&
        !url.contains('video') &&
        !url.contains('reel') &&
        !url.contains('watch')) {
      return;
    }

    if (detectedVideoUrl.value == url) return;

    print('Video detected: $url');
    detectedVideoUrl.value = url;
    isVideoDetected.value = true;
    _popupShownForCurrentVideo = false;

    _fetchFileSizes(url);
  }

  Future<void> _fetchFileSizes(String videoUrl) async {
    isFetchingSizes.value = true;
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
      };

      try {
        final response = await dio.head(videoUrl);
        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          final bytes = int.parse(contentLength);
          totalSize.value = _formatFileSize(bytes);
          final estimatedDurationSeconds = bytes / 437500;
          size1080p.value = _formatFileSize(bytes);
          size720p.value = _formatFileSize((bytes * 0.7).round());
          size480p.value = _formatFileSize((bytes * 0.45).round());
          size360p.value = _formatFileSize((bytes * 0.3).round());
          size144p.value = _formatFileSize((bytes * 0.12).round());

          final audioSize128Bytes = (estimatedDurationSeconds * 128 * 1024 / 8)
              .round();
          final audioSize320Bytes = (estimatedDurationSeconds * 320 * 1024 / 8)
              .round();
          audioSize128kbps.value = _formatFileSize(audioSize128Bytes);
          audioSize320kbps.value = _formatFileSize(audioSize320Bytes);
        } else {
          _setDefaultSizes();
        }
      } catch (e) {
        _setDefaultSizes();
      }
    } catch (e) {
      _setDefaultSizes();
    } finally {
      isFetchingSizes.value = false;
    }
  }

  void _setDefaultSizes() {
    size1080p.value = '~50 MB';
    size720p.value = '~35 MB';
    size480p.value = '~22 MB';
    size360p.value = '~15 MB';
    size144p.value = '~6 MB';
    audioSize128kbps.value = '~5 MB';
    audioSize320kbps.value = '~12 MB';
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

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedAdLoaded.value = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
              isRewardedAdLoaded.value = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
              isRewardedAdLoaded.value = false;
              if (_pendingFilePath != null) _navigateToHistory();
            },
          );
          update();
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          isRewardedAdLoaded.value = false;
        },
      ),
    );
  }

  void _loadInterstitialAdForDownload() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAdForDownload = ad;
          isInterstitialAdForDownloadLoaded.value = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isInterstitialAdForDownloadLoaded.value = false;
              _loadInterstitialAdForDownload();
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
              isInterstitialAdForDownloadLoaded.value = false;
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
          update();
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad for download failed to load: $error');
          isInterstitialAdForDownloadLoaded.value = false;
        },
      ),
    );
  }

  void showRewardedAdForHistory(
    String filePath,
    String fileName,
    bool isAudio,
  ) {
    _pendingFilePath = filePath;
    _pendingFileName = fileName;
    _isAudioPending = isAudio;
    if (isRewardedAdLoaded.value && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) => _navigateToHistory(),
      );
    } else {
      _navigateToHistory();
    }
  }

  void _navigateToHistory() {
    Get.toNamed('/history');
    _pendingFilePath = null;
    _pendingFileName = null;
  }

  Future<void> _showInterstitialAdBeforeDownload(
    String tier,
    String historyLabel,
    String? expectedSize,
  ) async {
    _pendingTier = tier;
    _pendingHistoryLabel = historyLabel;
    _pendingExpectedSize = expectedSize;
    if (isInterstitialAdForDownloadLoaded.value &&
        _interstitialAdForDownload != null) {
      _interstitialAdCompleter = Completer<void>();
      _interstitialAdForDownload!.show();
      await _interstitialAdCompleter!.future;
    } else {
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

  void _resetProgressState(
    String qualityLabel, {
    String? expectedSize,
    bool isAudio = false,
    bool isLowQuality = false,
  }) {
    isDownloading.value = true;
    downloadProgress.value = 0.0;
    animatedProgress.value = 0.0;
    downloadQualityLabel.value = qualityLabel;
    downloadIsAudio.value = isAudio;
    downloadProgressIsLowQuality.value = isLowQuality && !isAudio;
    selectedDownloadSize.value = expectedSize;
    receivedBytes.value = 0;
    actualTotalBytes.value = 0;
    totalKnown.value = false;
    downloadSpeed.value = '0 KB/s';
    etaTime.value = '';
    downloadedSize.value = '0 MB';
    downloadPercentage.value = 0;
    downloadStatus.value = 'Starting download...';
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (animatedProgress.value < downloadProgress.value) {
        animatedProgress.value += 0.02;
        if (animatedProgress.value > downloadProgress.value) {
          animatedProgress.value = downloadProgress.value;
        }
        downloadPercentage.value = (animatedProgress.value * 100).round();
      } else if (animatedProgress.value > downloadProgress.value) {
        animatedProgress.value = downloadProgress.value;
        downloadPercentage.value = (animatedProgress.value * 100).round();
      }
    });
  }

  void _startSpeedTimer() {
    _lastSpeedCalcTime = DateTime.now();
    _lastSpeedCalcBytes = receivedBytes.value;
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastSpeedCalcTime!).inMilliseconds;
      if (elapsed > 0) {
        final bytesDiff = receivedBytes.value - _lastSpeedCalcBytes;
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
        downloadSpeed.value = speedStr;

        if (totalKnown.value && speedBytesPerSec > 0) {
          final remainingBytes = actualTotalBytes.value - receivedBytes.value;
          final remainingSeconds = remainingBytes / speedBytesPerSec;
          if (remainingSeconds > 0) {
            final minutes = (remainingSeconds / 60).floor();
            final seconds = (remainingSeconds % 60).floor();
            if (minutes > 0) {
              etaTime.value = '$minutes min ${seconds}s left';
            } else {
              etaTime.value = '${seconds}s left';
            }
            downloadStatus.value = etaTime.value;
          }
        }
        downloadedSize.value = _formatFileSize(receivedBytes.value);
      }
      _lastSpeedCalcTime = now;
      _lastSpeedCalcBytes = receivedBytes.value;
    });
  }

  void _stopSpeedTimer() {
    _speedTimer?.cancel();
    _speedTimer = null;
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void _updateProgress(int received, int total) {
    receivedBytes.value = received;
    if (total > 0 && total != -1) {
      actualTotalBytes.value = total;
      totalKnown.value = true;
      final newProgress = (received / total).clamp(0.0, 1.0);
      downloadProgress.value = newProgress;

      if (etaTime.value.isNotEmpty && etaTime.value != 'Starting download...') {
        downloadStatus.value = etaTime.value;
      } else if (downloadSpeed.value != '0 KB/s' &&
          downloadSpeed.value != '0 B/s') {
        final speedBytes = _parseSpeedToBytes(downloadSpeed.value);
        if (speedBytes > 0) {
          final remaining = actualTotalBytes.value - receivedBytes.value;
          final remainingSecs = remaining / speedBytes;
          final mins = (remainingSecs / 60).floor();
          final secs = (remainingSecs % 60).floor();
          if (mins > 0) {
            downloadStatus.value = '${mins}m ${secs}s left';
          } else {
            downloadStatus.value = '${secs}s left';
          }
        }
      }
    } else {
      totalKnown.value = false;
      if (downloadStatus.value.isEmpty ||
          downloadStatus.value == 'Starting download...') {
        downloadStatus.value = 'Downloading...';
      }
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

  Future<void> _extractAndDownloadAudio(
    String historyQualityLabel,
    String? audioSize,
    String bitrate,
  ) async {
    if (detectedVideoUrl.value == null) return;
    _resetProgressState(
      historyQualityLabel,
      expectedSize: audioSize,
      isAudio: true,
    );
    downloadStatus.value = 'Extracting audio from video...';
    _startSpeedTimer();
    final fileName =
        'audio_${DateTime.now().millisecondsSinceEpoch}_${bitrate}kbps.mp3';
    try {
      final savePath = await _downloadAudioFile(
        detectedVideoUrl.value!,
        fileName,
        historyQualityLabel,
        bitrate,
      );
      _stopSpeedTimer();
      if (savePath != null) {
        isDownloading.value = false;
        lastDownloadedFilePath.value = savePath;
        lastDownloadedFileName.value = fileName;
        _showSuccessDialog(fileName, savePath, isAudio: true);
      } else {
        throw Exception('Audio extraction failed');
      }
    } catch (e) {
      _stopSpeedTimer();
      isDownloading.value = false;
      _showErrorDialog(
        'Audio extraction failed: ${e.toString().substring(0, 100)}',
      );
    }
  }

  Future<String?> _downloadAudioFile(
    String url,
    String fileName,
    String historyQualityLabel,
    String bitrate,
  ) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
      };

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

      downloadProgress.value = 0.0;
      animatedProgress.value = 0.0;
      totalKnown.value = false;
      downloadStatus.value = 'Converting to MP3...';

      String audioQuality = bitrate == '320' ? '0' : '4';
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
      try {
        await File(tempVideoPath).delete();
      } catch (_) {}

      if (!ReturnCode.isSuccess(returnCode)) {
        try {
          await File(tempAudioPath).delete();
        } catch (_) {}
        return null;
      }

      final documentsDir = await getApplicationDocumentsDirectory();
      final savedPath = path.join(documentsDir.path, fileName);
      await File(tempAudioPath).copy(savedPath);
      try {
        await File(tempAudioPath).delete();
      } catch (_) {}

      final downloadController = Get.find<DownloadController>();
      final savedFile = File(savedPath);
      final actualSizeBytes = await savedFile.length();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savedPath,
        videoUrl: url,
        quality: historyQualityLabel,
        actualFileSizeBytes: actualSizeBytes,
        estimatedSize: selectedDownloadSize.value,
      );
      await downloadController.loadHistory();
      return savedPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadVideo(
    String quality,
    String historyQualityLabel,
    String? expectedSize,
  ) async {
    if (detectedVideoUrl.value == null) return;
    bool isLowQuality = quality == '144p' || quality == '360p';
    _resetProgressState(
      historyQualityLabel,
      expectedSize: expectedSize,
      isLowQuality: isLowQuality,
    );
    downloadStatus.value = 'Preparing download...';
    _startSpeedTimer();
    String fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}_$quality.mp4';
    try {
      String videoUrl = detectedVideoUrl.value!;
      final qualityUrl = await _findQualityVideo(quality);
      if (qualityUrl != null &&
          qualityUrl.isNotEmpty &&
          qualityUrl.startsWith('http')) {
        videoUrl = qualityUrl;
        downloadStatus.value = '$quality version found! Downloading...';
      } else {
        downloadStatus.value = 'Downloading best available quality...';
      }

      final savePath = await _downloadFile(
        videoUrl,
        fileName,
        historyQualityLabel,
      );
      _stopSpeedTimer();
      if (savePath != null) {
        isDownloading.value = false;
        lastDownloadedFilePath.value = savePath;
        lastDownloadedFileName.value = fileName;
        _showSuccessDialog(fileName, savePath);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      _stopSpeedTimer();
      isDownloading.value = false;
      _showErrorDialog('Download failed: ${e.toString().substring(0, 100)}');
    }
  }

  Future<String?> _findQualityVideo(String quality) async {
    try {
      final qualityNum = quality.replaceAll('p', '');
      final result = await webController.runJavaScriptReturningResult('''
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
              
              if (q == targetQuality) return video.src;
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

  Future<String?> _downloadFile(
    String url,
    String fileName,
    String historyQualityLabel,
  ) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
      };

      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, fileName);

      await dio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          _updateProgress(received, total);
        },
      );

      bool gallerySaved = false;
      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();
        await Gal.putVideo(tempPath);
        gallerySaved = true;
        Get.snackbar(
          'Success',
          '✓ Video saved to Gallery',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Gallery save error: $e');
      }

      final downloadController = Get.find<DownloadController>();
      final actualSizeBytes = await File(tempPath).length();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: tempPath,
        videoUrl: url,
        quality: historyQualityLabel,
        actualFileSizeBytes: actualSizeBytes,
        estimatedSize: selectedDownloadSize.value,
      );
      await downloadController.loadHistory();

      if (!gallerySaved) {
        Get.snackbar('Info', 'Video saved to app folder: $fileName');
      }
      return tempPath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  void _showSuccessDialog(
    String fileName,
    String filePath, {
    bool isAudio = false,
  }) async {
    final actualFile = File(filePath);
    final actualSizeBytes = await actualFile.length();
    final actualSizeStr = _formatFileSize(actualSizeBytes);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                isAudio ? 'Audio Extracted!' : 'Download Complete!',
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
                          selectedDownloadSize.value ?? 'Unknown',
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
                      isAudio ? Icons.music_note : Icons.video_library,
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
                            isAudio ? 'App Documents' : 'Device Gallery',
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
                        Get.back();
                        showRewardedAdForHistory(filePath, fileName, isAudio);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0066ff)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        showRewardedAdForHistory(filePath, fileName, isAudio);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'History',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: Icon(Icons.error, color: Colors.red.shade400, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Download Failed',
                style: TextStyle(
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
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066ff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadOptionsPopup() {
    if (detectedVideoUrl.value == null) {
      Get.snackbar('No Video', 'No video detected yet. Please wait.');
      return;
    }

    isShowingDownloadPopup.value = true;

    Get.bottomSheet(
      _DownloadQualityBottomSheet(
        isFetchingSizes: isFetchingSizes.value,
        size1080p: size1080p.value,
        size720p: size720p.value,
        size480p: size480p.value,
        size360p: size360p.value,
        size144p: size144p.value,
        audioSize128kbps: audioSize128kbps.value,
        audioSize192kbps: audioSize192kbps.value,
        audioSize320kbps: audioSize320kbps.value,
        onWatch: () {
          isShowingDownloadPopup.value = false;
          Get.back();
        },
        onDownloadTier: (tier, label, size) async {
          isShowingDownloadPopup.value = false;
          await onDownloadTierSelected(tier, label, size);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      isShowingDownloadPopup.value = false;
    });
  }

  Future<void> onDownloadTierSelected(
    String tier,
    String historyQualityLabel,
    String? expectedSize,
  ) async {
    selectedDownloadQuality.value = historyQualityLabel;
    selectedDownloadSize.value = expectedSize;
    await _showInterstitialAdBeforeDownload(
      tier,
      historyQualityLabel,
      expectedSize,
    );
  }

  Future<void> openInChrome(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  WebViewController get controller => webController;
}

// Download Quality Bottom Sheet
class _DownloadQualityBottomSheet extends StatefulWidget {
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
  final Function(String, String, String?) onDownloadTier;

  const _DownloadQualityBottomSheet({
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
                const Flexible(
                  child: Text(
                    'Download Video',
                    style: TextStyle(
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
                  const Expanded(
                    child: Text(
                      'Video detected! Choose download option',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
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
                  const Text(
                    'Video Quality',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            _DownloadTierOptionCard(
              title: '1080p',
              subtitle: 'Full HD • Best Quality',
              size: widget.size1080p ?? '~50 MB',
              icon: Icons.high_quality,
              gradient: const LinearGradient(
                colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              ),
              color: Colors.blue,
              isLoading: false,
              isSelected: _isSelected(_k1080p),
              onTap: () => setState(() => _picked = _k1080p),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: '720p',
              subtitle: 'HD • High Quality',
              size: widget.size720p ?? '~35 MB',
              icon: Icons.high_quality,
              gradient: const LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              ),
              color: Colors.cyan,
              isLoading: false,
              isSelected: _isSelected(_k720p),
              onTap: () => setState(() => _picked = _k720p),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: '480p',
              subtitle: 'SD • Medium Quality',
              size: widget.size480p ?? '~22 MB',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
              ),
              color: Colors.grey,
              isLoading: false,
              isSelected: _isSelected(_k480p),
              onTap: () => setState(() => _picked = _k480p),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: '360p',
              subtitle: 'Low Quality • Good for slow connections',
              size: widget.size360p ?? '~15 MB',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFF455463), Color(0xFFEEF2F3)],
              ),
              color: const Color(0xFF455463),
              isLoading: false,
              isSelected: _isSelected(_k360p),
              onTap: () => setState(() => _picked = _k360p),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: '144p',
              subtitle: 'Very Low Quality • Smallest size',
              size: widget.size144p ?? '~6 MB',
              icon: Icons.sd_storage,
              gradient: const LinearGradient(
                colors: [Color(0xFFB9937A), Color(0xFFD4C5B0)],
              ),
              color: Colors.brown,
              isLoading: false,
              isSelected: _isSelected(_k144p),
              onTap: () => setState(() => _picked = _k144p),
            ),
            const SizedBox(height: 20),
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
                  const Text(
                    'Audio Quality (MP3)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            _DownloadTierOptionCard(
              title: 'MP3 128kbps',
              subtitle: 'Good Quality • Balanced file size',
              size: widget.audioSize128kbps ?? '~5 MB',
              icon: Icons.audiotrack,
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              color: Colors.green,
              isLoading: false,
              isSelected: _isSelected(_kAudio128),
              onTap: () => setState(() => _picked = _kAudio128),
            ),
            const SizedBox(height: 12),
            _DownloadTierOptionCard(
              title: 'MP3 320kbps',
              subtitle: 'Best Quality • Largest file size',
              size: widget.audioSize320kbps ?? '~12 MB',
              icon: Icons.audiotrack,
              gradient: const LinearGradient(
                colors: [Color(0xFF0b5e0b), Color(0xFF2e7d32)],
              ),
              color: Colors.green,
              isLoading: false,
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
                    label: const Text(
                      'Watch',
                      style: TextStyle(
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
                    onPressed: _picked == null
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
                      overflow: TextOverflow.ellipsis,
                      _picked == null
                          ? 'Select quality'
                          : 'Download ${_historyLabel(_picked!)}',
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 5,
                      ),
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
      onTap: onTap,
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
