import 'package:flutter/material.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/services/api_service.dart';

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
    final icon = _typeIcons[service.type.toLowerCase()] ?? Icons.build_rounded;
    final availColor = service.isAvailable
        ? const Color(0xFF4CAF50)
        : const Color(0xFF958EA0);

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
              color: Colors.black.withValues(alpha: 0.18),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + availability badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDAE2FD),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: availColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: availColor.withValues(alpha: 0.35)),
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

                  // Worker name
                  if (service.worker?.name.isNotEmpty == true) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12,
                            color: const Color(0xFFCBC3D7)
                                .withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          service.worker!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFCBC3D7)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Description
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: const Color(0xFFCBC3D7)
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Bottom row: price + request button
                  Row(
                    children: [
                      Text(
                        '\$${service.pricePerUnit.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD0BCFF),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        ' / ${service.unit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFFCBC3D7)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      if (service.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
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
                                color: Color(0x33A078FF),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Request',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C0091),
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
          // Handle
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDAE2FD),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tell us what you need',
            style: TextStyle(fontSize: 13, color: Color(0xFFCBC3D7)),
          ),
          const SizedBox(height: 24),

          // Note
          const _SheetLabel('Note'),
          const SizedBox(height: 8),
          _SheetInput(
            controller: widget.noteController,
            hintText: 'Describe what you need…',
            maxLines: 3,
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 14),

          // Address
          const _SheetLabel('Address'),
          const SizedBox(height: 8),
          _SheetInput(
            controller: widget.addressController,
            hintText: 'Your service address',
            maxLines: 1,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 24),

          // Submit button
          GestureDetector(
            onTap: _isSubmitting
                ? null
                : () async {
                    if (widget.addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an address'),
                          backgroundColor: Color(0xFF93000A),
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
                          backgroundColor: Color(0xFF1A1040),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isSubmitting = false);
                      messenger.showSnackBar(SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFF93000A),
                      ));
                    }
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
