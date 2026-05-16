import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/models/service_request.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      BackButton2(onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Worker Dashboard', style: AppText.h3),
                          Text(
                            'Manage services & requests',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: AppColors.gradientPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentDeep.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'My Services'),
                        Tab(text: 'Requests'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _MyServicesTab(),
                      _IncomingRequestsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Services Tab
// ─────────────────────────────────────────────────────────────────────────────

class _MyServicesTab extends StatefulWidget {
  const _MyServicesTab();

  @override
  _MyServicesTabState createState() => _MyServicesTabState();
}

class _MyServicesTabState extends State<_MyServicesTab> {
  List<WorkerService> _services = [];
  bool _isLoading = true;

  static const _typeIcons = {
    'plumbing':   Icons.plumbing,
    'painting':   Icons.format_paint,
    'tiling':     Icons.grid_on,
    'electrical': Icons.electrical_services,
    'carpentry':  Icons.carpenter,
    'finishing':  Icons.home_repair_service,
  };

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
        _services  = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteWorkerService(id);
      await _load();
      if (mounted) _showSuccess('Service deleted');
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.surface),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorBg),
      );

  Future<void> _showEditDialog(WorkerService service) async {
    final descController  = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.pricePerUnit.toString());
    final unitController  = TextEditingController(text: service.unit);
    bool isAvailable      = service.isAvailable;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Service', style: AppText.h4),
                const SizedBox(height: 20),

                Text('Description',
                    style: AppText.bodySmall.copyWith(
                        fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                const SizedBox(height: 6),
                _DialogInput(
                    controller: descController,
                    hintText: 'Describe the service…',
                    maxLines: 3),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price / unit',
                              style: AppText.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3)),
                          const SizedBox(height: 6),
                          _DialogInput(
                            controller: priceController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unit',
                              style: AppText.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3)),
                          const SizedBox(height: 6),
                          _DialogInput(
                            controller: unitController,
                            hintText: 'e.g. hour',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Availability toggle
                GestureDetector(
                  onTap: () => setDialogState(() => isAvailable = !isAvailable),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.success.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAvailable
                            ? AppColors.success.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAvailable
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          color: isAvailable
                              ? AppColors.success
                              : AppColors.textMuted,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Cancel',
                              style: AppText.body.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          try {
                            await ApiService.updateWorkerService(service.id, {
                              'description': descController.text.trim(),
                              'price_per_unit':
                                  double.tryParse(priceController.text.trim()) ??
                                      service.pricePerUnit,
                              'unit': unitController.text.trim(),
                              'is_available': isAvailable,
                            });
                            await _load();
                            if (mounted) _showSuccess('Service updated');
                          } catch (e) {
                            if (mounted) _showError(e.toString());
                          }
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColors.gradientPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentDeep
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_services.isEmpty) {
      return _buildEmpty(
        icon: Icons.build_outlined,
        title: 'No Services Yet',
        subtitle: 'Add your first service to get started.',
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: _services.length,
        itemBuilder: (_, i) {
          final s    = _services[i];
          final icon = _typeIcons[s.type.toLowerCase()] ?? Icons.build_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentDeep],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.type.toUpperCase(),
                        style: AppText.h4.copyWith(
                            fontSize: 14, letterSpacing: 0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${s.pricePerUnit.toStringAsFixed(0)} / ${s.unit}',
                        style: AppText.price.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.isAvailable
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.surfaceHigh,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  icon: Icon(Icons.more_vert_rounded,
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      size: 20),
                  onSelected: (v) {
                    if (v == 'edit') _showEditDialog(s);
                    if (v == 'delete') _delete(s.id);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Text('Edit',
                            style: AppText.body.copyWith(fontSize: 14)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Text('Delete',
                            style: AppText.body
                                .copyWith(fontSize: 14, color: AppColors.error)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Incoming Requests Tab
// ─────────────────────────────────────────────────────────────────────────────

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
        _requests  = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiService.updateRequestStatus(id, status);
      await _load();
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorBg),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return AppColors.warning;
      case 'accepted':  return AppColors.cyan;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.textMuted;
      default:          return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_requests.isEmpty) {
      return _buildEmpty(
        icon: Icons.inbox_outlined,
        title: 'No Incoming Requests',
        subtitle: 'New requests will appear here.',
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: _requests.length,
        itemBuilder: (_, i) {
          final r           = _requests[i];
          final statusColor = _statusColor(r.status);
          final date =
              '${r.createdAt.day.toString().padLeft(2, '0')}/'
              '${r.createdAt.month.toString().padLeft(2, '0')}/'
              '${r.createdAt.year}';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradientPrimary,
                      ),
                      child: Center(
                        child: Text(
                          '#${r.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.workerService?.type.toUpperCase() ??
                                'Service #${r.workerServiceId}',
                            style: AppText.h4.copyWith(fontSize: 14),
                          ),
                          Text(date, style: AppText.bodySmall.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.40)),
                      ),
                      child: Text(
                        r.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                // Address & note
                if (r.address.isNotEmpty || r.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                  const SizedBox(height: 12),
                  if (r.address.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(r.address, style: AppText.bodySmall),
                        ),
                      ],
                    ),
                  if (r.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 13,
                            color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            r.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                // Action buttons
                if (r.status == 'pending') ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionBtn(
                          label: 'Accept',
                          icon: Icons.check_rounded,
                          onTap: () => _updateStatus(r.id, 'accepted'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionBtn(
                          label: 'Decline',
                          icon: Icons.close_rounded,
                          isDanger: true,
                          onTap: () => _updateStatus(r.id, 'cancelled'),
                        ),
                      ),
                    ],
                  ),
                ] else if (r.status == 'accepted') ...[
                  const SizedBox(height: 14),
                  _ActionBtn(
                    label: 'Mark as Completed',
                    icon: Icons.task_alt_rounded,
                    isGradient: true,
                    onTap: () => _updateStatus(r.id, 'completed'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shared empty state ────────────────────────────────────────────────────────

Widget _buildEmpty({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
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
          child: Icon(icon, color: AppColors.accent, size: 36),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppText.h4),
        const SizedBox(height: 6),
        Text(subtitle, style: AppText.bodySmall),
      ],
    ),
  );
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isGradient;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDanger   = false,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.error : AppColors.accent;

    if (isGradient) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppColors.gradientPrimary,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDeep.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialog input ──────────────────────────────────────────────────────────────

class _DialogInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;

  const _DialogInput({
    required this.controller,
    required this.hintText,
    this.maxLines     = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted.withValues(alpha: 0.40),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentDeep, width: 1.5),
        ),
      ),
    );
  }
}
