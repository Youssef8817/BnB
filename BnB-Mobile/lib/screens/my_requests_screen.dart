import 'package:b_and_b/theme/app_theme.dart';
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
          backgroundColor: AppColors.errorBg,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

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
                      BackButton2(
                          onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Requests', style: AppText.h3),
                          Text(
                            '${_requests.length} request${_requests.length == 1 ? '' : 's'}',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : _requests.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: AppColors.accent,
                              backgroundColor: AppColors.surface,
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
              color: AppColors.accentSoft,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.assignment_outlined,
                color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No Requests Yet', style: AppText.h4),
          const SizedBox(height: 6),
          Text('Your service requests will appear here.',
              style: AppText.bodySmall),
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
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDeep],
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
                        style: AppText.h4.copyWith(
                            fontSize: 15, letterSpacing: 0.2),
                      ),
                      if (workerName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(workerName, style: AppText.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: request.status),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1,
                color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 14),

            // Meta
            Row(
              children: [
                _MetaItem(icon: Icons.calendar_today_outlined, label: date),
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
              GlassBox(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded,
                        size: 14,
                        color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Review button for completed requests
            if (request.status == 'completed') ...[
              const SizedBox(height: 14),
              GradientButton(
                label: 'Leave a Review',
                icon: Icons.star_outline_rounded,
                onTap: onReviewTap,
                height: 44,
              ),
            ],
          ],
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
      style: AppText.bodySmall.copyWith(fontSize: 12),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13,
            color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        overflow ? Flexible(child: text) : text,
      ],
    );
  }
}
