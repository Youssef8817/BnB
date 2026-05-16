// lib/widgets/role_badge.dart
import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case 'user':
        color = Colors.blue;
        break;
      case 'worker':
        color = Colors.orange;
        break;
      case 'admin':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(role.toUpperCase()),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
