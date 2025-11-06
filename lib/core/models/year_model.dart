class Year {
  final String id;
  final String name;
  final int order;
  final List<String> subjects;
  final String imageUrl;
  final String batch_name;
  final String academicSupervisor;
  final String actor;
  final String groupurl;

  Year({
    required this.id,
    required this.name,
    required this.order,
    required this.subjects,
    required this.imageUrl,
    required this.batch_name,
    this.academicSupervisor = '',
    this.actor = '',
    this.groupurl = '',
  });

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      order: json['order'] ?? 0,
      batch_name: json['batch_name'] ?? '',
      academicSupervisor: json['academic_supervisor'] ?? '',
      actor: json['actor'] ?? '',
      groupurl: json['group_url'] ?? '',
      subjects:
          json['subjects'] != null
              ? List<String>.from(json['subjects'])
              : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'batch_name': batch_name,
      'subjects': subjects,
      'imageUrl': imageUrl,
      'acadmic_supervisor': academicSupervisor,
      'actor': actor,
      'group_url': groupurl,
    };
  }
}
