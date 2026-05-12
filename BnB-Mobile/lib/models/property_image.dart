// lib/models/property_image.dart
import 'package:b_and_b/constants.dart';

class PropertyImage {
  final int id;
  final int propertyId;
  final String path;
  final int displayOrder;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.path,
    required this.displayOrder,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'],
      propertyId: json['propertyId'],
      path: json['path'],
      displayOrder: json['displayOrder'],
    );
  }

  String get fullUrl {
    // The API returns the path, we need to prepend the base URL without the '/api' part.
    String base = Constants.baseUrl.replaceAll('/api', '');
    // Ensure the path starts with a slash if it doesn't already.
    String adjustedPath = path.startsWith('/') ? path : '/$path';
    return '$base$adjustedPath';
  }
}