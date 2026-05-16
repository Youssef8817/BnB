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

  static const Color _bg      = Color(0xFF0B1326);
  static const Color _primary = Color(0xFFD0BCFF);

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worker Dashboard',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDAE2FD),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Manage services & requests',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFCBC3D7),
                            ),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33A078FF),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFF3C0091),
                      unselectedLabelColor: const Color(0xFFCBC3D7),
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

                // Tab views
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

  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1A1040)),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: const Color(0xFF93000A)),
      );

  Future<void> _showEditDialog(WorkerService service) async {
    final descController  = TextEditingController(text: service.description);
    final priceController =
        TextEditingController(text: service.pricePerUnit.toString());
    final unitController  = TextEditingController(text: service.unit);
    bool isAvailable      = service.isAvailable;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF111827),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Service',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDAE2FD),
                  ),
                ),
                const SizedBox(height: 20),

                const _DialogLabel('Description'),
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
                          const _DialogLabel('Price / unit'),
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
                          const _DialogLabel('Unit'),
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
                  onTap: () =>
                      setDialogState(() => isAvailable = !isAvailable),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAvailable
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.35)
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
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFCBC3D7),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFCBC3D7),
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
                                color:
                                    Colors.white.withValues(alpha: 0.10)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Color(0xFFCBC3D7),
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
                            await ApiService.updateWorkerService(
                                service.id, {
                              'description': descController.text.trim(),
                              'price_per_unit':
                                  double.tryParse(priceController.text
                                          .trim()) ??
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
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFA078FF),
                                Color(0xFF00A2E6)
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Color(0xFF3C0091),
                              fontWeight: FontWeight.w700,
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
          child: CircularProgressIndicator(color: _primary));
    }
    if (_services.isEmpty) {
      return _buildEmpty(
        icon: Icons.build_outlined,
        title: 'No Services Yet',
        subtitle: 'Add your first service to get started.',
      );
    }
    return RefreshIndicator(
      color: _primary,
      backgroundColor: const Color(0xFF171F33),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: _services.length,
        itemBuilder: (_, i) {
          final s    = _services[i];
          final icon =
              _typeIcons[s.type.toLowerCase()] ?? Icons.build_rounded;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                    ),
                  ),
                  child:
                      Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${s.pricePerUnit.toStringAsFixed(0)} / ${s.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Availability dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.isAvailable
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF958EA0),
                  ),
                ),
                // Menu
                PopupMenuButton<String>(
                  color: const Color(0xFF171F33),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  icon: Icon(Icons.more_vert_rounded,
                      color: _onSurfaceVariant.withValues(alpha: 0.5),
                      size: 20),
                  onSelected: (v) {
                    if (v == 'edit') _showEditDialog(s);
                    if (v == 'delete') _delete(s.id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: Color(0xFFD0BCFF), size: 18),
                        SizedBox(width: 10),
                        Text('Edit',
                            style: TextStyle(color: Color(0xFFDAE2FD))),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFFFB4AB), size: 18),
                        SizedBox(width: 10),
                        Text('Delete',
                            style: TextStyle(color: Color(0xFFFFB4AB))),
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
        SnackBar(
            content: Text(msg), backgroundColor: const Color(0xFF93000A)),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return const Color(0xFFFFB74D);
      case 'accepted':  return const Color(0xFF89CEFF);
      case 'completed': return const Color(0xFF4CAF50);
      case 'cancelled': return const Color(0xFF958EA0);
      default:          return const Color(0xFF958EA0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _primary));
    }
    if (_requests.isEmpty) {
      return _buildEmpty(
        icon: Icons.inbox_outlined,
        title: 'No Incoming Requests',
        subtitle: 'New requests will appear here.',
      );
    }
    return RefreshIndicator(
      color: _primary,
      backgroundColor: const Color(0xFF171F33),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: _requests.length,
        itemBuilder: (_, i) {
          final r          = _requests[i];
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
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFA078FF),
                            Color(0xFF6D3BD7)
                          ],
                        ),
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              color: _onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: 0.15),
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
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 12),
                  if (r.address.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13,
                            color: _onSurfaceVariant
                                .withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            r.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: _onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
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
                            color: _onSurfaceVariant
                                .withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            r.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: _onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
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
                          onTap: () =>
                              _updateStatus(r.id, 'accepted'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionBtn(
                          label: 'Decline',
                          icon: Icons.close_rounded,
                          isDanger: true,
                          onTap: () =>
                              _updateStatus(r.id, 'cancelled'),
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
            color: Colors.white.withValues(alpha: 0.05),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: const Color(0xFFD0BCFF), size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDAE2FD),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFFCBC3D7)),
        ),
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
    this.isDanger    = false,
    this.isGradient  = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger
        ? const Color(0xFFFFB4AB)
        : const Color(0xFFD0BCFF);

    if (isGradient) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33A078FF),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF3C0091)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C0091),
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
          border: Border.all(color: color.withValues(alpha: 0.25)),
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

// ── Dialog helpers ────────────────────────────────────────────────────────────

class _DialogLabel extends StatelessWidget {
  final String text;
  const _DialogLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCBC3D7),
          letterSpacing: 0.3,
        ),
      );
}

class _DialogInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;

  const _DialogInput({
    required this.controller,
    required this.hintText,
    this.maxLines    = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFFDAE2FD)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: const Color(0xFFCBC3D7).withValues(alpha: 0.30),
        ),
        filled: true,
        fillColor: const Color(0xFF0D1528),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.50)),
        ),
      ),
    );
  }
}
