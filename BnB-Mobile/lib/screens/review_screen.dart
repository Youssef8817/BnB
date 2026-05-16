import 'package:b_and_b/theme/app_theme.dart';
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
  int    _rating           = 5;
  bool   _isSubmitting     = false;
  final _commentController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();

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
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.errorBg,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                        BackButton2(
                            onTap: () => Navigator.of(context).pop()),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Leave a Review', style: AppText.h3),
                            Text(
                              'Share your experience',
                              style: AppText.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Star hero
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentDeep
                                  .withValues(alpha: 0.45),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 44),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Glass card
                    GlassBox(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Your Rating',
                            style: AppText.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
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
                                color: AppColors.warning,
                              ),
                              onRatingUpdate: (r) =>
                                  setState(() => _rating = r.round()),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _ratingLabels[_rating],
                                key: ValueKey(_rating),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.06)),
                          const SizedBox(height: 24),

                          Text(
                            'Your Comment',
                            style: AppText.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 5,
                            style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary),
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
                                color: AppColors.textMuted
                                    .withValues(alpha: 0.30),
                              ),
                              filled: true,
                              fillColor:
                                  Colors.white.withValues(alpha: 0.04),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white
                                        .withValues(alpha: 0.10)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white
                                        .withValues(alpha: 0.10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.accentDeep,
                                    width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.error, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    GradientButton(
                      label: 'Submit Review',
                      icon: Icons.send_rounded,
                      onTap: _isSubmitting ? null : _submit,
                      isLoading: _isSubmitting,
                      height: 54,
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
