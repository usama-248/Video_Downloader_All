// // ignore_for_file: invalid_null_aware_operator

// import 'package:facebook_video_downloader/features/home/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:facebook_video_downloader/l10n/app_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PremiumScreen extends StatelessWidget {
//   const PremiumScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F9FC),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // 🔶 Premium Icon
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.orange.withOpacity(0.4),
//                     blurRadius: 20,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.workspace_premium,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),

//             const SizedBox(height: 16),

//             Text(
//               localizations?.startLikeAPro ?? "START LIKE A PRO",
//               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               localizations?.unlockFeatures ?? "Unlock All Features",
//               style: const TextStyle(fontSize: 15, color: Colors.grey),
//             ),

//             const SizedBox(height: 30),

//             // 🔥 FEATURES CARD
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   _featureItem(
//                     Icons.download,
//                     localizations?.featureUnlimited ??
//                         "Unlimited Video Downloads",
//                     true,
//                   ),
//                   _featureItem(
//                     Icons.hd,
//                     localizations?.featureHD ?? "Download in HD Quality",
//                     true,
//                   ),
//                   _featureItem(
//                     Icons.flash_on,
//                     localizations?.featureFast ?? "Ultra-Fast Download Speed",
//                     false,
//                   ),
//                   _featureItem(
//                     Icons.trending_up,
//                     localizations?.featureTrending ?? "Watch Trending",
//                     true,
//                   ),
//                   _featureItem(
//                     Icons.all_inclusive,
//                     localizations?.featureAnything ?? "Download Anything",
//                     true,
//                   ),
//                   _featureItem(
//                     Icons.block,
//                     localizations?.featureUnlimited ?? "Ads Free Experience",
//                     false,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             // 💳 PLAN CARD
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Weekly Premium",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "Full Access",
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         "Rs 4,200",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text("Per week", style: TextStyle(color: Colors.white70)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 15),

//             // 🎁 FREE TRIAL BOX
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Center(
//                 child: Text(
//                   "3 Days Free Trial Included 🎉",
//                   style: TextStyle(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 15),

//             Text(
//               localizations?.disclaimerContent ??
//                   "After trial, subscription applies. Cancel anytime.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//             const SizedBox(height: 20),

//             // 🚀 CTA BUTTON
//             GestureDetector(
//               onTap: () => _startFreeTrial(context, localizations),
//               child: Container(
//                 height: 58,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
//                   ),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.4),
//                       blurRadius: 12,
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     localizations?.freeTrial?.toUpperCase() ??
//                         "START FREE TRIAL",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.verified, color: Colors.green, size: 20),
//                 SizedBox(width: 6),
//                 Text(
//                   "No Payment Now!",
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= FEATURE ITEM =================
//   Widget _featureItem(IconData icon, String text, bool available) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(child: Text(text)),
//           Icon(
//             available ? Icons.check_circle : Icons.cancel,
//             color: available ? Colors.blue : Colors.red,
//           ),
//         ],
//       ),
//     );
//   }

//   // Skip to Home directly
//   void _skipToHome(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_seen_premium', true);

//     if (context.mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     }
//   }

//   // Start free trial and go to Home
//   void _startFreeTrial(
//     BuildContext context,
//     AppLocalizations? localizations,
//   ) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );

//     // TODO: Add actual payment processing here
//     await Future.delayed(const Duration(seconds: 2));

//     if (context.mounted) {
//       Navigator.pop(context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             localizations?.processing_link ?? "Premium activated successfully!",
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('is_premium_user', true);
//       await prefs.setBool('has_seen_premium', true);

//       // Go to Home after premium activation
//       if (context.mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       }
//     }
//   }
// }

// ignore_for_file: invalid_null_aware_operator

import 'package:facebook_video_downloader/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ), // Increased top padding to avoid icon overlap
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
                  localizations?.startLikeAPro ?? "START LIKE A PRO",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  localizations?.unlockFeatures ?? "Unlock All Features",
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
                        Icons.download,
                        localizations?.featureUnlimited ??
                            "Unlimited Video Downloads",
                        true,
                      ),
                      _featureItem(
                        Icons.hd,
                        localizations?.featureHD ?? "Download in HD Quality",
                        true,
                      ),
                      _featureItem(
                        Icons.flash_on,
                        localizations?.featureFast ??
                            "Ultra-Fast Download Speed",
                        false,
                      ),
                      _featureItem(
                        Icons.trending_up,
                        localizations?.featureTrending ?? "Watch Trending",
                        true,
                      ),
                      _featureItem(
                        Icons.all_inclusive,
                        localizations?.featureAnything ?? "Download Anything",
                        true,
                      ),
                      _featureItem(
                        Icons.block,
                        localizations?.featureUnlimited ??
                            "Ads Free Experience",
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
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Weekly Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Full Access",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Rs 4,200",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Per week",
                            style: TextStyle(color: Colors.white70),
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
                  child: const Center(
                    child: Text(
                      "3 Days Free Trial Included 🎉",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  localizations?.disclaimerContent ??
                      "After trial, subscription applies. Cancel anytime.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // 🚀 CTA BUTTON
                GestureDetector(
                  onTap: () => _startFreeTrial(context, localizations),
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
                        localizations?.freeTrial?.toUpperCase() ??
                            "START FREE TRIAL",
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

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "No Payment Now!",
                      style: TextStyle(
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
  Widget _featureItem(IconData icon, String text, bool available) {
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
  void _skipToHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_premium', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Start free trial and go to Home
  void _startFreeTrial(
    BuildContext context,
    AppLocalizations? localizations,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // TODO: Add actual payment processing here
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.processing_link ?? "Premium activated successfully!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_user', true);
      await prefs.setBool('has_seen_premium', true);

      // Go to Home after premium activation
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }
}
