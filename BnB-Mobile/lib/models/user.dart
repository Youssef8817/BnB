// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}
