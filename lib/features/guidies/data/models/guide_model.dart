// lib/core/models/guide_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int order;

  GuideCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.order,
  });

  factory GuideCategory.fromJson(Map<String, dynamic> json) {
    return GuideCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'help',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'order': order,
  };
}

class GuideContent {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final List<String> keywords;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuideContent({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.keywords,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GuideContent.fromJson(Map<String, dynamic> json) {
    return GuideContent(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'content': content,
    'keywords': keywords,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final GuideContent? relatedContent;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.relatedContent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      relatedContent:
          json['relatedContent'] != null
              ? GuideContent.fromJson(json['relatedContent'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'relatedContent': relatedContent?.toJson(),
  };
}

class FAQItem {
  final String id;
  final String question;
  final String answer;
  final String categoryId;
  final int viewCount;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.categoryId,
    required this.viewCount,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      categoryId: json['categoryId'] ?? '',
      viewCount: json['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'categoryId': categoryId,
    'viewCount': viewCount,
  };
}
