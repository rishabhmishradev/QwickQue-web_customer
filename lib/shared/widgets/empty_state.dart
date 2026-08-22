import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BoutiqueEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  const BoutiqueEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.calendar_today_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.brass.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: AppColors.ink.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              width: 40,
              height: 1,
              color: AppColors.brass,
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.rouge,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
