import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? uninumber;
  final Map<String, String>? yearId;
  final String? address;
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.uninumber,
    this.address,
    this.yearId,
  });
  copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? uninumber,
    Map<String, String>? yearId,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uninumber: uninumber ?? this.uninumber,
      yearId: yearId ?? this.yearId,
      address: address ?? this.address,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    dynamic yearIdValue = json['yearId'];
    Map<String, String>? yearIdMap;
    if (yearIdValue != null) {
      if (yearIdValue is Map) {
        yearIdMap = Map<String, String>.from(yearIdValue);
      } else if (yearIdValue is String) {
        // If it's a string, store as {"id": yearIdValue}
        yearIdMap = {"id": yearIdValue};
      }
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] is Timestamp
                  ? json['createdAt'].toDate()
                  : DateTime.parse(json['createdAt']))
              : DateTime.now(),

      uninumber: json['uninumber'],
      updatedAt:
          json['updatedAt'] != null
              ? (json['updatedAt'] is Timestamp
                  ? json['updatedAt'].toDate()
                  : DateTime.parse(json['updatedAt']))
              : null,
      yearId: yearIdMap,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'uninumber': uninumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'address': address,
      'yearId': yearId,
    };
  }
}
