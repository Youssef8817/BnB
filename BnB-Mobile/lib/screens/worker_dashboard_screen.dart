import 'package:flutter/material.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/models/service_request.dart';
import 'package:b_and_b/widgets/empty_state.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Worker Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Services'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyServicesTab(),
            _IncomingRequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _MyServicesTab extends StatefulWidget {
  const _MyServicesTab();

  @override
  _MyServicesTabState createState() => _MyServicesTabState();
}

class _MyServicesTabState extends State<_MyServicesTab> {
  List<WorkerService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final services = await ApiService.getWorkerServices();
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

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteWorkerService(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showEditDialog(WorkerService service) async {
    final descController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.pricePerUnit.toString());
    final unitController = TextEditingController(text: service.unit);
    bool isAvailable = service.isAvailable;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price per unit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (v) => setDialogState(() => isAvailable = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await ApiService.updateWorkerService(service.id, {
                    'description': descController.text.trim(),
                    'price_per_unit': double.tryParse(priceController.text.trim()) ?? service.pricePerUnit,
                    'unit': unitController.text.trim(),
                    'is_available': isAvailable,
                  });
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service updated')),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_services.isEmpty) {
      return const EmptyState(
        message: 'You have no services yet',
        icon: Icons.build_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final s = _services[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                s.isAvailable ? Icons.check_circle : Icons.cancel,
                color: s.isAvailable ? Colors.green : Colors.red,
              ),
              title: Text(s.type, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${s.pricePerUnit.toStringAsFixed(2)}/${s.unit}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _showEditDialog(s);
                  if (value == 'delete') _delete(s.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IncomingRequestsTab extends StatefulWidget {
  const _IncomingRequestsTab();

  @override
  _IncomingRequestsTabState createState() => _IncomingRequestsTabState();
}

class _IncomingRequestsTabState extends State<_IncomingRequestsTab> {
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final requests = await ApiService.getIncomingRequests();
      setState(() {
        _requests = requests;
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

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiService.updateRequestStatus(id, status);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return Colors.orange;
      case 'accepted':  return Colors.blue;
      case 'completed': return Colors.green;
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_requests.isEmpty) {
      return const EmptyState(
        message: 'No incoming requests',
        icon: Icons.inbox_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final r = _requests[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Request #${r.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text(r.status,
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _statusColor(r.status),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Address: ${r.address}'),
                  if (r.note.isNotEmpty) Text('Note: ${r.note}'),
                  const SizedBox(height: 8),
                  if (r.status == 'pending')
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateStatus(r.id, 'accepted'),
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _updateStatus(r.id, 'cancelled'),
                          child: const Text('Cancel'),
                        ),
                      ],
                    )
                  else if (r.status == 'accepted')
                    ElevatedButton(
                      onPressed: () => _updateStatus(r.id, 'completed'),
                      child: const Text('Mark Completed'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
