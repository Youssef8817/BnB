import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/services/api_service.dart';
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

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1A1040)),
      );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: const Color(0xFF93000A)),
      );

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'available': return const Color(0xFF4CAF50);
      case 'pending':   return const Color(0xFFFFB74D);
      case 'sold':      return const Color(0xFF958EA0);
      default:          return const Color(0xFF958EA0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p      = widget.property;
    final images = p.images;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Background glows ────────────────────────────────────
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

          // ── Main scroll ─────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Image hero header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Image PageView
                    SizedBox(
                      height: 320,
                      child: images.isEmpty
                          ? _imgPlaceholder()
                          : PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) =>
                                  setState(() => _imageIndex = i),
                              itemBuilder: (_, i) {
                                final tag =
                                    'property_image_${p.id}_$i';
                                return GestureDetector(
                                  onTap: () => _openFullscreen(i),
                                  child: Hero(
                                    tag: tag,
                                    child: CachedNetworkImage(
                                      imageUrl: images[i].fullUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          _imgPlaceholder(),
                                      errorWidget: (_, __, ___) =>
                                          _imgPlaceholder(),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Bottom gradient over image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xE60B1326)],
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.black.withValues(alpha: 0.40),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.15)),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16),
                              ),
                            ),
                            if (_isOwner)
                              _OwnerMenu(
                                onEdit: () async {
                                  final result = await context.push(
                                      '/properties/add',
                                      extra: p);
                                  if (result == true && mounted) {
                                    _showSuccess(
                                        'Property updated successfully');
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: _imageIndex == i
                                    ? _primary
                                    : Colors.white
                                        .withValues(alpha: 0.30),
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
                            child: Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _onSurface,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _statusColor(p.status)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: _statusColor(p.status)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              p.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(p.status),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        p.formattedPrice,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location
                      if (p.city.isNotEmpty || p.location.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 15,
                                color: _onSurfaceVariant
                                    .withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [p.city, p.location]
                                    .where((s) => s.isNotEmpty)
                                    .join(', '),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
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
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          p.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: _onSurfaceVariant.withValues(alpha: 0.85),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Owner card
                      const Text(
                        'Owner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFA078FF),
                                    Color(0xFF00A2E6)
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _owner != null && _owner!.name.isNotEmpty
                                      ? _owner!.name[0].toUpperCase()
                                      : 'O',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3C0091),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _owner?.name ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                  if (_owner?.email != null)
                                    Text(
                                      _owner!.email!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _callOwner,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFA078FF),
                                      Color(0xFF00A2E6)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x33A078FF),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.phone_rounded,
                                    color: Color(0xFF3C0091),
                                    size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Owner status changer
                      if (_isOwner) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Change Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StatusSelector(
                          current: p.status,
                          onChanged: _updateStatus,
                          isLoading: _isLoading,
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Call CTA button
                      GestureDetector(
                        onTap: _callOwner,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFA078FF),
                                Color(0xFF00A2E6)
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x44A078FF),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_rounded,
                                  color: Color(0xFF3C0091), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Contact Owner',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3C0091),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
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
        color: const Color(0xFF111827),
        child: const Center(
          child: Icon(Icons.home_work_outlined,
              color: Color(0x33D0BCFF), size: 64),
        ),
      );

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
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
                'Delete Property',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDAE2FD),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to delete this property? This cannot be undone.',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCBC3D7),
                    height: 1.5),
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
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF93000A)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFFB4AB)
                                  .withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFFFB4AB),
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

// ── Owner menu (edit / delete) ────────────────────────────────────────────────

class _OwnerMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _OwnerMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF171F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, color: Color(0xFFD0BCFF), size: 18),
            SizedBox(width: 10),
            Text('Edit', style: TextStyle(color: Color(0xFFDAE2FD))),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded,
                color: Color(0xFFFFB4AB), size: 18),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: Color(0xFFFFB4AB))),
          ]),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.40),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFD0BCFF)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDAE2FD),
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFCBC3D7).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status selector (owner only) ──────────────────────────────────────────────

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

  Color _statusColor(String s) {
    switch (s) {
      case 'available': return const Color(0xFF4CAF50);
      case 'pending':   return const Color(0xFFFFB74D);
      case 'sold':      return const Color(0xFF958EA0);
      default:          return const Color(0xFF958EA0);
    }
  }

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
                    color: active ? color : const Color(0xFFCBC3D7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s[0].toUpperCase() + s.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? color : const Color(0xFFCBC3D7),
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
