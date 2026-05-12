import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final requests = await ApiService.getMyRequests();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No requests yet.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) => _RequestCard(
                      request: _requests[i],
                      onReviewTap: () =>
                          context.push('/review/${_requests[i].workerServiceId}'),
                    ),
                  ),
                ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onReviewTap;

  const _RequestCard({required this.request, required this.onReviewTap});

  @override
  Widget build(BuildContext context) {
    final ws = request.workerService;
    final serviceLabel = ws?.type ?? 'Service #${request.workerServiceId}';
    final workerName = ws?.worker?.name ?? '';
    final date =
        '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(serviceLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            if (workerName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(workerName,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ],
            if (request.status == 'completed') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReviewTap,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Leave Review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending' => (Colors.orange, 'Pending'),
      'accepted' => (Colors.blue, 'Accepted'),
      'completed' => (Colors.green, 'Completed'),
      'cancelled' => (Colors.grey, 'Cancelled'),
      _ => (Colors.grey, status),
    };
    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
