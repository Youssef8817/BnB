import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
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

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.surface),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorBg),
      );

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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Properties', style: AppText.h3),
                            Text(
                              '${_properties.length} listing${_properties.length == 1 ? '' : 's'}',
                              style: AppText.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await context.push('/properties/add');
                          if (result == true) await _load();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.gradientPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentDeep
                                    .withValues(alpha: 0.40),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : _properties.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: AppColors.accent,
                              backgroundColor: AppColors.surface,
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 32),
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
              color: AppColors.accentSoft,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.home_work_outlined,
                color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No Properties Yet', style: AppText.h4),
          const SizedBox(height: 6),
          Text('Add your first listing to get started.',
              style: AppText.bodySmall),
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
    final newStatus = await showDialog<String>(
      context: context,
      builder: (_) => _StatusDialog(current: p.status),
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
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 8),
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
                      width: double.infinity,
                      placeholder: (_, __) => _imgPlaceholder(),
                      errorWidget: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(property.title,
                          style: AppText.h4.copyWith(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: property.status),
                  ],
                ),
                const SizedBox(height: 6),
                if (property.city.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textMuted.withValues(alpha: 0.6)),
                      const SizedBox(width: 3),
                      Text(property.city, style: AppText.bodySmall),
                    ],
                  ),
                const SizedBox(height: 10),
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
                    Text(property.formattedPrice,
                        style: AppText.price.copyWith(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 14),
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

  Widget _imgPlaceholder() => Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientCard),
        child: Center(
          child: Icon(Icons.home_work_outlined,
              color: AppColors.accent.withValues(alpha: 0.20), size: 48),
        ),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13,
            color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(label, style: AppText.bodySmall.copyWith(fontSize: 12)),
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
    final color = isDanger ? AppColors.error : AppColors.accent;
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
      backgroundColor: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppText.h4),
            const SizedBox(height: 12),
            Text(body, style: AppText.body),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: GlassBox(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text('Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: confirmDanger
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: confirmDanger
                              ? AppColors.error.withValues(alpha: 0.40)
                              : AppColors.accent.withValues(alpha: 0.40),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: confirmDanger
                              ? AppColors.error
                              : AppColors.accent,
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
      backgroundColor: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change Status', style: AppText.h4),
            const SizedBox(height: 16),
            for (final s in ['available', 'pending', 'sold'])
              GestureDetector(
                onTap: () => setState(() => _selected = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selected == s
                        ? AppColors.accentSoft
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selected == s
                          ? AppColors.accent.withValues(alpha: 0.40)
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
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _selected == s
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
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
                    child: GlassBox(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text('Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(_selected),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppColors.gradientPrimary,
                      ),
                      child: const Text(
                        'Confirm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
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
