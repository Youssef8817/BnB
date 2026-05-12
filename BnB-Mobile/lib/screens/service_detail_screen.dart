import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_service.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  WorkerService? _service;
  List<Review> _reviews = [];
  bool _isLoading = true;
  final _noteController = TextEditingController();
  final _addressController = TextEditingController();

  static const _typeIcons = {
    'plumbing': Icons.plumbing,
    'painting': Icons.format_paint,
    'tiling': Icons.grid_on,
    'electrical': Icons.electrical_services,
    'carpentry': Icons.carpenter,
    'finishing': Icons.home_repair_service,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = await ApiService.getWorkerService(widget.serviceId);
      final reviews = await ApiService.getServiceReviews(widget.serviceId);
      setState(() {
        _service = service;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRequestSheet() {
    _noteController.clear();
    _addressController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Request Service', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.createServiceRequest(
                    widget.serviceId,
                    _noteController.text,
                    _addressController.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_service?.type ?? 'Service Detail')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _service == null
              ? const Center(child: Text('Service not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Icon(
                          _typeIcons[_service!.type] ?? Icons.build,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_service!.type.toUpperCase(),
                                  style: Theme.of(context).textTheme.titleLarge),
                              Text(
                                '${_service!.pricePerUnit.toStringAsFixed(0)} / ${_service!.unit}',
                                style: const TextStyle(color: Colors.green, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_service!.description),
                    const SizedBox(height: 12),
                    if (_service!.worker != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(_service!.worker!.name),
                        subtitle: Text(_service!.worker!.phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () => launchUrl(
                              Uri.parse('tel:${_service!.worker!.phone}')),
                        ),
                      ),
                    ],
                    const Divider(height: 32),
                    Row(
                      children: [
                        Text('Rating: ${_avgRating.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        RatingBarIndicator(
                          rating: _avgRating,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('(${_reviews.length})', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_reviews.isEmpty)
                      const Text('No reviews yet.', style: TextStyle(color: Colors.grey))
                    else
                      ..._reviews.map((r) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(r.userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      RatingBarIndicator(
                                        rating: r.rating.toDouble(),
                                        itemBuilder: (_, __) =>
                                            const Icon(Icons.star, color: Colors.amber),
                                        itemCount: 5,
                                        itemSize: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(r.comment),
                                ],
                              ),
                            ),
                          )),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showRequestSheet,
                      icon: const Icon(Icons.build),
                      label: const Text('Request Service'),
                    ),
                  ],
                ),
    );
  }
}
