// lib/models/worker_service.dart
import 'package:b_and_b/models/user.dart';

class WorkerService {
  final int id;
  final int workerId;
  final String type;
  final String description;
  final double pricePerUnit;
  final String unit;
  final bool isAvailable;
  final User? worker; // This is optional because sometimes we might not have the worker details embedded

  WorkerService({
    required this.id,
    required this.workerId,
    required this.type,
    required this.description,
    required this.pricePerUnit,
    required this.unit,
    required this.isAvailable,
    this.worker,
  });

  factory WorkerService.fromJson(Map<String, dynamic> json) {
    return WorkerService(
      id: json['id'],
      workerId: json['worker_id'] ?? json['workerId'] ?? 0,
      type: json['type'],
      description: json['description'],
      pricePerUnit: json['price_per_unit'].toDouble(),
      unit: json['unit'],
      isAvailable: json['is_available'],
      worker: json['worker'] != null ? User.fromJson(json['worker']) : null,
    );
  }
}