import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final int serviceId;
  const ReviewScreen({super.key, required this.serviceId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int    _rating            = 5;
  bool   _isSubmitting      = false;
  final _commentController  = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

  static const _ratingLabels = [
    '', 'Poor', 'Fair', 'Good', 'Great', 'Excellent',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ApiService.submitReview(
          widget.serviceId, _rating, _commentController.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted — thank you!'),
            backgroundColor: Color(0xFF1A1040),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF93000A),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
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
                              'Leave a Review',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Share your experience with the service',
                              style: TextStyle(
                                fontSize: 13,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Star icon hero
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x55A078FF),
                              blurRadius: 32,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 44),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Glass card ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Rating section
                          const Text(
                            'Your Rating',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _onSurfaceVariant,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: RatingBar.builder(
                              initialRating: _rating.toDouble(),
                              minRating: 1,
                              itemCount: 5,
                              itemSize: 44,
                              glow: false,
                              itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              itemBuilder: (_, i) => Icon(
                                i < _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFFD700),
                              ),
                              onRatingUpdate: (r) =>
                                  setState(() => _rating = r.round()),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating label
                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _ratingLabels[_rating],
                                key: ValueKey(_rating),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFD700),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          const SizedBox(height: 24),

                          // Comment section
                          const Text(
                            'Your Comment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _onSurfaceVariant,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 5,
                            style: const TextStyle(
                                fontSize: 15, color: Color(0xFFDAE2FD)),
                            validator: (v) {
                              if (v == null || v.trim().length < 10) {
                                return 'Please write at least 10 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Share your experience…',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: _onSurfaceVariant
                                    .withValues(alpha: 0.30),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0D1528),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.10)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: const Color(0xFFD0BCFF)
                                        .withValues(alpha: 0.50)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFFFB4AB)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFFFB4AB)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit button
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submit,
                      child: AnimatedOpacity(
                        opacity: _isSubmitting ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFA078FF),
                                Color(0xFF00A2E6),
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
                                  'Submit Review',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
