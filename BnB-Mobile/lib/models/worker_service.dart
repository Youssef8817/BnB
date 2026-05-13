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
      id: _toInt(json['id']),
      workerId: _toInt(json['worker_id'] ?? json['workerId']),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      pricePerUnit: _toDouble(json['price_per_unit']),
      unit: json['unit'] ?? '',
      isAvailable: json['is_available'] ?? true,
      worker: json['worker'] != null ? User.fromJson(json['worker']) : null,
    );
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