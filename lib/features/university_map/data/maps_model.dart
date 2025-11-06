import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String type;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;

  const LocationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.description,
    this.imageUrl,
    this.videoUrl,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'description': description,
      'video_url': videoUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, location, type, description, videoUrl];
}
