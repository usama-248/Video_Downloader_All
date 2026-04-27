// //workingggggggggggggg

// import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:open_file/open_file.dart';

// class HistoryScreen extends StatelessWidget {
//   const HistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Download History'),
//         actions: [
//           Consumer<DownloadController>(
//             builder: (context, controller, child) {
//               if (controller.downloadHistory.isEmpty) return const SizedBox();
//               return IconButton(
//                 icon: const Icon(Icons.delete_sweep),
//                 onPressed: () => _clearAll(context, controller),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer<DownloadController>(
//         builder: (context, controller, child) {
//           if (controller.downloadHistory.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.video_library, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text('No downloads yet'),
//                   SizedBox(height: 8),
//                   Text('Download videos from the browser'),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             itemCount: controller.downloadHistory.length,
//             itemBuilder: (context, index) {
//               final item = controller.downloadHistory[index];
//               return Card(
//                 margin: const EdgeInsets.all(8),
//                 child: ListTile(
//                   leading: const Icon(Icons.video_file, size: 40),
//                   title: Text(item['fileName'], maxLines: 1),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Quality: ${item['quality']} | Size: ${item['fileSize']}',
//                       ),
//                       Text(
//                         _formatDate(item['dateTime']),
//                         style: const TextStyle(fontSize: 11),
//                       ),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.play_arrow, color: Colors.green),
//                     onPressed: () => OpenFile.open(item['filePath']),
//                   ),
//                   onLongPress: () => _deleteItem(context, controller, item),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   String _formatDate(String dateTimeStr) {
//     final dateTime = DateTime.parse(dateTimeStr);
//     final now = DateTime.now();
//     final diff = now.difference(dateTime);

//     if (diff.inDays > 0) return '${diff.inDays}d ago';
//     if (diff.inHours > 0) return '${diff.inHours}h ago';
//     if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
//     return 'Just now';
//   }

//   void _deleteItem(
//     BuildContext context,
//     DownloadController controller,
//     Map<String, dynamic> item,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Video'),
//         content: Text('Delete "${item['fileName']}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               controller.deleteHistoryItem(item['id'], item['filePath']);
//               Navigator.pop(context);
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _clearAll(BuildContext context, DownloadController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All'),
//         content: const Text('Delete all downloaded videos?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               controller.clearAllHistory();
//               Navigator.pop(context);
//             },
//             child: const Text(
//               'Delete All',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//workingggggggggggggg

import 'package:facebook_video_downloader/features/downloaders/download_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download History'),
        actions: [
          Consumer<DownloadController>(
            builder: (context, controller, child) {
              if (controller.downloadHistory.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _clearAll(context, controller),
              );
            },
          ),
        ],
      ),
      body: Consumer<DownloadController>(
        builder: (context, controller, child) {
          if (controller.downloadHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No downloads yet'),
                  SizedBox(height: 8),
                  Text('Download videos from the browser'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.downloadHistory.length,
            itemBuilder: (context, index) {
              final item = controller.downloadHistory[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: FutureBuilder<String?>(
                    future: _getThumbnail(item['filePath']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Icon(Icons.video_file, size: 40);
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(snapshot.data!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        );
                      }

                      return const Icon(Icons.video_file, size: 40);
                    },
                  ),
                  title: Text(item['fileName'], maxLines: 1),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quality: ${item['quality']} | Size: ${item['fileSize']}',
                      ),
                      Text(
                        _formatDate(item['dateTime']),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => OpenFile.open(item['filePath']),
                  ),
                  onLongPress: () => _deleteItem(context, controller, item),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _getThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  String _formatDate(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _deleteItem(
    BuildContext context,
    DownloadController controller,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Delete "${item['fileName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteHistoryItem(item['id'], item['filePath']);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAll(BuildContext context, DownloadController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Delete all downloaded videos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
