import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final WorkerService service;
  const ServiceCard({super.key, required this.service});

  static const _typeIcons = {
    'plumbing':   Icons.plumbing,
    'painting':   Icons.format_paint,
    'tiling':     Icons.grid_on,
    'electrical': Icons.electrical_services,
    'carpentry':  Icons.carpenter,
    'finishing':  Icons.home_repair_service,
  };

  void _showRequestSheet(BuildContext context) {
    final noteController    = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestSheet(
        serviceType:       service.type,
        noteController:    noteController,
        addressController: addressController,
        onSubmit: (note, address) async {
          await ApiService.createServiceRequest(service.id, note, address);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon       = _typeIcons[service.type.toLowerCase()] ?? Icons.build_rounded;
    final availColor = service.isAvailable ? AppColors.success : AppColors.textMuted;

    return GestureDetector(
      onTap: () => _showRequestSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accentDeep],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.type.toUpperCase(),
                          style: AppText.h4.copyWith(fontSize: 15, letterSpacing: 0.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: availColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: availColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          service.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: availColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (service.worker?.name.isNotEmpty == true) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12, color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          service.worker!.name,
                          style: AppText.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],

                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted.withValues(alpha: 0.65),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        '\$${service.pricePerUnit.toStringAsFixed(0)}',
                        style: AppText.price.copyWith(fontSize: 20),
                      ),
                      Text(
                        ' / ${service.unit}',
                        style: AppText.bodySmall.copyWith(fontSize: 13),
                      ),
                      const Spacer(),
                      if (service.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: AppColors.gradientPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentDeep.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Request',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Request bottom sheet ──────────────────────────────────────────────────────

class _RequestSheet extends StatefulWidget {
  final String serviceType;
  final TextEditingController noteController;
  final TextEditingController addressController;
  final Future<void> Function(String note, String address) onSubmit;

  const _RequestSheet({
    required this.serviceType,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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

          Text(
            'Request ${widget.serviceType[0].toUpperCase()}${widget.serviceType.substring(1)}',
            style: AppText.h3,
          ),
          const SizedBox(height: 4),
          Text('Tell us what you need', style: AppText.bodySmall),
          const SizedBox(height: 24),

          PremiumInputField(
            controller: widget.noteController,
            hintText: 'Describe what you need…',
            label: 'Note',
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 14),

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
            onTap: () async {
              if (widget.addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an address'),
                    backgroundColor: AppColors.errorBg,
                  ),
                );
                return;
              }
              setState(() => _isSubmitting = true);
              final messenger = ScaffoldMessenger.of(context);
              final nav       = Navigator.of(context);
              try {
                await widget.onSubmit(
                  widget.noteController.text.trim(),
                  widget.addressController.text.trim(),
                );
                if (!mounted) return;
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Request sent successfully!'),
                    backgroundColor: AppColors.surface,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isSubmitting = false);
                messenger.showSnackBar(SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: AppColors.errorBg,
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
