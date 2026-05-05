// import 'package:facebook_video_downloader/features/interest/interestscreen.dart';
// import 'package:facebook_video_downloader/features/providers/language_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// class LanguageSelectorScreen extends StatefulWidget {
//   const LanguageSelectorScreen({super.key});

//   @override
//   State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
// }

// class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
//   String _selectedLanguage = 'English';

//   final List<Map<String, dynamic>> _languages = [
//     {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
//     {'name': 'اردو', 'code': 'ur', 'flag': '🇵🇰'},
//     {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/BG.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               const Icon(
//                 Icons.language,
//                 size: 80,
//                 color: Color.fromARGB(255, 255, 255, 255),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Choose Your Language',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Select your preferred language to continue',
//                 style: TextStyle(fontSize: 16, color: Colors.white70),
//               ),
//               const SizedBox(height: 48),
//               ..._languages.map((lang) => _buildLanguageOption(lang)),
//               const Spacer(),
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: ElevatedButton(
//                   onPressed: () => _saveAndContinue(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     minimumSize: const Size(double.infinity, 55),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: const Text(
//                     'Continue',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageOption(Map<String, dynamic> language) {
//     final isSelected = _selectedLanguage == language['name'];
//     return GestureDetector(
//       onTap: () => setState(() => _selectedLanguage = language['name']),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.blue.withOpacity(0.2)
//               : Colors.white.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: isSelected
//                 ? const Color.fromARGB(255, 92, 92, 94)
//                 : Colors.white.withOpacity(0.1),
//           ),
//         ),
//         child: Row(
//           children: [
//             Text(language['flag'], style: const TextStyle(fontSize: 32)),
//             const SizedBox(width: 16),
//             Text(
//               language['name'],
//               style: const TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             const Spacer(),
//             if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveAndContinue(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_selected_language', true);

//     // Find language code
//     final selectedLang = _languages.firstWhere(
//       (l) => l['name'] == _selectedLanguage,
//     );

//     // Update language provider - ✅ FIXED: Use correct method name
//     final languageProvider = Provider.of<LanguageProvider>(
//       context,
//       listen: false,
//     );
//     languageProvider.setLanguage(
//       Locale(selectedLang['code']),
//     ); // ✅ Use setLanguage, not setLocale

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const InterestScreen()),
//     );
//   }
// }

import 'package:facebook_video_downloader/features/interest/interestscreen.dart';
import 'package:facebook_video_downloader/features/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String _selectedLanguage = 'English';
  final List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'اردو', 'code': 'ur', 'flag': '🇵🇰'},
    {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Language Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language,
                size: 50,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You can choose the language and customise your application in the language you want.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Language List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = _selectedLanguage == language['name'];
                  return _buildLanguageOption(language, isSelected);
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => _saveAndContinue(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, dynamic> language, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language['name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  language['flag'],
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language['name'],
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue.shade700, size: 24),
          ],
        ),
      ),
    );
  }

  void _saveAndContinue(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('has_selected_language', true);
  await prefs.setString('selected_language_name', _selectedLanguage);

  // Find language code
  final selectedLang = _languages.firstWhere(
    (l) => l['name'] == _selectedLanguage,
  );

  // Update language provider
  final languageProvider = Provider.of<LanguageProvider>(
    context,
    listen: false,
  );
  languageProvider.setLanguage(Locale(selectedLang['code']));

  if (mounted) {
    // Go to Interest screen (one-time)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InterestScreen()),
    );
  }
  }
}