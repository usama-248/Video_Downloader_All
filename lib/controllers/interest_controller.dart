import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';

class InterestController extends GetxController {
  var selectedInterests = <String>{}.obs;
  
  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.local_airport, 'name': 'Aviation', 'color': Colors.blueAccent},
    {'icon': Icons.brush, 'name': 'Art', 'color': Colors.purple},
    {'icon': Icons.currency_bitcoin, 'name': 'Crypto', 'color': Colors.orange},
    {'icon': Icons.bakery_dining, 'name': 'Baking', 'color': Colors.brown},
    {'icon': Icons.grass, 'name': 'Botany', 'color': Colors.green},
    {'icon': Icons.directions_car, 'name': 'Cars', 'color': Colors.red},
    {'icon': Icons.house, 'name': 'Real Estate', 'color': Colors.teal},
    {'icon': Icons.smartphone, 'name': 'Technology', 'color': Colors.cyan},
    {'icon': Icons.checkroom, 'name': 'Fashion', 'color': Colors.pink},
    {'icon': Icons.pets, 'name': 'Dogs', 'color': Colors.orange.shade700},
    {'icon': Icons.flutter_dash, 'name': 'Birds', 'color': Colors.lightBlue},
    {'icon': Icons.local_hospital, 'name': 'Health care', 'color': Colors.redAccent},
    {'icon': Icons.public, 'name': 'Geography', 'color': Colors.green.shade700},
    {'icon': Icons.attach_money, 'name': 'Finance', 'color': Colors.amber},
    {'icon': Icons.pets, 'name': 'Cats', 'color': Colors.deepOrange},
    {'icon': Icons.psychology, 'name': 'Mental Health', 'color': Colors.indigo},
    {'icon': Icons.code, 'name': 'Programming', 'color': Colors.blueGrey},
    {'icon': Icons.movie, 'name': 'Cinema', 'color': Colors.deepPurple},
    {'icon': Icons.sports_soccer, 'name': 'Sports', 'color': Colors.green},
    {'icon': Icons.flight_takeoff, 'name': 'Travel', 'color': Colors.lightBlueAccent},
    {'icon': Icons.sports_esports, 'name': 'Gaming', 'color': Colors.blue},
    {'icon': Icons.camera_alt, 'name': 'Photography', 'color': Colors.grey.shade600},
    {'icon': Icons.design_services, 'name': 'Design', 'color': Colors.pink.shade400},
    {'icon': Icons.wb_twilight, 'name': 'UFO', 'color': Colors.indigo.shade900},
    {'icon': Icons.music_note, 'name': 'Music', 'color': Colors.deepPurpleAccent},
  ];
  
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }
  
  Future<void> saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_interests', true);
    await prefs.setStringList('selected_interests', selectedInterests.toList());
    
    if (AppFeatures.showPremiumScreen) {
      Get.offAllNamed('/premium');
    } else {
      await prefs.setBool('has_seen_premium', true);
      Get.offAllNamed('/home');
    }
  }
}