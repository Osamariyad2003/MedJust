class Professor {
  final String id;
  final String name;
  final String department;
  final String? email;
  final String? officeLocation;
  final String? imageUrl;
  final String? bio;
  final List<String> subjectIds;

  Professor({
    required this.id,
    required this.name,
    required this.department,
    this.email,
    this.officeLocation,
    this.imageUrl,
    this.bio,
    required this.subjectIds,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'],
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      email: json['email'],
      officeLocation: json['officeLocation'],
      imageUrl: json['imageUrl'],
      bio: json['bio'],
      subjectIds: List<String>.from(json['subjectIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'email': email,
      'officeLocation': officeLocation,
      'imageUrl': imageUrl,
      'bio': bio,
      'subjectIds': subjectIds,
    };
  }
}
