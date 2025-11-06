import 'dart:convert';

enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int pomodorosCompleted;
  final int estimatedPomodoros;
  final int totalMinutesSpent;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.pomodorosCompleted = 0,
    this.estimatedPomodoros = 1,
    this.totalMinutesSpent = 0,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    int? pomodorosCompleted,
    int? estimatedPomodoros,
    int? totalMinutesSpent,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      pomodorosCompleted: pomodorosCompleted ?? this.pomodorosCompleted,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      totalMinutesSpent: totalMinutesSpent ?? this.totalMinutesSpent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.name, // Changed to use .name instead of .index
    'priority': priority.name, // Changed to use .name instead of .index
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'pomodorosCompleted': pomodorosCompleted,
    'estimatedPomodoros': estimatedPomodoros,
    'totalMinutesSpent': totalMinutesSpent,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(), // Convert to string
      title: json['title'] as String,
      description: json['description'] as String?,
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      pomodorosCompleted: (json['pomodorosCompleted'] as num?)?.toInt() ?? 0,
      estimatedPomodoros: (json['estimatedPomodoros'] as num?)?.toInt() ?? 1,
      totalMinutesSpent: (json['totalMinutesSpent'] as num?)?.toInt() ?? 0,
    );
  }

  static TaskStatus _parseStatus(dynamic value) {
    if (value is int) {
      return TaskStatus.values[value];
    }
    if (value is String) {
      return TaskStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskStatus.pending,
      );
    }
    return TaskStatus.pending;
  }

  static TaskPriority _parsePriority(dynamic value) {
    if (value is int) {
      return TaskPriority.values[value];
    }
    if (value is String) {
      return TaskPriority.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskPriority.medium,
      );
    }
    return TaskPriority.medium;
  }

  static String encodeList(List<TaskModel> tasks) =>
      jsonEncode(tasks.map((e) => e.toJson()).toList());

  static List<TaskModel> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error decoding tasks: $e');
      return [];
    }
  }
}
