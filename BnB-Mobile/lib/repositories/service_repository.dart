// lib/repositories/service_repository.dart
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/models/service_request.dart';

class ServiceRepository {
  final ApiService _apiService = ApiService();

  Future<List<WorkerService>> getAll({String? type}) async {
    final services = await ApiService.getWorkerServices();
    if (type == null || type.isEmpty) {
      return services;
    }
    return services.where((service) => service.type == type).toList();
  }

  Future<List<ServiceRequest>> getMyRequests() async {
    return await ApiService.getMyRequests();
  }

  Future<List<ServiceRequest>> getIncomingRequests() async {
    return await ApiService.getIncomingRequests();
  }

  Future<void> updateRequestStatus(int id, String status) async {
    await ApiService.updateRequestStatus(id, status);
  }

  Future<void> updateWorkerService(int id, Map<String, dynamic> data) async {
    await ApiService.updateWorkerService(id, data);
  }

  Future<void> deleteWorkerService(int id) async {
    await ApiService.deleteWorkerService(id);
  }
}