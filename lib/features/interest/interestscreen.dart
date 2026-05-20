


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_video_downloader/core/config/app_features.dart';
import 'package:facebook_video_downloader/l10n/app_localizations.dart';

/// Brand blues and neutrals aligned with the app splash screen.
const Color _kBrandBlue = Color(0xFF0066ff);
const Color _kTextPrimary = Color(0xFF1F2937);
const Color _kTextSecondary = Color(0xFF6B7280);

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final Set<String> _selectedInterests = {};

  final List<Map<String, dynamic>> _interests = [
    {
      'icon': Icons.local_airport,
      'name': 'Aviation',
      'color': Colors.blueAccent,
    },
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
    {
      'icon': Icons.local_hospital,
      'name': 'Health care',
      'color': Colors.redAccent,
    },
    {'icon': Icons.public, 'name': 'Geography', 'color': Colors.green.shade700},
    {'icon': Icons.attach_money, 'name': 'Finance', 'color': Colors.amber},
    {'icon': Icons.pets, 'name': 'Cats', 'color': Colors.deepOrange},
    {'icon': Icons.psychology, 'name': 'Mental Health', 'color': Colors.indigo},
    {'icon': Icons.code, 'name': 'Programming', 'color': Colors.blueGrey},
    {'icon': Icons.movie, 'name': 'Cinema', 'color': Colors.deepPurple},
    {'icon': Icons.sports_soccer, 'name': 'Sports', 'color': Colors.green},
    {
      'icon': Icons.flight_takeoff,
      'name': 'Travel',
      'color': Colors.lightBlueAccent,
    },
    {'icon': Icons.sports_esports, 'name': 'Gaming', 'color': Colors.blue},
    {
      'icon': Icons.camera_alt,
      'name': 'Photography',
      'color': Colors.grey.shade600,
    },
    {
      'icon': Icons.design_services,
      'name': 'Design',
      'color': Colors.pink.shade400,
    },
    {'icon': Icons.wb_twilight, 'name': 'UFO', 'color': Colors.indigo.shade900},
    {
      'icon': Icons.music_note,
      'name': 'Music',
      'color': Colors.deepPurpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kBrandBlue.withOpacity(0.09), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                localizations.selectInterests,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.whatsYourInterests,
                style: TextStyle(fontSize: 14, color: _kTextSecondary),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _interests.length,
                    itemBuilder: (context, index) {
                      final interest = _interests[index];
                      final isSelected = _selectedInterests.contains(
                        interest['name'],
                      );
                      final color = interest['color'] as Color;
                      return _buildInterestCard(
                        interest: interest,
                        isSelected: isSelected,
                        color: color,
                        onTap: () => setState(
                          () => _toggleInterest(interest['name'] as String),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedInterests.length >= 2
                            ? () => _saveAndContinue(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBrandBlue,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '${localizations.continueText} (${_selectedInterests.length}/2+)',
                          style: TextStyle(
                            color: _selectedInterests.length >= 2
                                ? Colors.white
                                : _kTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedInterests.length < 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          localizations.selectAtLeastTwo,
                          style: TextStyle(
                            fontSize: 12,
                            color: _kTextSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestCard({
    required Map<String, dynamic> interest,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  colors: [_kBrandBlue, Color.lerp(_kBrandBlue, color, 0.35)!],
                )
              : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected ? _kBrandBlue : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kBrandBlue.withOpacity(0.22)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              interest['icon'] as IconData,
              size: 32,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 10),
            Text(
              interest['name'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : _kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
  }

  Future<void> _saveAndContinue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_interests', true);
    await prefs.setStringList(
      'selected_interests',
      _selectedInterests.toList(),
    );

    if (AppFeatures.showPremiumScreen) {
      Get.offAllNamed('/premium');
    } else {
      await prefs.setBool('has_seen_premium', true);
      Get.offAllNamed('/home');
    }
  }
}