// lib/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/services/api_service.dart';

class ServiceCard extends StatelessWidget {
  final WorkerService service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  IconData _iconForType(String type) {
    switch (type) {
      case 'plumbing':
        return Icons.water_drop;
      case 'painting':
        return Icons.format_paint;
      case 'tiling':
        return Icons.grid_on;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.handyman;
      case 'finishing':
        return Icons.brush;
      default:
        return Icons.build;
    }
  }

  void _showRequestSheet(BuildContext context) {
    final noteController = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Request ${service.type}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter an address')),
                            );
                            return;
                          }
                          setSheetState(() => isSubmitting = true);
                          try {
                            await ApiService.createServiceRequest(
                              service.id,
                              noteController.text.trim(),
                              addressController.text.trim(),
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Request sent!')),
                              );
                            }
                          } catch (e) {
                            setSheetState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text('Submit Request'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(service.type), size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service.type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Worker: ${service.worker?.name ?? 'Unknown'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: \$${service.pricePerUnit.toStringAsFixed(2)}/${service.unit}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              'Availability: ${service.isAvailable ? 'Available' : 'Not Available'}',
              style: TextStyle(
                fontSize: 14,
                color: service.isAvailable ? Colors.green : Colors.red,
              ),
            ),
            if (service.isAvailable) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showRequestSheet(context),
                  child: const Text('Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
