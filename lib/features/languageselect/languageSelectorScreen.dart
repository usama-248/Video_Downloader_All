
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/controllers/language_controller.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          localizations.selectLanguage,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => Column(
          children: [
            const SizedBox(height: 20),

            // Earth Logo Center
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0066ff).withOpacity(0.1),
                    const Color(0xFF0066ff).withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066ff).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.language,
                  size: 60,
                  color: const Color(0xFF0066ff),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            Text(
              localizations.chooseYourLanguage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            // English Option with Emoji Flag
            _buildLanguageOption(
              flagEmoji: '🇺🇸',
              iconColor: Colors.blue,
              languageName: 'English',
              languageCode: 'en',
              isSelected: controller.currentLocale.value.languageCode == 'en',
              onTap: () => controller.changeLanguage('en'),
            ),
            _buildDivider(),

            // Urdu Option with Emoji Flag
            _buildLanguageOption(
              flagEmoji: '🇵🇰',
              iconColor: Colors.green,
              languageName: 'اردو',
              languageCode: 'ur',
              isSelected: controller.currentLocale.value.languageCode == 'ur',
              onTap: () => controller.changeLanguage('ur'),
            ),
            _buildDivider(),

            // Arabic Option with Emoji Flag
            _buildLanguageOption(
              flagEmoji: '🇸🇦',
              iconColor: Colors.red,
              languageName: 'العربية',
              languageCode: 'ar',
              isSelected: controller.currentLocale.value.languageCode == 'ar',
              onTap: () => controller.changeLanguage('ar'),
            ),
            _buildDivider(),

            const SizedBox(height: 30),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _saveAndContinue(controller, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    localizations.continueText, // ✅ Fixed: using continueText instead of continue
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flagEmoji,
    required Color iconColor,
    required String languageName,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(flagEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
            if (!isSelected)
              const Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 0, thickness: 0.5, color: Colors.grey);
  }

  Future<void> _saveAndContinue(
    LanguageController controller,
    BuildContext context,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);

    Get.snackbar(
      localizations.success,
      '${controller.getCurrentLanguageName()} ${localizations.languageSelected}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate to your desired screen
    Get.offAllNamed('/interest');
  }
}