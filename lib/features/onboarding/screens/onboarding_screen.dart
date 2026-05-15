// import 'package:facebook_video_downloader/features/languageselect/languageSelectorScreen.dart';
import 'package:facebook_video_downloader/controllers/onboarding_controller.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already
    if (!Get.isRegistered<OnboardingController>()) {
      Get.put(OnboardingController());
    }
    
    // Update localized strings
    controller.updateLocalizedStrings(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top row with skip button
            _buildTopBar(context),
            
            // Page content - Centered
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.totalPages,
                itemBuilder: (context, index) {
                  return _buildPage(controller.onboardingPages[index], index);
                },
              ),
            ),
            
            // Bottom navigation - Centered dots and button
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopBar(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty space for balance
          const SizedBox(width: 60),
          
          // Centered title
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          
          // Skip button
          TextButton(
            onPressed: controller.skipOnboarding,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              localizations?.skip ?? 'Skip',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Page indicator - Centered
          Center(
            child: SmoothPageIndicator(
              controller: controller.pageController,
              count: controller.totalPages,
              effect: const ExpandingDotsEffect(
                activeDotColor: Color(0xFF0066ff),
                dotColor: Color(0xFFE0E0E0),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 8,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Get Started / Next Button - Centered and prominent
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: controller.nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066ff),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF0066ff).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isLastPage.value
                        ? (localizations?.get_started ?? 'GET STARTED')
                        : (localizations?.next ?? 'NEXT'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (!controller.isLastPage.value) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    ));
  }
  
  Widget _buildPage(OnboardingPageData data, int index) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Image container - Centered
            Container(
              height: MediaQuery.of(Get.context!).size.height * 0.42,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  data.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0066ff).withOpacity(0.1),
                            Colors.grey[100]!,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.video_library_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title - Centered
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description - Centered
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Animated progress cards (centered)
            Center(
              child: SizedBox(
                width: MediaQuery.of(Get.context!).size.width * 0.85,
                child: _buildProgressCards(index),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressCards(int pageIndex) {
    final localizations = AppLocalizations.of(Get.context!);
    
    if (pageIndex == 0) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            _buildProgressItem(
              localizations?.art_design_video ?? 'Art Design.mp4',
              null,
              null,
              true,
            ),
            const SizedBox(height: 10),
            _buildProgressItem(
              localizations?.historical_place_video ?? 'Historical Place.mp4',
              66,
              672,
              false,
            ),
          ],
        ),
      );
    } else if (pageIndex == 1) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            _buildProgressItem(
              localizations?.science_speech_video ?? 'Science Speech.mp4',
              180,
              250,
              false,
            ),
            const SizedBox(height: 10),
            _buildProgressItem(
              localizations?.programming_course_video ??
                  'Programming Course.mp4',
              110,
              190,
              false,
            ),
          ],
        ),
      );
    } else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: _buildDownloadCard(
          localizations?.video_download ?? 'Video Download',
          localizations?.tap_to_download ?? 'Tap to download',
          Icons.download_rounded,
        ),
      );
    }
  }
  
  Widget _buildProgressItem(
    String title,
    int? current,
    int? total,
    bool isCompleted,
  ) {
    final localizations = AppLocalizations.of(Get.context!);
    double progress = (current != null && total != null)
        ? current / total
        : 1.0;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isCompleted && current != null && total != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${current}MB/${total}MB',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                )
              else if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        localizations?.completed ?? 'Completed',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isCompleted && current != null && total != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0066ff),
                ),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDownloadCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0066ff).withOpacity(0.05), Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0066ff).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066ff), Color(0xFF0088ff)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }
}