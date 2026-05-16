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

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final requests = await ApiService.getMyRequests();
      setState(() {
        _requests  = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF93000A),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Purple glow — top-right ─────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.95, -0.95),
                  radius: 0.9,
                  colors: [Color(0x556D3BD7), Color(0x000B1326)],
                ),
              ),
            ),
          ),
          // ── Blue glow — bottom-left ─────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.95, 0.95),
                  radius: 0.7,
                  colors: [Color(0x3300A2E6), Color(0x000B1326)],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _primary,
                              size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Requests',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${_requests.length} request${_requests.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: _onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: _primary))
                      : _requests.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: _primary,
                              backgroundColor: const Color(0xFF171F33),
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 32),
                                itemCount: _requests.length,
                                itemBuilder: (_, i) => _RequestCard(
                                  request: _requests[i],
                                  onReviewTap: () => context.push(
                                      '/review/${_requests[i].workerServiceId}'),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.assignment_outlined,
                color: _primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Requests Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDAE2FD),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your service requests will appear here.',
            style: TextStyle(fontSize: 14, color: Color(0xFFCBC3D7)),
          ),
        ],
      ),
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onReviewTap;

  const _RequestCard({required this.request, required this.onReviewTap});

  @override
  Widget build(BuildContext context) {
    final ws           = request.workerService;
    final serviceLabel = ws?.type ?? 'Service #${request.workerServiceId}';
    final workerName   = ws?.worker?.name ?? '';
    final price        = ws != null
        ? '\$${ws.pricePerUnit.toStringAsFixed(0)}/${ws.unit}'
        : '';
    final date =
        '${request.createdAt.day.toString().padLeft(2, '0')}/'
        '${request.createdAt.month.toString().padLeft(2, '0')}/'
        '${request.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — service name + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                    ),
                  ),
                  child: const Icon(Icons.handyman_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDAE2FD),
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (workerName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          workerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFCBC3D7)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: request.status),
              ],
            ),

            const SizedBox(height: 14),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 14),

            // Meta row
            Row(
              children: [
                _MetaItem(
                    icon: Icons.calendar_today_outlined, label: date),
                if (price.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _MetaItem(
                      icon: Icons.attach_money_rounded, label: price),
                ],
                if (request.address.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetaItem(
                      icon: Icons.location_on_outlined,
                      label: request.address,
                      overflow: true,
                    ),
                  ),
                ],
              ],
            ),

            // Note
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded,
                        size: 14,
                        color: const Color(0xFFCBC3D7)
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: const Color(0xFFCBC3D7)
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Review button for completed requests
            if (request.status == 'completed') ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onReviewTap,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33A078FF),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline_rounded,
                          color: Color(0xFF3C0091), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Leave a Review',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C0091),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending'   => (const Color(0xFFFFB74D), 'Pending'),
      'accepted'  => (const Color(0xFF89CEFF), 'Accepted'),
      'completed' => (const Color(0xFF4CAF50), 'Completed'),
      'cancelled' => (const Color(0xFF958EA0), 'Cancelled'),
      _           => (const Color(0xFF958EA0), status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Meta item ─────────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool overflow;
  const _MetaItem(
      {required this.icon, required this.label, this.overflow = false});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: overflow ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: 12,
        color: const Color(0xFFCBC3D7).withValues(alpha: 0.7),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13,
            color: const Color(0xFFCBC3D7).withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        overflow ? Flexible(child: text) : text,
      ],
    );
  }
}
