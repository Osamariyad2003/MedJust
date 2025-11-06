import 'dart:convert';

class AzkarItem {
  final String id;
  final String title;
  final String content;
  final bool completed;
  final DateTime createdAt;
  final List<bool> weekChecks; // index 0 = Sunday, ... 6 = Saturday

  AzkarItem({
    required this.id,
    required this.title,
    required this.content,
    required this.completed,
    required this.createdAt,
    List<bool>? weekChecks,
  }) : weekChecks = weekChecks ?? List<bool>.filled(7, false);

  AzkarItem copyWith({
    String? id,
    String? title,
    String? content,
    bool? completed,
    DateTime? createdAt,
    List<bool>? weekChecks,
  }) {
    return AzkarItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      weekChecks: weekChecks ?? List<bool>.from(this.weekChecks),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
        'weekChecks': weekChecks, // list of bools
      };

  factory AzkarItem.fromJson(Map<String, dynamic> json) => AzkarItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        weekChecks: (json['weekChecks'] as List<dynamic>?)
                ?.map((e) => e == true)
                .toList() ??
            List<bool>.filled(7, false),
      );

  static String encodeList(List<AzkarItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<AzkarItem> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => AzkarItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
