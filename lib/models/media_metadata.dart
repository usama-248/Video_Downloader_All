enum MediaPlatform {
  facebook,
  instagram,
  twitter,
  youtube,
  tiktok,
  unsupported,
}

enum MediaType {
  image,
  video,
  unknown,
}

class MediaMetadata {
  final String sourceUrl;
  final MediaPlatform platform;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final MediaType type;
  final bool publiclyAccessible;
  final bool downloadPermitted;
  final String legalMessage;

  MediaMetadata({
    required this.sourceUrl,
    required this.platform,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.type,
    required this.publiclyAccessible,
    required this.downloadPermitted,
    required this.legalMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceUrl': sourceUrl,
      'platform': platform.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toString().split('.').last,
      'publiclyAccessible': publiclyAccessible,
      'downloadPermitted': downloadPermitted,
      'legalMessage': legalMessage,
    };
  }

  factory MediaMetadata.fromJson(Map<String, dynamic> json) {
    return MediaMetadata(
      sourceUrl: json['sourceUrl'] as String,
      platform: _parsePlatform(json['platform'] as String? ?? 'unsupported'),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: _parseType(json['type'] as String? ?? 'unknown'),
      publiclyAccessible: json['publiclyAccessible'] as bool? ?? false,
      downloadPermitted: json['downloadPermitted'] as bool? ?? false,
      legalMessage: json['legalMessage'] as String? ?? '',
    );
  }

  static MediaPlatform _parsePlatform(String value) {
    switch (value.toLowerCase()) {
      case 'facebook':
        return MediaPlatform.facebook;
      case 'instagram':
        return MediaPlatform.instagram;
      case 'twitter':
        return MediaPlatform.twitter;
      case 'youtube':
        return MediaPlatform.youtube;
      case 'tiktok':
        return MediaPlatform.tiktok;
      default:
        return MediaPlatform.unsupported;
    }
  }

  static MediaType _parseType(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.unknown;
    }
  }
}