// import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
// import 'package:facebook_video_downloader/features/settings/settings_screen.dart' hide HistoryScreen;
// import 'package:flutter/material.dart';

// import '../webview/webview_screen.dart';
// import '../history/history_screen.dart';
// import 'url_input.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _urlController = TextEditingController();
//   final String _defaultUrl = 'https://www.facebook.com';
//   int _currentIndex = 0;

//   final List<Widget> _screens = [];

//   @override
//   void initState() {
//     super.initState();
//     _screens.addAll([
//       _BrowserScreen(urlController: _urlController, defaultUrl: _defaultUrl),
//       const HistoryScreen(),
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.web), label: 'Browser'),
//           BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Watch'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.saved_search_rounded),
//             label: 'Saved',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BrowserScreen extends StatelessWidget {
//   final TextEditingController urlController;
//   final String defaultUrl;

//   const _BrowserScreen({required this.urlController, required this.defaultUrl});

//   void _navigateToWebView(BuildContext context) {
//     String url = urlController.text.trim();
//     if (url.isEmpty) {
//       url = defaultUrl;
//     }
//     if (!url.startsWith('http')) {
//       url = 'https://$url';
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           'Video Downloader',
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           // Premium Button
//           IconButton(
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.star, color: Colors.amber, size: 22),
//             ),
//             onPressed: () {
//               // Navigate to Premium Screen
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const PremiumScreen()),
//               );
//             },
//             tooltip: 'Premium',
//           ),
//           // Facebook Button
//           IconButton(
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.facebook,
//                 color: Color(0xFF1877F2),
//                 size: 22,
//               ),
//             ),
//             onPressed: () {
//               // Open Facebook WebView or Launch URL
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       WebViewScreen(url: 'https://www.facebook.com'),
//                 ),
//               );
//             },
//             tooltip: 'Facebook',
//           ),
//           // Settings Button
//           IconButton(
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.settings, color: Colors.grey, size: 22),
//             ),
//             onPressed: () {
//               // Navigate to Settings Screen
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
//               );
//             },
//             tooltip: 'Settings',
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),

//       body: Column(
//         children: [
//           UrlInput(
//             controller: urlController,
//             onSearch: () => _navigateToWebView(context),
//           ),
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.play_circle_filled, size: 80, color: Colors.blue),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Enter a URL to start browsing',
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Videos will be detected automatically',

//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),

//                   const SizedBox(height: 8),
//                   const Text(
//                     'Select Quality and then Download',

//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),

//                   const SizedBox(height: 16),

//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.symmetric(horizontal: 32),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Column(
//                       children: [
//                         Text(
//                           '💡 Tip:',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Try Facebook.com/videos',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:facebook_video_downloader/features/settings/settings_screen.dart' hide HistoryScreen;
import '../webview/webview_screen.dart';
import '../history/history_screen.dart';
import 'url_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final String _defaultUrl = 'https://www.facebook.com';
  int _currentIndex = 0;
  
  // Flag to track if user has agreed to disclaimer
  bool _hasAgreed = false;
  bool _isLoading = true;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _BrowserScreen(urlController: _urlController, defaultUrl: _defaultUrl),
      const HistoryScreen(),
    ]);
    
    // Check agreement status when screen loads
    _checkAgreementStatus();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Check if user has already agreed to disclaimer (persisted)
  Future<void> _checkAgreementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreedBefore = prefs.getBool('disclaimer_agreed') ?? false;
    
    setState(() {
      _hasAgreed = hasAgreedBefore;
      _isLoading = false;
    });
    
    // Only show dialog if user hasn't agreed before
    if (!_hasAgreed) {
      // Wait for the first frame to complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDisclaimerDialog();
      });
    }
  }

  /// Save agreement status to SharedPreferences
  Future<void> _saveAgreementStatus(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_agreed', agreed);
    setState(() {
      _hasAgreed = agreed;
    });
  }

  /// Shows the disclaimer popup dialog
  void _showDisclaimerDialog() {
    // Double check if user hasn't agreed
    if (_hasAgreed) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Prevent back button from closing the dialog
            return false;
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Disclaimer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high, size: 16, color: Colors.amber.shade800),
                        const SizedBox(width: 6),
                        Text(
                          'Attention Please',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please get the permissions from the owner before reposting videos. Any unauthorized actions (re-uploading or downloading of contents) and/or violations of intellectual property rights is the sole responsibility of the user.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_off, size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'We will not upload or store any of your downloaded or personal data.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.security, size: 18, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'We are also not collecting and/or transmitting any of your personal or sensitive data from your device.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // Open a dialog or URL with more information
                      _showReadMoreDialog(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Read more',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: Colors.blue.shade700),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Cancel button - closes the app
              TextButton(
                onPressed: () {
                  // Close the app when user cancels
                  _closeApp();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
              // Agree button - proceeds to the app
              ElevatedButton(
                onPressed: () async {
                  // User agreed, save to SharedPreferences and proceed
                  await _saveAgreementStatus(true);
                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Agree',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows detailed "Read more" information
  void _showReadMoreDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('More Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Copyright & Usage Policy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              '• All videos are sourced from third-party platforms.\n\n'
              '• Users are solely responsible for ensuring they have the necessary rights and permissions before downloading or reposting any content.\n\n'
              '• This application does not claim ownership of any downloaded content.\n\n'
              '• Respect intellectual property rights and fair use policies.\n\n'
              '• For any copyright concerns, please contact the content owner directly.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Closes the application
  void _closeApp() {
    // Exit the app
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking agreement status
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.watch_later), label: 'Watch'),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

class _BrowserScreen extends StatelessWidget {
  final TextEditingController urlController;
  final String defaultUrl;

  const _BrowserScreen({required this.urlController, required this.defaultUrl});

  void _navigateToWebView(BuildContext context) {
    String url = urlController.text.trim();
    if (url.isEmpty) {
      url = defaultUrl;
    }
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Video Downloader',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Premium Button
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 22),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            tooltip: 'Premium',
          ),
          // Facebook Button
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.facebook,
                color: Color(0xFF1877F2),
                size: 22,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WebViewScreen(url: 'https://www.facebook.com'),
                ),
              );
            },
            tooltip: 'Facebook',
          ),
          // Settings Button
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, color: Colors.grey, size: 22),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          UrlInput(
            controller: urlController,
            onSearch: () => _navigateToWebView(context),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter a URL to start browsing',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Videos will be detected automatically',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select Quality and then Download',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '💡 Tip:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try Facebook.com/videos',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}