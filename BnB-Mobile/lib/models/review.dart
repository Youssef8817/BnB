class Review {
  final int id;
  final int userId;
  final int workerServiceId;
  final int rating;
  final String comment;
  final String userName;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.workerServiceId,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user']?['id'] ?? 0,
      workerServiceId: json['worker_service_id'] ?? 0,
      rating: json['rating'],
      comment: json['comment'],
      userName: json['user']?['name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
