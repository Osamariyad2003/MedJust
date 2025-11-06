class FileModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final String description;
  final DateTime uploadedAt;

  FileModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.description,
    required this.uploadedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['fileId'],
      name: json['title'],
      url: json['url'],
      type: json['fileType'],
      size: json['fileSize'],
      description: json['description'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': id,
      'title': name,
      'url': url,
      'fileType': type,
      'fileSize': size,
      'description': description,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
