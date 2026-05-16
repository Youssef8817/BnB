import 'package:b_and_b/theme/app_theme.dart';
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
        SnackBar(content: Text(msg), backgroundColor: AppColors.errorBg),
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
                  backgroundColor: AppColors.surface,
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
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent))
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
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('Service not found', style: AppText.bodySmall),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final s    = _service!;
    final icon = _typeIcons[s.type.toLowerCase()] ?? Icons.build_rounded;
    final availColor =
        s.isAvailable ? AppColors.success : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              BackButton2(onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 16),
              Expanded(
                child: Text(s.type.toUpperCase(), style: AppText.h3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: availColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: availColor.withValues(alpha: 0.40)),
                ),
                child: Text(
                  s.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: availColor,
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
              // Hero card
              GlassBox(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent,
                                AppColors.accentDeep,
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
                              Text(s.type.toUpperCase(),
                                  style: AppText.h4.copyWith(
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Text(
                                '\$${s.pricePerUnit.toStringAsFixed(0)} / ${s.unit}',
                                style: AppText.price,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (s.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.06)),
                      const SizedBox(height: 16),
                      Text(s.description, style: AppText.body),
                    ],
                  ],
                ),
              ),

              // Worker card
              if (s.worker != null) ...[
                const SizedBox(height: 16),
                Text('Worker', style: AppText.h4),
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
                            s.worker!.name.isNotEmpty
                                ? s.worker!.name[0].toUpperCase()
                                : 'W',
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
                            Text(s.worker!.name,
                                style: AppText.h4.copyWith(fontSize: 15)),
                            if (s.worker!.phone != null &&
                                s.worker!.phone!.isNotEmpty)
                              Text(s.worker!.phone!,
                                  style: AppText.bodySmall),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _callPhone(s.worker!.phone),
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
              ],

              // Reviews summary
              const SizedBox(height: 16),
              Text('Reviews', style: AppText.h4),
              const SizedBox(height: 10),
              GlassBox(
                padding: const EdgeInsets.all(16),
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
                            color: AppColors.warning,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RatingBarIndicator(
                          rating: _avgRating,
                          itemBuilder: (_, __) => const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning),
                          itemCount: 5,
                          itemSize: 18,
                          unratedColor:
                              Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                          style: AppText.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              if (_reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No reviews yet — be the first!',
                    style: AppText.bodySmall,
                  ),
                )
              else
                ..._reviews.map((r) => _ReviewTile(review: r)),

              const SizedBox(height: 24),

              GradientButton(
                label: 'Request Service',
                icon: Icons.build_rounded,
                onTap: s.isAvailable ? _showRequestSheet : null,
                isLoading: false,
                height: 54,
              ),
            ],
          ),
        ),
      ],
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientPrimary,
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                      style: AppText.body.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(date, style: AppText.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                itemBuilder: (_, __) => const Icon(
                    Icons.star_rounded, color: AppColors.warning),
                itemCount: 5,
                itemSize: 14,
                unratedColor: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: AppText.bodySmall),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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

          Text('Request Service', style: AppText.h3),
          const SizedBox(height: 4),
          Text('Tell us a bit about what you need',
              style: AppText.bodySmall),
          const SizedBox(height: 24),

          PremiumInputField(
            controller: widget.noteController,
            hintText: 'Describe what you need…',
            label: 'Note',
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          PremiumInputField(
            controller: widget.addressController,
            hintText: 'Your service address',
            label: 'Address',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 24),

          GradientButton(
            label: 'Submit Request',
            icon: Icons.send_rounded,
            isLoading: _isSubmitting,
            height: 54,
            onTap: _isSubmitting
                ? null
                : () async {
                    setState(() => _isSubmitting = true);
                    await widget.onSubmit();
                    if (mounted) setState(() => _isSubmitting = false);
                  },
          ),
        ],
      ),
    );
  }
}
