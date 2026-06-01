


class Constants {
  static const String downloadFolder = 'VideoDownloads';
  static const List<String> videoExtensions = [
    '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m3u8'
  ];
  
  static const List<String> videoHosts = [
    // ONLY Facebook 
    'facebook.com', 'fb.watch', 'fbcdn.net', 'fbsv.com'
  ];
}

class VideoQuality {
  static const Map<String, String> qualities = {

    '720p': '720',
    '480p': '480',
    '360p': '360',
    '240p': '240',
    '144p': '144',
  };

  
}
