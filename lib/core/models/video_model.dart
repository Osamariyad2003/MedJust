import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final Duration duration;
  final DateTime uploadedAt;
  final String platform;
  final String uploadedBy;
  final String lectureId;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.uploadedAt,
    this.platform = '',
    this.uploadedBy = '',
    required this.lectureId,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // Handle duration - it appears to be empty in your database
    Duration videoDuration = const Duration(minutes: 0);
    if (json['duration'] != null && json['duration'].toString().isNotEmpty) {
      try {
        if (json['duration'] is int) {
          videoDuration = Duration(seconds: json['duration']);
        } else {
          // Try to parse string duration if possible
          videoDuration = const Duration(minutes: 0);
        }
      } catch (_) {
        videoDuration = const Duration(minutes: 0);
      }
    }

    // Handle uploadedAt timestamp
    DateTime videoUploadedAt;
    if (json['uploadedAt'] is Timestamp) {
      videoUploadedAt = (json['uploadedAt'] as Timestamp).toDate();
    } else if (json['uploadedAt'] is String && json['uploadedAt'].isNotEmpty) {
      videoUploadedAt = DateTime.parse(json['uploadedAt']);
    } else {
      videoUploadedAt = DateTime.now();
    }

    return Video(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: videoDuration,
      uploadedAt: videoUploadedAt,
      platform: json['platform'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      lectureId: json['lectureId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'duration':
          duration.inMinutes.toString(), // Store as string to match your DB
      'uploadedAt': uploadedAt.toIso8601String(),
      'platform': platform,
      'uploadedBy': uploadedBy,
      'lectureId': lectureId,
    };
  }
}
