// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class WebViewScreen extends StatefulWidget {
//   final String url;

//   const WebViewScreen({super.key, required this.url});

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController controller;

//   String? detectedVideoUrl;

//   @override
//   void initState() {
//     super.initState();

//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (url) async {
//             await _injectJS();
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   // 🔥 Open in Chrome / External Browser
//   Future<void> openInChrome(String url) async {
//     final uri = Uri.parse(url);

//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }

//   Future<void> _injectJS() async {
//     await controller.runJavaScript("""
//       function detectVideo() {
//         let videos = document.getElementsByTagName('video');
//         if (videos.length > 0) {
//           let src = videos[0].src;
//           if (src) {
//             VideoChannel.postMessage(src);
//           }
//         }
//       }

//       setInterval(detectVideo, 2000);
//     """);
//   }

//   void downloadVideo() {
//     if (detectedVideoUrl == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("No video detected")));
//       return;
//     }

//     print("Download URL: $detectedVideoUrl");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Browser"),
//         actions: [
//           // 🔥 Open in Chrome button
//           IconButton(
//             icon: const Icon(Icons.open_in_browser),
//             onPressed: () {
//               openInChrome(widget.url);
//             },
//           ),

//           // Download button
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: downloadVideo,
//           ),
//         ],
//       ),

//       body: Stack(
//         children: [
//           WebViewWidget(controller: controller),

//           if (detectedVideoUrl != null)
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: FloatingActionButton(
//                 onPressed: downloadVideo,
//                 child: const Icon(Icons.download),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//working code
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:async';

// class WebViewScreen extends StatefulWidget {
//   final String url;

//   const WebViewScreen({super.key, required this.url});

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController controller;
//   String? detectedVideoUrl;
//   Timer? _videoDetectionTimer;

//   @override
//   void initState() {
//     super.initState();

//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (url) {
//             _injectJS();
//             _handleUnknownUrlScheme();
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Handle custom URL schemes
//             if (request.url.startsWith('fullscreen_video://') ||
//                 request.url.startsWith('intent://') ||
//                 request.url.startsWith('fb://')) {
//               _extractVideoFromIntent(request.url);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   void _handleUnknownUrlScheme() {
//     // Intercept console messages to catch video URLs
//     controller.runJavaScript("""
//       // Override console.log to catch video URLs
//       const originalLog = console.log;
//       console.log = function(...args) {
//         if (args[0] && typeof args[0] === 'string') {
//           if (args[0].includes('.mp4') || args[0].includes('video') || args[0].includes('.m3u8')) {
//             VideoChannel.postMessage(args[0]);
//           }
//         }
//         originalLog.apply(console, args);
//       };
//     """);
//   }

//   void _extractVideoFromIntent(String intentUrl) {
//     // Extract video URL from intent:// scheme
//     try {
//       if (intentUrl.contains('video')) {
//         // Parse intent URL to find video source
//         final regex = RegExp(r'video[^"]*\.(mp4|m3u8|mov)[^"]*');
//         final match = regex.firstMatch(intentUrl);
//         if (match != null) {
//           setState(() {
//             detectedVideoUrl = match.group(0);
//           });
//           _injectVideoDetection();
//         }
//       }
//     } catch (e) {
//       print('Error extracting video: $e');
//     }
//   }

//   void _injectJS() async {
//     // Setup JavaScript channel to receive video URLs
//     controller.addJavaScriptChannel(
//       'VideoChannel',
//       onMessageReceived: (JavaScriptMessage message) {
//         if (message.message.isNotEmpty &&
//             (message.message.contains('.mp4') ||
//                 message.message.contains('.m3u8') ||
//                 message.message.contains('video'))) {
//           setState(() {
//             detectedVideoUrl = message.message;
//           });
//         }
//       },
//     );

//     // Comprehensive video detection script
//     await controller.runJavaScript("""
//       function findVideoUrl() {
//         // Check video elements
//         let videos = document.getElementsByTagName('video');
//         if (videos.length > 0) {
//           for (let video of videos) {
//             let src = video.src;
//             if (src && (src.includes('.mp4') || src.includes('video'))) {
//               VideoChannel.postMessage(src);
//               return;
//             }

//             // Check source elements inside video
//             let sources = video.getElementsByTagName('source');
//             for (let source of sources) {
//               if (source.src && source.src.includes('.mp4')) {
//                 VideoChannel.postMessage(source.src);
//                 return;
//               }
//             }
//           }
//         }

//         // Check for video URLs in page content
//         let pageText = document.body.innerText;
//         let videoUrlMatch = pageText.match(/https?:[^\\s]+.(mp4|m3u8)(\\?[^\\s]*)?/);
//         if (videoUrlMatch) {
//           VideoChannel.postMessage(videoUrlMatch[0]);
//           return;
//         }

//         // Check for video elements in iframes
//         let iframes = document.getElementsByTagName('iframe');
//         for (let iframe of iframes) {
//           try {
//             let iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
//             let iframeVideos = iframeDoc.getElementsByTagName('video');
//             if (iframeVideos.length > 0 && iframeVideos[0].src) {
//               VideoChannel.postMessage(iframeVideos[0].src);
//               return;
//             }
//           } catch(e) {
//             // Cross-origin iframe, can't access
//           }
//         }
//       }

//       // Run detection every 2 seconds
//       setInterval(findVideoUrl, 2000);

//       // Also check when DOM changes
//       const observer = new MutationObserver(findVideoUrl);
//       observer.observe(document.body, { childList: true, subtree: true });
//     """);
//   }

//   void _injectVideoDetection() async {
//     if (detectedVideoUrl != null) {
//       await controller.runJavaScript("""
//         // Try to directly access the video
//         const videoElements = document.getElementsByTagName('video');
//         if (videoElements.length > 0) {
//           const video = videoElements[0];
//           if (video.src) {
//             VideoChannel.postMessage(video.src);
//           } else {
//             // Try to get video URL from data attributes
//             const dataUrl = video.getAttribute('data-video-url') ||
//                            video.getAttribute('data-src');
//             if (dataUrl) {
//               VideoChannel.postMessage(dataUrl);
//             }
//           }
//         }
//       """);
//     }
//   }

//   Future<void> openInChrome(String url) async {
//     final uri = Uri.parse(url);
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Could not open browser: $e")));
//     }
//   }

//   Future<void> downloadVideo() async {
//     if (detectedVideoUrl == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "No video detected yet. Please wait for the video to load.",
//           ),
//         ),
//       );
//       return;
//     }

//     print("Download URL: $detectedVideoUrl");

//     // Show dialog with video URL options
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Video Detected"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Video URL found:"),
//               const SizedBox(height: 8),
//               Text(
//                 detectedVideoUrl!,
//                 style: const TextStyle(fontSize: 12),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _downloadVideoFile();
//               },
//               child: const Text("Download"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _downloadVideoFile() async {
//     // Implement actual download logic here
//     // You can use packages like: dio, flutter_downloader, etc.
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           "Download feature needs to be implemented with a download manager",
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _videoDetectionTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Browser"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.open_in_browser),
//             onPressed: () => openInChrome(widget.url),
//             tooltip: "Open in Chrome",
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: downloadVideo,
//             tooltip: "Download Video",
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: controller),
//           if (detectedVideoUrl != null)
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: FloatingActionButton(
//                 onPressed: downloadVideo,
//                 child: const Icon(Icons.download),
//                 tooltip: "Download Video",
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// class WebViewScreen extends StatefulWidget {
//   final String url;

//   const WebViewScreen({super.key, required this.url});

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController _controller;
//   String? detectedVideoUrl;
//   bool _isDownloading = false;
//   double _downloadProgress = 0.0;
//   String _downloadStatus = '';
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _initWebView();
//   }

//   Future<void> _requestPermissions() async {
//     if (Platform.isAndroid) {
//       await Permission.storage.request();
//     }
//   }

//   void _initWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..addJavaScriptChannel(
//         'VideoChannel',
//         onMessageReceived: (JavaScriptMessage message) {
//           _onVideoDetected(message.message);
//         },
//       )
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//               _errorMessage = null;
//             });
//             debugPrint('Page started: $url');
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//             });
//             debugPrint('Page finished: $url');
//             _injectJS();
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('WebView error: ${error.description}');
//             setState(() {
//               _isLoading = false;
//               _errorMessage = 'Failed to load page';
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('intent://') ||
//                 request.url.startsWith('fb://')) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );

//     // Load URL after a short delay
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadUrl();
//     });
//   }

//   Future<void> _loadUrl() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final uri = Uri.parse(widget.url);
//       await _controller.loadRequest(uri);
//     } catch (e) {
//       debugPrint('Error loading URL: $e');
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Error loading: ${widget.url}';
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load: ${widget.url}')),
//         );
//       }
//     }
//   }

//   void _injectJS() {
//     _controller.runJavaScript('''
//       function findVideoUrls() {
//         const urls = [];

//         const videos = document.querySelectorAll('video');
//         for (const video of videos) {
//           if (video.src && video.src.startsWith('http')) {
//             urls.push(video.src);
//             VideoChannel.postMessage(video.src);
//           }
//           const sources = video.querySelectorAll('source');
//           for (const source of sources) {
//             if (source.src && source.src.startsWith('http')) {
//               urls.push(source.src);
//               VideoChannel.postMessage(source.src);
//             }
//           }
//         }

//         const iframes = document.querySelectorAll('iframe');
//         for (const iframe of iframes) {
//           if (iframe.src && (iframe.src.includes('.mp4') || iframe.src.includes('video'))) {
//             urls.push(iframe.src);
//             VideoChannel.postMessage(iframe.src);
//           }
//         }

//         const links = document.querySelectorAll('a[href*=".mp4"], a[href*=".m3u8"], a[href*=".mov"]');
//         for (const link of links) {
//           if (link.href && link.href.startsWith('http')) {
//             urls.push(link.href);
//             VideoChannel.postMessage(link.href);
//           }
//         }

//         return urls.length;
//       }

//       findVideoUrls();
//       setInterval(findVideoUrls, 3000);

//       const observer = new MutationObserver(function() {
//         findVideoUrls();
//       });

//       if (document.body) {
//         observer.observe(document.body, {
//           childList: true,
//           subtree: true,
//           attributes: true
//         });
//       }
//     ''');
//   }

//   void _onVideoDetected(String url) {
//     if (detectedVideoUrl == url) return;

//     setState(() {
//       detectedVideoUrl = url;
//     });

//     debugPrint('🎥 Video detected: $url');

//     if (!_isDownloading && mounted) {
//       _showDownloadDialog();
//     }
//   }

//   void _showDownloadDialog() {
//     if (detectedVideoUrl == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No video detected yet')),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Download Video', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Select video quality:', style: TextStyle(fontWeight: FontWeight.w500)),
//               const SizedBox(height: 16),
//               _buildQualityOption('High Quality (720p)', '720p', Icons.high_quality, Colors.blue),
//               const Divider(height: 0),
//               _buildQualityOption('Medium Quality (480p)', '480p', Icons.high_quality_outlined, Colors.orange),
//               const Divider(height: 0),
//               _buildQualityOption('Low Quality (360p)', '360p', Icons.sd, Colors.grey),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQualityOption(String title, String quality, IconData icon, Color color) {
//     return ListTile(
//       leading: Icon(icon, color: color),
//       title: Text(title),
//       trailing: const Icon(Icons.download, color: Colors.blue),
//       onTap: () async {
//         Navigator.pop(context);
//         await _downloadVideo(quality);
//       },
//     );
//   }

//   Future<void> _downloadVideo(String quality) async {
//     if (detectedVideoUrl == null) return;

//     setState(() {
//       _isDownloading = true;
//       _downloadProgress = 0.0;
//       _downloadStatus = 'Starting download...';
//     });

//     final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}_$quality.mp4';

//     try {
//       // Download video directly
//       final savePath = await _downloadFile(detectedVideoUrl!, fileName, quality);

//       if (savePath != null && mounted) {
//         setState(() => _isDownloading = false);
//         _showSuccessDialog(fileName, savePath);
//       } else {
//         throw Exception('Download failed');
//       }
//     } catch (e) {
//       setState(() => _isDownloading = false);
//       _showErrorSnackbar('Download failed: ${e.toString().substring(0, 100)}');
//     }
//   }

//   Future<String?> _downloadFile(String url, String fileName, String quality) async {
//     try {
//       final dio = Dio();
//       dio.options.connectTimeout = const Duration(seconds: 30);
//       dio.options.receiveTimeout = const Duration(minutes: 5);
//       dio.options.headers = {
//         'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
//         'Accept': '*/*',
//       };

//       // Get download directory
//       String savePath;
//       if (Platform.isAndroid) {
//         final moviesDir = Directory('/storage/emulated/0/Movies');
//         if (await moviesDir.exists()) {
//           savePath = '${moviesDir.path}/$fileName';
//         } else {
//           final downloadsDir = Directory('/storage/emulated/0/Download');
//           savePath = '${downloadsDir.path}/$fileName';
//         }
//       } else {
//         final directory = await getApplicationDocumentsDirectory();
//         savePath = '${directory.path}/$fileName';
//       }

//       await dio.download(
//         url,
//         savePath,
//         onReceiveProgress: (received, total) {
//           if (total > 0) {
//             final progress = received / total;
//             final receivedMB = received / 1024 / 1024;
//             final totalMB = total / 1024 / 1024;
//             setState(() {
//               _downloadProgress = progress;
//               _downloadStatus = '${receivedMB.toStringAsFixed(1)} MB / ${totalMB.toStringAsFixed(1)} MB';
//             });
//           }
//         },
//       );

//       // Save to history using controller
//       final downloadController = context.read<DownloadController>();
//       await downloadController.addToHistory(
//         fileName: fileName,
//         filePath: savePath,
//         videoUrl: url,
//         quality: quality,
//       );

//       return savePath;
//     } catch (e) {
//       debugPrint('Download error: $e');
//       return null;
//     }
//   }

//   void _showSuccessDialog(String fileName, String filePath) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.green),
//               SizedBox(width: 10),
//               Text('Download Complete!'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Video has been saved to your gallery.'),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('📹 File Details:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text('Name: $fileName', style: const TextStyle(fontSize: 12)),
//                     const SizedBox(height: 4),
//                     const Text('Location: Movies / Downloads folder', style: TextStyle(fontSize: 11, color: Colors.grey)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.error, color: Colors.red),
//               const SizedBox(width: 10),
//               Expanded(child: Text(message)),
//             ],
//           ),
//           backgroundColor: Colors.red[800],
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> openInChrome(String url) async {
//     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Downloader Browser'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.open_in_browser),
//             onPressed: () => openInChrome(widget.url),
//             tooltip: 'Open in Browser',
//           ),
//           if (detectedVideoUrl != null && !_isDownloading)
//             IconButton(
//               icon: const Icon(Icons.download),
//               onPressed: _showDownloadDialog,
//               tooltip: 'Download Video',
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // WebView
//           WebViewWidget(controller: _controller),

//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.white,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Loading webpage...'),
//                   ],
//                 ),
//               ),
//             ),

//           // Error message
//           if (_errorMessage != null && !_isLoading)
//             Container(
//               color: Colors.white,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                     const SizedBox(height: 16),
//                     Text(_errorMessage!),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _loadUrl,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           // Video detection badge
//           if (detectedVideoUrl != null && !_isDownloading && !_isLoading)
//             Positioned(
//               top: 60,
//               right: 10,
//               child: GestureDetector(
//                 onTap: _showDownloadDialog,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.video_camera_front, color: Colors.white, size: 16),
//                       SizedBox(width: 6),
//                       Text('Video Found!', style: TextStyle(color: Colors.white, fontSize: 12)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Download progress
//           if (_isDownloading)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Card(
//                 elevation: 8,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           const CircularProgressIndicator(),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 LinearProgressIndicator(value: _downloadProgress),
//                                 const SizedBox(height: 8),
//                                 Text(_downloadStatus, style: const TextStyle(fontSize: 12)),
//                                 Text('${(_downloadProgress * 100).toStringAsFixed(1)}%',
//                                      style: const TextStyle(fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//workingggggggggggggggggggggggggggggggggggggggggggg
import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initWebView();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
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
            });
            debugPrint('Page started: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('Page finished: $url');
            _injectJS();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
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

    // Load URL after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUrl();
    });
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
      debugPrint('Error loading URL: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading: ${widget.url}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: ${widget.url}')),
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

        const links = document.querySelectorAll('a[href*=".mp4"], a[href*=".m3u8"], a[href*=".mov"]');
        for (const link of links) {
          if (link.href && link.href.startsWith('http')) {
            urls.push(link.href);
            VideoChannel.postMessage(link.href);
          }
        }

        return urls.length;
      }

      findVideoUrls();
      setInterval(findVideoUrls, 3000);

      const observer = new MutationObserver(function() {
        findVideoUrls();
      });

      if (document.body) {
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          attributes: true
        });
      }
    ''');
  }

  void _onVideoDetected(String url) {
    if (detectedVideoUrl == url) return;

    setState(() {
      detectedVideoUrl = url;
    });

    debugPrint('🎥 Video detected: $url');

    if (!_isDownloading && mounted) {
      _showDownloadDialog();
    }
  }

  void _showDownloadDialog() {
    if (detectedVideoUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No video detected yet')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Download Video',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select video quality:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildQualityOption(
                'High Quality (720p)',
                '720p',
                Icons.high_quality,
                Colors.blue,
              ),
              const Divider(height: 0),
              _buildQualityOption(
                'Medium Quality (480p)',
                '480p',
                Icons.high_quality_outlined,
                Colors.orange,
              ),
              const Divider(height: 0),
              _buildQualityOption(
                'Low Quality (360p)',
                '360p',
                Icons.sd,
                Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQualityOption(
    String title,
    String quality,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.download, color: Colors.blue),
      onTap: () async {
        Navigator.pop(context);
        await _downloadVideo(quality);
      },
    );
  }

  Future<void> _downloadVideo(String quality) async {
    if (detectedVideoUrl == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Starting download...';
    });

    final fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}_$quality.mp4';

    try {
      // Download video directly
      final savePath = await _downloadFile(
        detectedVideoUrl!,
        fileName,
        quality,
      );

      if (savePath != null && mounted) {
        setState(() => _isDownloading = false);
        _showSuccessDialog(fileName, savePath);
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      _showErrorSnackbar('Download failed: ${e.toString().substring(0, 100)}');
    }
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
      };

      // Get download directory
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
          }
        },
      );

      // Save to history using controller
      final downloadController = context.read<DownloadController>();
      await downloadController.addToHistory(
        fileName: fileName,
        filePath: savePath,
        videoUrl: url,
        quality: quality,
      );

      return savePath;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  void _showSuccessDialog(String fileName, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Download Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Video has been saved to your gallery.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📹 File Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: $fileName',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Location: Movies / Downloads folder',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[800],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> openInChrome(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Downloader Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => openInChrome(widget.url),
            tooltip: 'Open in Browser',
          ),
          if (detectedVideoUrl != null && !_isDownloading)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _showDownloadDialog,
              tooltip: 'Download Video',
            ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading webpage...'),
                  ],
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null && !_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUrl,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Video detection badge
          if (detectedVideoUrl != null && !_isDownloading && !_isLoading)
            Positioned(
              top: 60,
              right: 10,
              child: GestureDetector(
                onTap: _showDownloadDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.video_camera_front,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Video Found!',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Download progress
          if (_isDownloading)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _downloadProgress,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _downloadStatus,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
            ),
        ],
      ),
    );
  }
}
