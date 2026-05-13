import 'package:facebook_video_downloader/features/onboarding/screens/onboarding_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Add your REAL App Open Ad unit ID here
const String appOpenAdUnitId =
    'ca-app-pub-3605518487927639/7526774448'; // REAL App Open Ad unit ID

class SplashScreen extends StatefulWidget {
  final bool isReturningUser;

  const SplashScreen({super.key, this.isReturningUser = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _adShown = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Load App Open Ad
    _loadAppOpenAd();
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
          print('App Open Ad loaded successfully');

          // Set full screen content callback
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('App Open Ad showed');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('App Open Ad dismissed');
              ad.dispose();
              _isAdLoaded = false;
              _appOpenAd = null;
              // Navigate after ad is dismissed
              _navigateToNextScreen();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('App Open Ad failed to show: $error');
              ad.dispose();
              _isAdLoaded = false;
              _appOpenAd = null;
              // Navigate even if ad fails
              _navigateToNextScreen();
            },
          );

          // Auto-show the ad once loaded
          _showAppOpenAd();
        },
        onAdFailedToLoad: (error) {
          print('App Open Ad failed to load: $error');
          _isAdLoaded = false;
          // Navigate without ad after splash delay
          Future.delayed(const Duration(milliseconds: 2500), () {
            _navigateToNextScreen();
          });
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (_adShown || _navigated) return;

    if (_isAdLoaded && _appOpenAd != null) {
      _adShown = true;
      _appOpenAd!.show();
    }
  }

  void _navigateToNextScreen() {
    if (_navigated) return;
    _navigated = true;

    // Small delay to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      if (widget.isReturningUser) {
        // RETURNING USER: Go directly to Premium Screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const PremiumScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // NEW USER: Go to Onboarding Screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0066ff).withOpacity(0.1),
                            const Color.fromARGB(
                              255,
                              128,
                              157,
                              199,
                            ).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        size: 72,
                        color: Color(0xFF0066ff),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Video',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Downloader',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0066ff),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Download Videos\nfast and securely with our\nhassle-free video downloader.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0066ff),
                      ),
                      strokeWidth: 2.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}