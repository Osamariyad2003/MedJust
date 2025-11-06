import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> images;
  final DateTime createdAt;
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.images,
    required this.createdAt,
    this.quantity = 1,
  });
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? images,
    DateTime? createdAt,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      quantity: quantity ?? this.quantity,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle Timestamp conversion
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    // Handle images array
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = List<String>.from(json['images'].map((i) => i.toString()));
      }
    }

    return Product(
      id: json['id'] ?? json['productId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      categoryId: json['categoryId'] ?? '',
      images: imagesList,
      createdAt: createdAt,
      quantity: (json['quantity'] is int) ? json['quantity'] as int : 1,
    );
  }

  @override
  List<Object?> get props => [id, name, price, categoryId, createdAt, quantity];
}
