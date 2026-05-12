import 'worker_service.dart';

class ServiceRequest {
  final int id;
  final int userId;
  final int workerServiceId;
  final String note;
  final String address;
  final String status;
  final WorkerService? workerService;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.workerServiceId,
    required this.note,
    required this.address,
    required this.status,
    this.workerService,
    required this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    // API returns nested objects: user:{id,name} and worker_service:{id,type,...}
    final userObj = json['user'] as Map<String, dynamic>?;
    final wsObj = json['worker_service'] as Map<String, dynamic>?;
    return ServiceRequest(
      id: json['id'],
      userId: userObj?['id'] ?? json['user_id'] ?? json['userId'] ?? 0,
      workerServiceId: wsObj?['id'] ?? json['worker_service_id'] ?? json['workerServiceId'] ?? 0,
      note: json['note'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? 'pending',
      workerService: wsObj != null ? WorkerService.fromJson(wsObj) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}