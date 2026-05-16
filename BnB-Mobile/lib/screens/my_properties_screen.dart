import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  _MyPropertiesScreenState createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _repo = PropertyRepository();
  List<Property> _properties = [];
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
      final props = await _repo.getMine();
      setState(() {
        _properties = props;
        _isLoading  = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _delete(int id) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteProperty(id);
      await _load();
      if (mounted) _showSuccess('Property deleted successfully');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updatePropertyStatus(id, status);
      await _load();
      if (mounted) _showSuccess('Status updated successfully');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A1040),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF93000A),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Purple glow — top-right ───────────────────────────────
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
          // ── Blue glow — bottom-left ───────────────────────────────
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

          // ── Content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: _primary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Properties',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${_properties.length} listing${_properties.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: _onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Add button
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await context.push('/properties/add');
                          if (result == true) await _load();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x44A078FF),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Color(0xFF3C0091), size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primary))
                      : _properties.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: _primary,
                              backgroundColor: const Color(0xFF171F33),
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                                itemCount: _properties.length,
                                itemBuilder: (_, i) => _PropertyCard(
                                  property: _properties[i],
                                  onEdit: () async {
                                    final result = await context.push(
                                      '/properties/add',
                                      extra: _properties[i],
                                    );
                                    if (result == true) await _load();
                                  },
                                  onDelete: () =>
                                      _confirmDelete(_properties[i]),
                                  onChangeStatus: () =>
                                      _showStatusDialog(_properties[i]),
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.home_work_outlined,
                color: _primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Properties Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your first listing to get started.',
            style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Property p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _StyledDialog(
        title: 'Delete Property',
        body: 'Are you sure you want to delete "${p.title}"? This cannot be undone.',
        confirmLabel: 'Delete',
        confirmDanger: true,
      ),
    );
    if (confirmed == true) await _delete(p.id);
  }

  Future<void> _showStatusDialog(Property p) async {
    String selected = p.status;
    final newStatus = await showDialog<String>(
      context: context,
      builder: (_) => _StatusDialog(current: selected),
    );
    if (newStatus != null && newStatus != p.status) {
      await _updateStatus(p.id, newStatus);
    }
  }
}

// ── Property card ─────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChangeStatus;

  const _PropertyCard({
    required this.property,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeStatus,
  });

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFB74D);
      case 'sold':
        return const Color(0xFF958EA0);
      default:
        return const Color(0xFF958EA0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = property.images.isNotEmpty;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 160,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: property.images.first.fullUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(),
                      errorWidget: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDAE2FD),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(property.status)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: _statusColor(property.status)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        property.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(property.status),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (property.city.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13,
                          color: const Color(0xFFCBC3D7).withValues(alpha: 0.6)),
                      const SizedBox(width: 3),
                      Text(
                        property.city,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFFCBC3D7).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                // Stats row
                Row(
                  children: [
                    _Stat(
                        icon: Icons.bed_rounded,
                        label: '${property.rooms} rooms'),
                    const SizedBox(width: 14),
                    _Stat(
                        icon: Icons.square_foot_rounded,
                        label:
                            '${property.areaMq.toStringAsFixed(0)}m²'),
                    const Spacer(),
                    Text(
                      property.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD0BCFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Status',
                        onTap: onChangeStatus,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      onTap: onDelete,
                      isDanger: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF0B1326)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.home_work_outlined,
            color: Color(0x33D0BCFF), size: 48),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: const Color(0xFFCBC3D7).withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFFCBC3D7).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFFFB4AB) : const Color(0xFFD0BCFF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

// ── Styled dialog ─────────────────────────────────────────────────────────────

class _StyledDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final bool confirmDanger;

  const _StyledDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.confirmDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDAE2FD),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFFCBC3D7), height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
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
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: confirmDanger
                            ? const Color(0xFF93000A).withValues(alpha: 0.25)
                            : const Color(0xFFA078FF).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: confirmDanger
                              ? const Color(0xFFFFB4AB).withValues(alpha: 0.4)
                              : const Color(0xFFD0BCFF).withValues(alpha: 0.4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          color: confirmDanger
                              ? const Color(0xFFFFB4AB)
                              : const Color(0xFFD0BCFF),
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// ── Status dialog ─────────────────────────────────────────────────────────────

class _StatusDialog extends StatefulWidget {
  final String current;
  const _StatusDialog({required this.current});

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Change Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDAE2FD),
              ),
            ),
            const SizedBox(height: 16),
            for (final s in ['available', 'pending', 'sold'])
              GestureDetector(
                onTap: () => setState(() => _selected = s),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selected == s
                        ? const Color(0xFFD0BCFF).withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selected == s
                          ? const Color(0xFFD0BCFF).withValues(alpha: 0.40)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selected == s
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: 18,
                        color: _selected == s
                            ? const Color(0xFFD0BCFF)
                            : const Color(0xFFCBC3D7),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _selected == s
                              ? const Color(0xFFDAE2FD)
                              : const Color(0xFFCBC3D7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
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
                    onTap: () => Navigator.of(context).pop(_selected),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Confirm',
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
    );
  }
}
