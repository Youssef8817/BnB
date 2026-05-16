// lib/models/property.dart
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
    List<PropertyImage> images = [];
    if (json['images'] is List) {
      images = (json['images'] as List)
          .map((i) => PropertyImage.fromJson(i as Map<String, dynamic>))
          .toList();
    } else if (json['image_urls'] is List) {
      final urls = (json['image_urls'] as List).cast<String>();
      for (var i = 0; i < urls.length; i++) {
        images.add(PropertyImage.fromUrl(urls[i], i));
      }
    }

    return Property(
      id: _toInt(json['id']),
      ownerId: _toInt(json['owner_id'] ?? json['ownerId']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: _toDouble(json['price']),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      areaMq: _toDouble(json['area_m2'] ?? json['areaMq']),
      rooms: _toInt(json['rooms']),
      status: json['status'] ?? 'available',
      images: images,
    );
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(0)}';
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().replaceAll(',', '')) ?? 0;
}
