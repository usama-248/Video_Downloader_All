import 'package:facebook_video_downloader/features/onboarding/onboarding_data.dart';
import 'package:flutter/material.dart';


class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;

  const OnboardingPage({Key? key, required this.data, required this.pageIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Main card with video illustration
          _buildVideoCard(context),

          const SizedBox(height: 30),

          // User info and stats
          _buildUserInfo(),

          const SizedBox(height: 20),

          // Title and description
          _buildContent(),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[200]!, Colors.grey[100]!],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.smart_display_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),

            // Download progress bars (simulating the images)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildDownloadProgress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress() {
    // Different download states based on page
    if (pageIndex == 0) {
      return Column(
        children: [
          _buildProgressItem('Process of art design.mp4', null, 'Completed' as int?),
          const SizedBox(height: 8),
          _buildProgressItem('Historical Place.mp4', 66, 672),
        ],
      );
    } else if (pageIndex == 1) {
      return Column(
        children: [
          _buildProgressItem('Speech of Science.mp4', 180, 250),
          const SizedBox(height: 8),
          _buildProgressItem('Programming course.mp4', 110, 190),
        ],
      );
    } else {
      return Column(
        children: [
          _downloadCard(
            'Video Download',
            'Tap to download your favorite videos',
            Icons.download_rounded,
          ),
        ],
      );
    }
  }

  Widget _buildProgressItem(String title, int? current, int? total) {
    double progress = (current != null && total != null)
        ? current / total
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (current != null && total != null)
                Text(
                  '${current}MB/${total}MB',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (current != null && total != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _downloadCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            data.userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            _buildStat(Icons.favorite_border, data.likes),
            const SizedBox(width: 16),
            _buildStat(Icons.comment_outlined, data.comments),
            if (data.shares > 0) ...[
              const SizedBox(width: 16),
              _buildStat(Icons.share_outlined, data.shares),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data.description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
      ],
    );
  }
}
