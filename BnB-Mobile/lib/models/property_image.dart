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
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? json['propertyId'] ?? 0,
      path: json['path'] ?? '',
      displayOrder: json['display_order'] ?? json['displayOrder'] ?? 0,
    );
  }

  factory PropertyImage.fromUrl(String url, int order) {
    return PropertyImage(
      id: 0,
      propertyId: 0,
      path: url,
      displayOrder: order,
    );
  }

  String get fullUrl {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    String base = Constants.baseUrl.replaceAll('/api', '');
    String adjustedPath = path.startsWith('/') ? path : '/$path';
    return '$base$adjustedPath';
  }
}