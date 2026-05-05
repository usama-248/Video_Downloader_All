import 'package:facebook_video_downloader/features/home/home_screen.dart';
import 'package:facebook_video_downloader/features/premium/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:facebook_video_downloader/features/home/home_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header Section
              const Text(
                "Let's select your interests.",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 59, 70, 228),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select two or more to proceed.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 59, 70, 228),
                ),
              ),
              const SizedBox(height: 32),
              // Interests Grid
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
                      );
                    },
                  ),
                ),
              ),
              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: _selectedInterests.length >= 2
                            ? LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent,
                                ],
                              )
                            : null,
                        color: _selectedInterests.length >= 2
                            ? null
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedInterests.length >= 2
                            ? () => _saveAndContinue()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Continue (${_selectedInterests.length}/2+)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 59, 70, 228),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedInterests.length < 2)
                      Text(
                        'Select at least 2 interests to continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 59, 70, 228),
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
  }) {
    return GestureDetector(
      onTap: () => _toggleInterest(interest['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                )
              : null,
          color: isSelected
              ? null
              : const Color.fromARGB(255, 55, 42, 238).withOpacity(0.08),
          border: Border.all(
            color: isSelected
                ? color
                : const Color.fromARGB(255, 46, 45, 45).withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
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
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        // Allow unlimited selection
        _selectedInterests.add(interest);
      }
    });
  }

  void _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_interests', true);

    // After interests, go to Premium (which will then go to Home)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
    }
  }
}
