import 'package:facebook_video_downloader/features/providers/language_provider.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l10n.selectLanguage,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // English Option
          _buildLanguageOption(
            context: context,
            icon: Icons.g_translate,
            iconColor: Colors.blue,
            languageName: l10n.english,
            languageCode: 'en',
            currentLocale: languageProvider.locale,
            onTap: () {
              _changeLanguage(context, const Locale('en'), l10n.english);
            },
          ),
          _buildDivider(),
          // Urdu Option
          _buildLanguageOption(
            context: context,
            icon: Icons.g_translate,
            iconColor: Colors.green,
            languageName: l10n.urdu,
            languageCode: 'ur',
            currentLocale: languageProvider.locale,
            onTap: () {
              _changeLanguage(context, const Locale('ur'), l10n.urdu);
            },
          ),
          _buildDivider(),
          // Arabic Option
          _buildLanguageOption(
            context: context,
            icon: Icons.g_translate,
            iconColor: Colors.red,
            languageName: l10n.arabic,
            languageCode: 'ar',
            currentLocale: languageProvider.locale,
            onTap: () {
              _changeLanguage(context, const Locale('ar'), l10n.arabic);
            },
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String languageName,
    required String languageCode,
    required Locale currentLocale,
    required VoidCallback onTap,
  }) {
    final isSelected = currentLocale.languageCode == languageCode;
    
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
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
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
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
              ),
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
    return const Divider(
      height: 0,
      thickness: 0.5,
      color: Colors.grey,
    );
  }

  void _changeLanguage(BuildContext context, Locale locale, String languageName) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Update the language
    languageProvider.setLanguage(locale);
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.languageChanged} $languageName'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Go back to settings screen
    Navigator.pop(context);
    
    // Optional: Show restart dialog
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.languageChanged),
            content: Text(l10n.restartMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      );
    });
  }
}