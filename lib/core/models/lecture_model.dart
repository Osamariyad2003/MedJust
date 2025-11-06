import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_just/core/models/file_model.dart';
import 'package:med_just/core/models/quiz_model.dart';
import 'package:med_just/core/models/video_model.dart';

class Lecture {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String imageUrl;
  final DateTime createdAt; // This is correctly defined as DateTime

  Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.imageUrl,

    required this.createdAt,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    // Convert createdAt from Timestamp to DateTime
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now(); // Default
    }

    return Lecture(
      id: json['id'] ?? json['lectureId'] ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      subjectId: json['subjectId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(), // Fixed this line
    };
  }
}
