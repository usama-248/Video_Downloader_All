
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:facebook_video_downloader/controllers/language_controller.dart';

// class LanguageSelectorScreen extends StatelessWidget {
//   const LanguageSelectorScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final LanguageController languageController = Get.find<LanguageController>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           'selectLanguage'.tr,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Color.fromARGB(221, 0, 0, 0),
//           ),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(() => Column(
//         children: [
//           const SizedBox(height: 20),
//           // English Option
//           _buildLanguageOption(
//             icon: Icons.g_translate,
//             iconColor: Colors.blue,
//             languageName: 'English',
//             languageCode: 'en',
//             isSelected: languageController.currentLocale.value.languageCode == 'en',
//             onTap: () {
//               _changeLanguage('en', 'English', languageController);
//             },
//           ),
//           _buildDivider(),
//           // Urdu Option
//           _buildLanguageOption(
//             icon: Icons.g_translate,
//             iconColor: Colors.green,
//             languageName: 'اردو',
//             languageCode: 'ur',
//             isSelected: languageController.currentLocale.value.languageCode == 'ur',
//             onTap: () {
//               _changeLanguage('ur', 'اردو', languageController);
//             },
//           ),
//           _buildDivider(),
//           // Arabic Option
//           _buildLanguageOption(
//             icon: Icons.g_translate,
//             iconColor: Colors.red,
//             languageName: 'العربية',
//             languageCode: 'ar',
//             isSelected: languageController.currentLocale.value.languageCode == 'ar',
//             onTap: () {
//               _changeLanguage('ar', 'العربية', languageController);
//             },
//           ),
//           _buildDivider(),
          
//           const SizedBox(height: 30),
          
//           // Continue Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () {
//                   _saveAndContinue(languageController);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0066ff),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   'continue'.tr,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 20),
//         ],
//       )),
//     );
//   }

//   Widget _buildLanguageOption({
//     required IconData icon,
//     required Color iconColor,
//     required String languageName,
//     required String languageCode,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Row(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: iconColor, size: 28),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 languageName,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? Colors.blue : Colors.black87,
//                 ),
//               ),
//             ),
//             if (isSelected)
//               const Icon(Icons.check_circle, color: Colors.blue, size: 24),
//             if (!isSelected)
//               const Icon(
//                 Icons.radio_button_unchecked,
//                 color: Colors.grey,
//                 size: 24,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return const Divider(height: 0, thickness: 0.5, color: Colors.grey);
//   }

//   void _changeLanguage(
//     String languageCode,
//     String languageName,
//     LanguageController controller,
//   ) {
//     // Update the language using GetX controller
//     controller.changeLanguage(languageCode);
    
//     // Show confirmation message using GetX snackbar
//     Get.snackbar(
//       'languageChanged'.tr,
//       '$languageName ${'languageChangedMessage'.tr}',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 2),
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void _saveAndContinue(LanguageController controller) async {
//     // Save that user has selected a language
//     var SharedPreferences;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_selected_language', true);
    
//     // Navigate to Interest Screen
//     Get.offAllNamed('/interest');
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/controllers/language_controller.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is the correct way to get the controller
    final LanguageController controller = Get.find<LanguageController>();
    
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
          'selectLanguage'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => Column(
        children: [
          const SizedBox(height: 20),
          
          // English Option
          _buildLanguageOption(
            icon: Icons.g_translate,
            iconColor: Colors.blue,
            languageName: 'English',
            languageCode: 'en',
            isSelected: controller.currentLocale.value.languageCode == 'en',
            onTap: () => controller.changeLanguage('en'),
          ),
          _buildDivider(),
          
          // Urdu Option
          _buildLanguageOption(
            icon: Icons.g_translate,
            iconColor: Colors.green,
            languageName: 'اردو',
            languageCode: 'ur',
            isSelected: controller.currentLocale.value.languageCode == 'ur',
            onTap: () => controller.changeLanguage('ur'),
          ),
          _buildDivider(),
          
          // Arabic Option
          _buildLanguageOption(
            icon: Icons.g_translate,
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
                onPressed: () => _saveAndContinue(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066ff),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'continue'.tr,
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
      )),
    );
  }

  Widget _buildLanguageOption({
    required IconData icon,
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
              child: Icon(icon, color: iconColor, size: 28),
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

  Future<void> _saveAndContinue(LanguageController controller) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);
    
    Get.snackbar(
      'success'.tr,
      '${controller.getCurrentLanguageName()} ${'languageSelected'.tr}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed('/interest');
  }
}