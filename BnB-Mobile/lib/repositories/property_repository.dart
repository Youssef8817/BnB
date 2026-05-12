// lib/repositories/property_repository.dart
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/property.dart';

class PropertyRepository {
  Future<List<Property>> getAll({String? city, String? status, double? minPrice, double? maxPrice}) async {
    return ApiService.getProperties(
      city: city,
      status: status,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<List<Property>> getMine() async {
    return await ApiService.getMyProperties();
  }
}