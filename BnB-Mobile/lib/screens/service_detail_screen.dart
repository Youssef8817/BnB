import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_service.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  WorkerService? _service;
  List<Review>   _reviews   = [];
  bool           _isLoading = true;

  final _noteController    = TextEditingController();
  final _addressController = TextEditingController();

  static const Color _bg               = Color(0xFF0B1326);
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

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final service = await ApiService.getWorkerService(widget.serviceId);
      final reviews = await ApiService.getServiceReviews(widget.serviceId);
      setState(() {
        _service   = service;
        _reviews   = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        _reviews.length;
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) {
      _showError('No phone number available');
      return;
    }
    try {
      final ok = await launchUrl(Uri.parse('tel:$phone'),
          mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No dialer found. Number copied: $phone')),
      );
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), backgroundColor: const Color(0xFF93000A)),
      );

  void _showRequestSheet() {
    _noteController.clear();
    _addressController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestSheet(
        noteController:    _noteController,
        addressController: _addressController,
        onSubmit: () async {
          try {
            await ApiService.createServiceRequest(
              widget.serviceId,
              _noteController.text.trim(),
              _addressController.text.trim(),
            );
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request sent successfully!'),
                  backgroundColor: Color(0xFF1A1040),
                ),
              );
            }
          } catch (e) {
            if (mounted) _showError(e.toString());
          }
        },
      ),
    );
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary))
                : _service == null
                    ? _buildNotFound()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: _onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          const Text('Service not found',
              style: TextStyle(fontSize: 16, color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final s    = _service!;
    final icon = _typeIcons[s.type.toLowerCase()] ?? Icons.build_rounded;

    return Column(
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
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _primary, size: 16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  s.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              // Availability dot
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (s.isAvailable
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF958EA0))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (s.isAvailable
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF958EA0))
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  s.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: s.isAvailable
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF958EA0),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            children: [
              // ── Hero card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Service icon circle
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFA078FF),
                                Color(0xFF6D3BD7)
                              ],
                            ),
                          ),
                          child: Icon(icon,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.type.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${s.pricePerUnit.toStringAsFixed(0)} / ${s.unit}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (s.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color:
                              _onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Worker card ───────────────────────────────────────
              if (s.worker != null) ...[
                const SizedBox(height: 16),
                const _SectionLabel('Worker'),
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
                            s.worker!.name.isNotEmpty
                                ? s.worker!.name[0].toUpperCase()
                                : 'W',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.worker!.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _onSurface,
                              ),
                            ),
                            if (s.worker!.phone != null &&
                                s.worker!.phone!.isNotEmpty)
                              Text(
                                s.worker!.phone!,
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
                        onTap: () => _callPhone(s.worker!.phone),
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
                          ),
                          child: const Icon(Icons.phone_rounded,
                              color: Color(0xFF3C0091), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Ratings summary ───────────────────────────────────
              const SizedBox(height: 16),
              const _SectionLabel('Reviews'),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFD700),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RatingBarIndicator(
                          rating: _avgRating,
                          itemBuilder: (_, __) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700)),
                          itemCount: 5,
                          itemSize: 18,
                          unratedColor:
                              Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Review list ───────────────────────────────────────
              const SizedBox(height: 12),
              if (_reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No reviews yet — be the first!',
                    style: TextStyle(
                      fontSize: 14,
                      color: _onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                )
              else
                ..._reviews.map((r) => _ReviewTile(review: r)),

              const SizedBox(height: 24),

              // ── Request button ────────────────────────────────────
              GestureDetector(
                onTap: s.isAvailable ? _showRequestSheet : null,
                child: AnimatedOpacity(
                  opacity: s.isAvailable ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                      ),
                      boxShadow: s.isAvailable
                          ? const [
                              BoxShadow(
                                color: Color(0x44A078FF),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_rounded,
                            color: Color(0xFF3C0091), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Request Service',
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFFDAE2FD),
        letterSpacing: -0.2,
      ),
    );
  }
}

// ── Review tile ───────────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final date =
        '${review.createdAt.day.toString().padLeft(2, '0')}/'
        '${review.createdAt.month.toString().padLeft(2, '0')}/'
        '${review.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                  ),
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C0091),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty
                          ? review.userName
                          : 'Anonymous',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDAE2FD),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFFCBC3D7)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                itemBuilder: (_, __) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFD700)),
                itemCount: 5,
                itemSize: 14,
                unratedColor: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFFCBC3D7).withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Request bottom sheet ──────────────────────────────────────────────────────

class _RequestSheet extends StatefulWidget {
  final TextEditingController noteController;
  final TextEditingController addressController;
  final Future<void> Function() onSubmit;

  const _RequestSheet({
    required this.noteController,
    required this.addressController,
    required this.onSubmit,
  });

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Request Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDAE2FD),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tell us a bit about what you need',
            style: TextStyle(fontSize: 13, color: Color(0xFFCBC3D7)),
          ),
          const SizedBox(height: 24),

          // Note field
          const _SheetLabel('Note'),
          const SizedBox(height: 8),
          _SheetInput(
            controller: widget.noteController,
            hintText: 'Describe what you need…',
            maxLines: 3,
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 16),

          // Address field
          const _SheetLabel('Address'),
          const SizedBox(height: 8),
          _SheetInput(
            controller: widget.addressController,
            hintText: 'Your service address',
            maxLines: 1,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 24),

          // Submit
          GestureDetector(
            onTap: _isSubmitting
                ? null
                : () async {
                    setState(() => _isSubmitting = true);
                    await widget.onSubmit();
                    if (mounted) setState(() => _isSubmitting = false);
                  },
            child: AnimatedOpacity(
              opacity: _isSubmitting ? 0.7 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44A078FF),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF3C0091)),
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C0091),
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCBC3D7),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SheetInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final IconData icon;

  const _SheetInput({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: Color(0xFFDAE2FD)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: const Color(0xFFCBC3D7).withValues(alpha: 0.30),
        ),
        filled: true,
        fillColor: const Color(0xFF0D1528),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: Icon(icon,
            size: 18,
            color: const Color(0xFFCBC3D7).withValues(alpha: 0.35)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.50)),
        ),
      ),
    );
  }
}
