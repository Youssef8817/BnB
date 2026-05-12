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
  int _rating = 5;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ApiService.submitReview(widget.serviceId, _rating, _commentController.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                itemCount: 5,
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (r) => setState(() => _rating = r.round()),
              ),
              const SizedBox(height: 24),
              const Text('Your Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Comment must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
