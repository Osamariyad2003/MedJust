import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String? category;
  final String? summary;
  final String yearId;
  final bool isPinned;
  final String subjectId;
  final int? yearNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    this.category,
    this.summary,
    required this.yearId,
    this.isPinned = false,
    this.subjectId = '',
    this.yearNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt:
          json['publishedAt'] is Timestamp
              ? (json['publishedAt'] as Timestamp).toDate()
              : (json['publishedAt'] is DateTime
                  ? json['publishedAt'] as DateTime
                  : DateTime.now()),
      category: json['category'] as String?,
      summary: json['summary'] as String?,
      yearId: json['yearId'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      subjectId: json['subjectId'] as String? ?? '',

      yearNumber:
          json['yearNumber'] is int
              ? json['yearNumber'] as int
              : int.tryParse(json['yearNumber']?.toString() ?? ''),
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : (json['createdAt'] is DateTime
                  ? json['createdAt'] as DateTime
                  : null),
      updatedAt:
          json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : (json['updatedAt'] is DateTime
                  ? json['updatedAt'] as DateTime
                  : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'category': category,
      'summary': summary,
      'yearId': yearId,
      'isPinned': isPinned,
      'subjectId': subjectId,
      'yearNumber': yearNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
