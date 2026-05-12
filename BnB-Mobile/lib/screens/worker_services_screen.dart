// lib/screens/worker_services_screen.dart
import 'package:flutter/material.dart';
import 'package:b_and_b/repositories/service_repository.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/widgets/service_card.dart';
import 'package:b_and_b/widgets/filter_chips_row.dart';
import 'package:b_and_b/widgets/empty_state.dart';

class WorkerServicesScreen extends StatefulWidget {
  const WorkerServicesScreen({Key? key}) : super(key: key);

  @override
  _WorkerServicesScreenState createState() => _WorkerServicesScreenState();
}

class _WorkerServicesScreenState extends State<WorkerServicesScreen> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  List<WorkerService> _services = [];
  bool _isLoading = true;
  String? _selectedType; // For type filter

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices({String? type}) async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceRepository.getAll(type: type);
      setState(() {
        _services = services;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Services'),
      ),
      body: Column(
        children: [
          // Filter chips row for type
          FilterChipsRow(
            options: ['All', 'plumbing', 'painting', 'tiling', 'electrical', 'carpentry', 'finishing'],
            selected: _selectedType == null ? 'All' : _selectedType,
            onSelected: (value) {
              if (value == 'All') {
                setState(() {
                  _selectedType = null;
                });
              } else {
                setState(() {
                  _selectedType = value;
                });
              }
              _loadServices(type: _selectedType);
            },
          ),
          const SizedBox(height: 8),
          // Services list
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _services.isEmpty
                  ? const EmptyState(
                      message: 'No services found',
                      icon: Icons.widgets,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadServices,
                      child: ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          return ServiceCard(service: _services[index]);
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}