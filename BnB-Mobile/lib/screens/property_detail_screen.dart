import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool  _isLoading  = false;
  User? _owner;
  bool  _isOwner    = false;
  int   _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfOwner();
    _fetchOwner();
  }

  Future<void> _checkIfOwner() async {
    final prefs    = await SharedPreferences.getInstance();
    final userJson = prefs.getString(Constants.userKey);
    if (userJson != null) {
      final map = json.decode(userJson) as Map<String, dynamic>;
      setState(() => _isOwner = (map['id'] == widget.property.ownerId));
    }
  }

  Future<void> _fetchOwner() async {
    try {
      final owner = await ApiService.getUser(widget.property.ownerId);
      setState(() => _owner = owner);
    } catch (_) {}
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updatePropertyStatus(widget.property.id, status);
      if (mounted) _showSuccess('Status updated successfully');
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProperty() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteProperty(widget.property.id);
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccess('Property deleted successfully');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _callOwner() async {
    final phone = _owner?.phone ?? '';
    if (phone.isEmpty) {
      _showError('No phone number available');
      return;
    }
    try {
      final launched = await launchUrl(
        Uri.parse('tel:$phone'),
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No dialer found. Number copied: $phone')),
      );
    }
  }

  void _openFullscreen(int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Hero(
                  tag: 'property_image_${widget.property.id}_$index',
                  child: CachedNetworkImage(
                    imageUrl: widget.property.images[index].fullUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 48,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.surface),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorBg),
      );

  @override
  Widget build(BuildContext context) {
    final p      = widget.property;
    final images = p.images;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const AmbientBackground(),

          CustomScrollView(
            slivers: [
              // Image hero header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: images.isEmpty
                          ? _imgPlaceholder()
                          : PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) =>
                                  setState(() => _imageIndex = i),
                              itemBuilder: (_, i) {
                                final tag = 'property_image_${p.id}_$i';
                                return GestureDetector(
                                  onTap: () => _openFullscreen(i),
                                  child: Hero(
                                    tag: tag,
                                    child: CachedNetworkImage(
                                      imageUrl: images[i].fullUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => _imgPlaceholder(),
                                      errorWidget: (_, __, ___) =>
                                          _imgPlaceholder(),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Bottom gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 140,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xF0060B18)],
                          ),
                        ),
                      ),
                    ),

                    // Back + menu
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BackButton2(
                                onTap: () => Navigator.of(context).pop()),
                            if (_isOwner)
                              _OwnerMenu(
                                onEdit: () async {
                                  final result = await context.push(
                                      '/properties/add',
                                      extra: p);
                                  if (result == true && mounted) {
                                    _showSuccess('Property updated successfully');
                                  }
                                },
                                onDelete: _confirmDelete,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Dot indicators
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: _imageIndex == i ? 20 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: _imageIndex == i
                                    ? AppColors.accent
                                    : Colors.white.withValues(alpha: 0.30),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title + status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(p.title, style: AppText.h2),
                          ),
                          const SizedBox(width: 10),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(p.formattedPrice, style: AppText.price),
                      const SizedBox(height: 6),

                      if (p.city.isNotEmpty || p.location.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 15,
                                color: AppColors.textMuted.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [p.city, p.location]
                                    .where((s) => s.isNotEmpty)
                                    .join(', '),
                                style: AppText.bodySmall,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Stats chips
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.bed_rounded,
                            label: '${p.rooms}',
                            sublabel: 'Rooms',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.square_foot_rounded,
                            label: p.areaMq.toStringAsFixed(0),
                            sublabel: 'm²',
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            icon: Icons.home_work_outlined,
                            label: p.status[0].toUpperCase() +
                                p.status.substring(1),
                            sublabel: 'Status',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text('Description', style: AppText.h4),
                      const SizedBox(height: 10),
                      GlassBox(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          p.description,
                          style: AppText.body,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Owner card
                      Text('Owner', style: AppText.h4),
                      const SizedBox(height: 10),
                      GlassBox(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.gradientPrimary,
                              ),
                              child: Center(
                                child: Text(
                                  _owner != null && _owner!.name.isNotEmpty
                                      ? _owner!.name[0].toUpperCase()
                                      : 'O',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
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
                                    _owner?.name ?? 'Loading…',
                                    style: AppText.h4.copyWith(fontSize: 15),
                                  ),
                                  if (_owner?.email != null)
                                    Text(
                                      _owner!.email!,
                                      style: AppText.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _callOwner,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
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
                                child: const Icon(Icons.phone_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status changer (owner only)
                      if (_isOwner) ...[
                        const SizedBox(height: 24),
                        Text('Change Status', style: AppText.h4),
                        const SizedBox(height: 10),
                        _StatusSelector(
                          current: p.status,
                          onChanged: _updateStatus,
                          isLoading: _isLoading,
                        ),
                      ],

                      const SizedBox(height: 28),

                      GradientButton(
                        label: 'Contact Owner',
                        icon: Icons.phone_rounded,
                        onTap: _callOwner,
                        height: 54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: AppColors.card,
        child: Center(
          child: Icon(Icons.home_work_outlined,
              color: AppColors.accent.withValues(alpha: 0.20), size: 64),
        ),
      );

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Delete Property', style: AppText.h4),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this property? This cannot be undone.',
                style: AppText.body,
              ),
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
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.40)),
                        ),
                        child: const Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.error,
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
      ),
    );
    if (confirmed == true) await _deleteProperty();
  }
}

// ── Owner menu ────────────────────────────────────────────────────────────────

class _OwnerMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _OwnerMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
            SizedBox(width: 10),
            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: AppColors.error)),
          ]),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: const Icon(Icons.more_horiz_rounded,
            color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  const _StatChip(
      {required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassBox(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(height: 6),
            Text(label, style: AppText.h4.copyWith(fontSize: 15)),
            Text(sublabel,
                style: AppText.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Status selector ───────────────────────────────────────────────────────────

class _StatusSelector extends StatefulWidget {
  final String current;
  final void Function(String) onChanged;
  final bool isLoading;
  const _StatusSelector(
      {required this.current,
      required this.onChanged,
      required this.isLoading});

  @override
  State<_StatusSelector> createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<_StatusSelector> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  Color _statusColor(String s) => switch (s) {
        'available' => AppColors.success,
        'pending'   => AppColors.warning,
        _           => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['available', 'pending', 'sold'].map((s) {
        final active = _selected == s;
        final color  = _statusColor(s);
        return Expanded(
          child: GestureDetector(
            onTap: widget.isLoading
                ? null
                : () {
                    setState(() => _selected = s);
                    widget.onChanged(s);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? color.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? color.withValues(alpha: 0.50)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    active
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 16,
                    color: active ? color : AppColors.textMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s[0].toUpperCase() + s.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? color : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
