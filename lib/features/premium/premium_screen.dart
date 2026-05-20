// ignore_for_file: invalid_null_aware_operator

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/features/home/home_screen.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // 🔶 Premium Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  localizations.premiumTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  localizations.premiumSubtitle,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // 🔥 FEATURES CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _featureItem(
                        context,
                        Icons.download,
                        localizations.featureUnlimited,
                        true,
                      ),
                      _featureItem(
                        context,
                        Icons.hd,
                        localizations.featureHD,
                        true,
                      ),
                      _featureItem(
                        context,
                        Icons.flash_on,
                        localizations.featureFast,
                        false,
                      ),
                      _featureItem(
                        context,
                        Icons.trending_up,
                        localizations.featureTrending,
                        true,
                      ),
                      _featureItem(
                        context,
                        Icons.all_inclusive,
                        localizations.featureAnything,
                        true,
                      ),
                      _featureItem(
                        context,
                        Icons.block,
                        localizations.featureAdFree,
                        false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 💳 PLAN CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.weeklyPremium,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.fullAccess,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            localizations.priceWeekly,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            localizations.perWeek,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // 🎁 FREE TRIAL BOX
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      localizations.freeTrialIncluded,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  localizations.disclaimerContent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // 🚀 CTA BUTTON
                GestureDetector(
                  onTap: () => _startFreeTrial(context),
                  child: Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        localizations.freeTrialButton.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      localizations.noPaymentNow,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Close icon positioned at top-right
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => _skipToHome(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close,
                  color: Color.fromARGB(255, 117, 115, 115),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FEATURE ITEM =================
  Widget _featureItem(BuildContext context, IconData icon, String text, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.blue : Colors.red,
          ),
        ],
      ),
    );
  }

  // Skip to Home directly
  Future<void> _skipToHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_premium', true);

    Get.offAll(() => const HomeScreen());
  }

  // Start free trial and go to Home
  Future<void> _startFreeTrial(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // TODO: Add actual payment processing here
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (Get.context != null) {
      Get.back();
    }

    // Show success message
    Get.snackbar(
      localizations.premiumActivated,
      localizations.premiumSuccessMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Save premium status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_user', true);
    await prefs.setBool('has_seen_premium', true);

    // Go to Home after premium activation
    Get.offAll(() => const HomeScreen());
  }
}