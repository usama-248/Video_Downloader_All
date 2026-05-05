// ignore_for_file: unnecessary_null_comparison, unused_field

import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:facebook_video_downloader/features/history/history_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initWebView();
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

        const allElements = document.querySelectorAll('[src*=".mp4"], [data-video-url], [data-hd-url]');
        for (const element of allElements) {
          const src = element.getAttribute('src');
          const dataVideoUrl = element.getAttribute('data-video-url');
          const dataHdUrl = element.getAttribute('data-hd-url');
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

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isVideoDetected && !_isDownloading) {
        setState(() => _isVideoDetected = false);
      }
    });
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                            localizations?.download_options ??
                                'Download Options',
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
                              localizations?.video_detected_message ??
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
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.video_settings,
                          size: 20,
                          color: Color(0xFF0066ff),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations?.video_quality ?? 'VIDEO QUALITY',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildQualityCard(
                      title: localizations?.pro_badge != null
                          ? '1080p HD ${localizations!.pro_badge}'
                          : '1080p HD Pro',
                      quality: '1080p',
                      icon: Icons.photo_size_select_large,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                      size: '~30-50 MB',
                      color: Colors.purple,
                      description:
                          localizations?.full_hd_best_quality ??
                          'Full HD • Best Quality',
                    ),

                    const SizedBox(height: 12),

                    _buildQualityCard(
                      title: localizations?.high_quality ?? 'High Quality',
                      quality: '720p',
                      icon: Icons.high_quality,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                      ),
                      size: '~15-25 MB',
                      color: Colors.blue,
                      description: localizations?.hd_ready ?? 'HD Ready',
                    ),

                    const SizedBox(height: 12),

                    _buildQualityCard(
                      title: localizations?.medium_quality ?? 'Medium Quality',
                      quality: '480p',
                      icon: Icons.hd,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf12711), Color(0xFFf5af19)],
                      ),
                      size: '~8-12 MB',
                      color: Colors.orange,
                      description:
                          localizations?.standard_quality ?? 'Standard Quality',
                    ),

                    const SizedBox(height: 12),

                    _buildQualityCard(
                      title: localizations?.low_quality ?? 'Low Quality',
                      quality: '360p',
                      icon: Icons.sd_storage,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
                      ),
                      size: '~4-6 MB',
                      color: Colors.grey,
                      description: localizations?.small_size ?? 'Small Size',
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.audiotrack,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations?.audio_only ?? 'AUDIO ONLY',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildAudioCard(
                      title: localizations?.audio_only_title ?? 'Audio Only',
                      format: 'MP3',
                      bitrate: localizations?.mp3_128kbps ?? '128 kbps',
                      icon: Icons.music_note,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                      ),
                      size: '~3-5 MB',
                      color: Colors.green,
                      description:
                          localizations?.extract_audio_from_video ??
                          'Extract audio from video',
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        localizations?.cancel ?? 'Cancel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQualityCard({
    required String title,
    required String quality,
    required IconData icon,
    required Gradient gradient,
    required String size,
    required Color color,
    required String description,
  }) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _downloadVideo(quality);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (quality == '1080p') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations?.pro_badge ?? 'PRO',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quality • $size',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      localizations?.download ?? 'Download',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioCard({
    required String title,
    required String format,
    required String bitrate,
    required IconData icon,
    required Gradient gradient,
    required String size,
    required Color color,
    required String description,
  }) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _extractAndDownloadAudio();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            format,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bitrate • $size',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      localizations?.extract_audio ?? 'Extract',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _extractAndDownloadAudio() async {
    final localizations = AppLocalizations.of(context);

    if (detectedVideoUrl == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus =
          localizations?.extracting_audio ?? 'Extracting audio from video...';
    });

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

    try {
      final savePath = await _downloadAudioFile(detectedVideoUrl!, fileName);

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
      setState(() => _isDownloading = false);
      _showErrorDialog(
        '${localizations?.download_failed ?? 'Audio extraction failed'}: ${e.toString().substring(0, 100)}',
      );
    }
  }

  Future<String?> _downloadAudioFile(String url, String fileName) async {
    final localizations = AppLocalizations.of(context);

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
        'Referer': 'https://www.facebook.com/',
      };

      String savePath;
      if (Platform.isAndroid) {
        final musicDir = Directory('/storage/emulated/0/Music');
        if (await musicDir.exists()) {
          savePath = '${musicDir.path}/$fileName';
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
          if (total > 0) {
            final progress = received / total;
            final receivedMB = received / 1024 / 1024;
            final totalMB = total / 1024 / 1024;
            setState(() {
              _downloadProgress = progress;
              _downloadStatus =
                  '${localizations?.extracting ?? 'Extracting'}: ${receivedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB';
            });
          }
        },
      );

      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: 'MP3 Audio',
      );

      return savePath;
    } catch (e) {
      debugPrint('Audio extraction error: $e');
      return null;
    }
  }

  Future<void> _downloadVideo(String quality) async {
    final localizations = AppLocalizations.of(context);

    if (detectedVideoUrl == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus =
          localizations?.processing_link ?? 'Preparing download...';
    });

    String fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}_$quality.mp4';

    try {
      String videoUrl = detectedVideoUrl!;

      // For 1080p, try to find better quality
      if (quality == '1080p') {
        setState(() {
          _downloadStatus =
              localizations?.processing_video ??
              'Searching for 1080p version...';
        });

        final betterUrl = await _findBestQualityVideo();
        if (betterUrl != videoUrl) {
          videoUrl = betterUrl;
          setState(() {
            _downloadStatus =
                localizations?.video_ready ??
                '1080p version found! Downloading...';
          });
        } else {
          setState(() {
            _downloadStatus =
                localizations?.not_available_message ??
                '1080p not available, downloading best available...';
          });
        }
      }

      final savePath = await _downloadFile(videoUrl, fileName, quality);

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
      setState(() => _isDownloading = false);

      // If 1080p failed, offer to try 720p
      if (quality == '1080p') {
        _show1080pNotAvailableDialog();
      } else {
        _showErrorDialog(
          '${localizations?.download_failed ?? 'Download failed'}: ${e.toString().substring(0, 100)}',
        );
      }
    }
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

  Future<String?> _downloadFile(
    String url,
    String fileName,
    String quality,
  ) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Referer': 'https://www.facebook.com/',
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
          if (total > 0) {
            final progress = received / total;
            final receivedMB = received / 1024 / 1024;
            final totalMB = total / 1024 / 1024;
            setState(() {
              _downloadProgress = progress;
              _downloadStatus =
                  '${receivedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB';
            });
          } else {
            final receivedMB = received / 1024 / 1024;
            setState(() {
              _downloadProgress = 0.5;
              _downloadStatus =
                  '${AppLocalizations.of(context)?.downloading ?? 'Downloading'}: ${receivedMB.toStringAsFixed(1)} MB...';
            });
          }
        },
      );

      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: quality,
      );

      await downloadController.loadHistory();

      debugPrint('✅ Download completed and saved to history: $fileName');

      return savePath;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  void _show1080pNotAvailableDialog() {
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
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning,
                    color: Colors.orange.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations?.not_available ?? '1080p Not Available',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations?.not_available_message ??
                      'This video does not have a 1080p version available. Would you like to download in 720p instead?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
                        ),
                        child: Text(localizations?.cancel ?? 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadVideo('720p');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations?.download_720p ?? 'Download 720p',
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
                                        'Saved to Music:')
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
                const SizedBox(height: 20),
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
                        ),
                        child: Text(
                          localizations?.view_in_history ?? 'View in History',
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066ff),
        leading: IconButton(
          // ADD THIS
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
            tooltip: localizations?.open_facebook ?? 'Open in Browser',
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
              left: 20,
              right: 20,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0066ff),
                                        Color(0xFF1f83ff),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.downloading,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations?.downloading_video ??
                                            'Downloading Video',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        _downloadStatus,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0066ff,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0066ff),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _downloadProgress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0066ff),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.speed,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _downloadStatus.contains('Extracting')
                                      ? (localizations?.extracting ??
                                            'Extracting audio...')
                                      : (localizations?.downloading ??
                                            'Downloading...'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
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
                                        width: 6,
                                        height: 6,
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
}

