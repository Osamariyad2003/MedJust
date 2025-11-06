import 'dart:convert';

class VideoNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? timestamp; // e.g., "05:30" or "01:15:45"

  VideoNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'timestamp': timestamp,
      };

  factory VideoNote.fromJson(Map<String, dynamic> json) {
    return VideoNote(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      timestamp: json['timestamp'] as String?,
    );
  }

  VideoNote copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? timestamp,
  }) {
    return VideoNote(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Extract timestamp from content if exists (for legacy support)
  static VideoNote fromLegacyNote(String id, String content, DateTime createdAt) {
    final timestampRegex = RegExp(r'^\[(\d{2}:\d{2}(?::\d{2})?)\]\s*(.+)$');
    final match = timestampRegex.firstMatch(content);

    if (match != null) {
      return VideoNote(
        id: id,
        content: match.group(2)!,
        createdAt: createdAt,
        timestamp: match.group(1),
      );
    }

    return VideoNote(
      id: id,
      content: content,
      createdAt: createdAt,
    );
  }

  Duration? get timestampDuration {
    if (timestamp == null) return null;

    final parts = timestamp!.split(':');
    if (parts.length == 2) {
      // MM:SS format
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    } else if (parts.length == 3) {
      // HH:MM:SS format
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }

    return null;
  }

  static String encodeList(List<VideoNote> notes) =>
      jsonEncode(notes.map((e) => e.toJson()).toList());

  static List<VideoNote> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) {
        if (json is String) {
          return VideoNote.fromLegacyNote(
            DateTime.now().millisecondsSinceEpoch.toString(),
            json,
            DateTime.now(),
          );
        }
        return VideoNote.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error decoding notes: $e');
      return [];
    }
  }
}
