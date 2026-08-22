import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/review_service.dart';
import '../../../core/theme/app_theme.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;
  const ReviewScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(
        title: const Text('RATE THE EXPERIENCE'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'HOW WAS YOUR SERVICE?',
              style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your feedback helps us curate the best artisans for QuickQue.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.brass,
                    size: 48,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 48),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR COMMENTS (OPTIONAL)', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  style: theme.textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience with the artisan...',
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('SUBMIT FEEDBACK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(reviewServiceProvider).postReview(
        widget.bookingId,
        _rating,
        _commentController.text,
      );
      if (mounted) {
        _showThanks();
      }
    } catch (e) {
      _showThanks(); // For demo mode
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showThanks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('THANK YOU FOR YOUR FEEDBACK'),
        backgroundColor: AppColors.ink,
      ),
    );
    context.go('/home');
  }
}
