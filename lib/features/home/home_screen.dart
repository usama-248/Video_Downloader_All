
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

import '../webview/webview_screen.dart';
import '../history/history_screen.dart';
import '../premium/premium_screen.dart';
import '../settings/settings_screen.dart';

// Add this function outside of any class or inside a utility class
Future<void> openInChrome(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error opening URL: $e');
    // Fallback: You might want to show a snackbar or dialog here
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _hasAgreed = false;
  bool _isLoading = true;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const _BrowserScreen(),
      const _WatchScreen(),
      const HistoryScreen(),
    ]);
    _checkAgreementStatus();
  }

  Future<void> _checkAgreementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreedBefore = prefs.getBool('disclaimer_agreed') ?? false;

    setState(() {
      _hasAgreed = hasAgreedBefore;
      _isLoading = false;
    });

    if (!_hasAgreed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDisclaimerDialog();
      });
    }
  }

  Future<void> _saveAgreementStatus(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_agreed', agreed);
    setState(() => _hasAgreed = agreed);
  }

  void _showDisclaimerDialog() {
    if (_hasAgreed) return;

    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
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
                      color: const Color(0xFF0066ff).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/Disclaimer.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF0066ff),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.disclaimerTitle ?? 'Disclaimer',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 2, color: Colors.grey.shade200),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066ff).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 16,
                        color: const Color(0xFF0066ff),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Attention Please',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0066ff),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations?.disclaimerContent ??
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
                          Image.asset(
                            'assets/images/FileSave.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.cloud_off,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                          ),
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
                          Image.asset(
                            'assets/images/Privacyicon.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.security,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                          ),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                localizations?.cancel ?? 'Cancel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveAgreementStatus(true);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF0066ff),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                localizations?.ok ?? 'Agree',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0066ff),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/images/Home.png'),
              size: 24,
            ),
            label: localizations?.browserTab ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/images/Watch_Video.png'),
              size: 24,
            ),
            label: localizations?.watchTab ?? 'Watch',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              const AssetImage('assets/images/FileSave.png'),
              size: 24,
            ),
            label: localizations?.savedTab ?? 'Saved',
          ),
        ],
      ),
    );
  }
}

// ==================== BROWSER SCREEN WITH LOCALIZATION ====================

class _BrowserScreen extends StatefulWidget {
  const _BrowserScreen();

  @override
  State<_BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<_BrowserScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _title;
  String? _imageUrl;
  bool _isFetching = false;

  Future<void> _fetchMetadata(String url) async {
    if (url.isEmpty || !url.contains('facebook.com')) return;

    setState(() => _isFetching = true);

    try {
      final metadata = await MetadataFetch.extract(url);
      setState(() {
        _title = metadata?.title ?? 'Facebook Video';
        _imageUrl = metadata?.image;
      });
    } catch (e) {
      setState(() {
        _title = 'Video Preview';
        _imageUrl = null;
      });
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _pasteLink() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      _urlController.text = data.text!;
      _fetchMetadata(data.text!);
    }
  }

  void _navigateToWebView(BuildContext context, {String? url}) {
    String finalUrl = url ?? _urlController.text.trim();
    if (finalUrl.isEmpty) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.please_paste_link ?? 'Please paste a link first',
          ),
        ),
      );
      return;
    }

    if (!finalUrl.startsWith('http')) {
      finalUrl = 'https://$finalUrl';
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebViewScreen(url: finalUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations?.appTitle ?? 'Video Downloader',
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
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Crown.png',
                width: 35,
                height: 35,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.star, color: Colors.white, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              tooltip: localizations?.premium ?? 'Premium',
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Facebookicon.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.facebook, color: Colors.white, size: 22),
              ),
              onPressed: () {
                // Replace WebView with Chrome browser
                openInChrome('https://www.facebook.com');
              },
              tooltip: localizations?.facebook ?? 'Facebook',
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Settingicon.png',
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.settings, color: Colors.white, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              tooltip: localizations?.settings ?? 'Settings',
            ),
          ),
          const SizedBox(width: 8),
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
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      233,
                      230,
                      230,
                    ).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 233, 230, 230),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 170, 166, 166),
                          ),
                        ),
                        child: TextField(
                          controller: _urlController,
                          onChanged: (value) {
                            if (value.contains('facebook.com')) {
                              _fetchMetadata(value);
                            }
                          },
                          decoration: InputDecoration(
                            hintText:
                                localizations?.searchHint ??
                                'Paste your link here...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            prefixIcon: Image.asset(
                              'assets/images/coy',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.link,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pasteLink,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0066ff),
                                side: const BorderSide(
                                  color: Color(0xFF0066ff),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                localizations?.paste_link ?? 'Paste Link',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0066ff),
                                    Color(0xFF1f83ff),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (_urlController.text.isNotEmpty) {
                                    _navigateToWebView(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localizations?.please_paste_link ??
                                              'Please paste a link first',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  localizations?.download ?? 'Download',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildThumbnail(localizations),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _title ??
                                        (localizations?.facebook_video ??
                                            'Facebook Video'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '720p • MP4',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_urlController.text.isNotEmpty) {
                                  _navigateToWebView(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localizations?.please_paste_link ??
                                            'Please paste a link first',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.download, size: 18),
                              label: Text(
                                localizations?.download ?? 'Download',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066ff),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.how_to_download ?? 'How to download?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        '1',
                        localizations?.step_1 ??
                            'Open Facebook and copy video link',
                      ),
                      const SizedBox(height: 8),
                      _buildStep(
                        '2',
                        localizations?.step_2 ??
                            'Paste link in the app and tap Download',
                      ),
                      const SizedBox(height: 8),
                      _buildStep(
                        '3',
                        localizations?.step_3 ??
                            'Select quality and save the video',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066ff).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tips_and_updates,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations?.tipText ??
                                '💡 Tip: Try Facebook.com/videos for best results',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0066ff).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF0066ff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildThumbnail(AppLocalizations? localizations) {
    if (_isFetching) {
      return SizedBox(
        height: 200,
        width: double.infinity,
        child: Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              _imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultThumbnail(localizations),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_circle_filled,
                size: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return _defaultThumbnail(localizations);
  }

  Widget _defaultThumbnail(AppLocalizations? localizations) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                localizations?.video_ready ??
                    'Video ready! Tap Download to save.',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== WATCH SCREEN WITH LOCALIZATION ====================

class _WatchScreen extends StatelessWidget {
  const _WatchScreen();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0066ff),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations?.appTitle ?? 'Video Downloader',
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
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Crown.png',
                width: 35,
                height: 35,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.star, color: Colors.white, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              tooltip: localizations?.premium ?? 'Premium',
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Facebookicon.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.facebook, color: Colors.white, size: 22),
              ),
              onPressed: () {
                // Replace WebView with Chrome browser
                openInChrome('https://www.facebook.com');
              },
              tooltip: localizations?.facebook ?? 'Facebook',
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'assets/images/Settingicon.png',
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.settings, color: Colors.white, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              tooltip: localizations?.settings ?? 'Settings',
            ),
          ),
          const SizedBox(width: 8),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0066ff).withOpacity(0.9),
                          const Color(0xFF1f83ff).withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066ff).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/Watch_Video.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.play_circle_filled,
                              size: 60,
                              color: Color(0xFF0066ff),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          localizations?.watch_facebook_videos ??
                              'Watch & Download Videos',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations?.tap_below_to_open_facebook ??
                              'Browse Facebook and save your favorite videos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Replace WebView with Chrome browser
                              openInChrome('https://www.facebook.com');
                            },
                            icon: const Icon(Icons.facebook, size: 24),
                            label: Text(
                              localizations?.open_facebook ?? 'Open Facebook',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0066ff),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // How to Download Videos - Beautiful Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFF0066ff),
                                const Color(0xFF1f83ff),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.download_for_offline,
                                  color: Color(0xFF0066ff),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  localizations?.how_to_download_videos ??
                                      'How to Download Videos',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Step 1
                              _buildStepCard(
                                title: 'Find & Share',
                                description:
                                    localizations?.step_1 ??
                                    'Open Facebook, find a video you like, and tap the Share button',
                                icon: Icons.facebook,
                                color: const Color(0xFF1877F2),
                              ),
                              const SizedBox(height: 16),
                              // Step 2
                              _buildStepCard(
                                title: 'Copy Link',
                                description:
                                    'Select "Copy Link" from the share options',
                                icon: Icons.link,
                                color: const Color(0xFF34A853),
                              ),
                              const SizedBox(height: 16),
                              // Step 3
                              _buildStepCard(
                                title: 'Paste & Download',
                                description:
                                    localizations?.step_2 ??
                                    'Go to Home tab, paste the link, and tap Download',
                                icon: Icons.download,
                                color: const Color(0xFF0066ff),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pro Tips Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0066ff).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066ff).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.tips_and_updates,
                                color: Color(0xFF0066ff),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Pro Tips for Best Results',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTipRow(
                          '🎯',
                          localizations?.tip_find_video ??
                              'Public videos work best for downloading',
                        ),
                        const SizedBox(height: 12),
                        _buildTipRow(
                          '📱',
                          'Make sure you have a stable internet connection',
                        ),
                        const SizedBox(height: 12),
                        _buildTipRow(
                          '💾',
                          'Saved videos are stored in your gallery',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Need Help Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.help_outline,
                                  color: Color(0xFF0066ff),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations?.how_to_download_videos ??
                                      'Quick Guide',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDialogStep(
                                  '1',
                                  localizations?.step_1 ??
                                      'Find a video on Facebook',
                                ),
                                const SizedBox(height: 12),
                                _buildDialogStep('2', 'Tap the share button'),
                                const SizedBox(height: 12),
                                _buildDialogStep('3', 'Select "Copy Link"'),
                                const SizedBox(height: 12),
                                _buildDialogStep(
                                  '4',
                                  localizations?.step_2 ??
                                      'Go to Home tab and paste the link',
                                ),
                                const SizedBox(height: 12),
                                _buildDialogStep(
                                  '5',
                                  localizations?.step_3 ??
                                      'Tap Download button',
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF0066ff),
                                ),
                                child: Text(
                                  localizations?.got_it ?? 'Got it',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.support_agent,
                        color: Colors.transparent,
                      ),
                      label: Text(
                        localizations?.need_help ?? 'Need Help? Watch Tutorial',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.transparent,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.transparent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

  Widget _buildStepCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF0066ff).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0066ff),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
