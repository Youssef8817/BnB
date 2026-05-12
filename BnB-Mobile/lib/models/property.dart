// lib/models/property.dart
import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/property_image.dart';

class Property {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final double price;
  final String location;
  final String city;
  final double areaMq;
  final int rooms;
  final String status;
  final List<PropertyImage> images;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.areaMq,
    required this.rooms,
    required this.status,
    required this.images,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Parse images list
    List<PropertyImage> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List)
          .map((i) => PropertyImage.fromJson(i))
          .toList();
    }

    return Property(
      id: json['id'],
      ownerId: json['ownerId'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      location: json['location'],
      city: json['city'],
      areaMq: json['areaMq'].toDouble(),
      rooms: json['rooms'],
      status: json['status'],
      images: images,
    );
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(0)}';
  }
}