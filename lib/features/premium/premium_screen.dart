import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Premium',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[400]!, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Text(
                    'START LIKE A PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unlock All Features',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Plan Selection Row
            Row(
              children: [
                Expanded(child: _buildPlanCard('BASIC', false)),
                const SizedBox(width: 12),
                Expanded(child: _buildPlanCard('PREMIUM', true)),
              ],
            ),
            const SizedBox(height: 24),

            // Features List
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildFeatureRow('Unlimited Video Downloads', false),
            const SizedBox(height: 12),
            _buildFeatureRow('Download in HD Quality', false),
            const SizedBox(height: 12),
            _buildFeatureRow('Ultra-Fast Download Speed', true),
            const SizedBox(height: 12),
            _buildFeatureRow('Watch Trending', false),
            const SizedBox(height: 12),
            _buildFeatureRow('Download anything', false),

            const Spacer(),

            // Start Free Trial Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle free trial
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Free Trial...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'START FREE TRIAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // No Payment Now Text
            Center(
              child: Text(
                'No Payment Now!',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String plan, bool isPremium) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isPremium ? Colors.blue : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isPremium
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Text(
            plan,
            style: TextStyle(
              color: isPremium ? Colors.blue : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (isPremium) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'RECOMMENDED',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool isChecked) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isChecked ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            isChecked ? Icons.check : Icons.close,
            size: 16,
            color: isChecked ? Colors.white : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: isChecked ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
