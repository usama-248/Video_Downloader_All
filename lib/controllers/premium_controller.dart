import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumController extends GetxController {
  var isLoading = false.obs;
  
  Future<void> skipToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_premium', true);
    Get.offAllNamed('/home');
  }
  
  Future<void> startFreeTrial() async {
    isLoading.value = true;
    
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
    
    isLoading.value = false;
    
    // Save premium status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_user', true);
    await prefs.setBool('has_seen_premium', true);
    
    Get.snackbar(
      'Premium Activated',
      'Premium activated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    // Go to Home after premium activation
    Get.offAllNamed('/home');
  }
}