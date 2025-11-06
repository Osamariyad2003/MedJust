class Subject {
  final String id;
  final String name;
  final String yearId;
  final String? description;
  final String? professorId;
  final String? professorName;
  final int? resourcesCount;
  // You can add lecturesCount here if needed
  final String? imageUrl;

  Subject({
    required this.id,
    required this.name,
    required this.yearId,
    this.description,
    this.professorId,
    this.professorName,
    this.resourcesCount,
    this.imageUrl,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      yearId: json['yearId'] ?? '',
      description: json['description'], // Nullable field
      professorId: json['professorId'], // Nullable field
      professorName: json['professorName'], // Nullable field
      imageUrl: json['imageUrl'], // Nullable field
    );
  }
}
