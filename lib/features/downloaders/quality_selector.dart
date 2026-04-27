import 'package:flutter/material.dart';
import '../../core/utils.dart';

class QualitySelector extends StatefulWidget {
  final String videoUrl;
  final Function(String quality, String videoUrl) onDownload;

  const QualitySelector({
    Key? key,
    required this.videoUrl,
    required this.onDownload,
  }) : super(key: key);

  @override
  State<QualitySelector> createState() => _QualitySelectorState();
}

class _QualitySelectorState extends State<QualitySelector> {
  String _selectedQuality = '720p';
  final Map<String, VideoQualityData> _qualities = {
    '1080p': VideoQualityData(label: '1080p', size: 50 * 1024 * 1024, urlSuffix: 'hd'),
    '720p': VideoQualityData(label: '720p', size: 30 * 1024 * 1024, urlSuffix: 'hd'),
    '480p': VideoQualityData(label: '480p', size: 20 * 1024 * 1024, urlSuffix: 'sd'),
    '360p': VideoQualityData(label: '360p', size: 10 * 1024 * 1024, urlSuffix: 'sd'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Video Quality',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          ..._qualities.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value.label),
              subtitle: Text(Utils.formatFileSize(entry.value.size)),
              value: entry.key,
              groupValue: _selectedQuality,
              onChanged: (value) {
                setState(() {
                  _selectedQuality = value!;
                });
              },
            );
          }),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onDownload(_selectedQuality, widget.videoUrl);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Download Now'),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class VideoQualityData {
  final String label;
  final int size;
  final String urlSuffix;

  VideoQualityData({
    required this.label,
    required this.size,
    required this.urlSuffix,
  });
}