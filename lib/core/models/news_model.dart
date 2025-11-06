class News {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String author;
  final DateTime publishedAt;
  final List<String> tags;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.tags,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      author: json['author'],
      publishedAt: DateTime.parse(json['publishedAt']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'tags': tags,
    };
  }
}
