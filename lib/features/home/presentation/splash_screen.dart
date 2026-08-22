import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'QUICKQUE',
              style: theme.textTheme.displayLarge?.copyWith(
                color: AppColors.chalk,
                letterSpacing: 12,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 12),
            Container(width: 40, height: 1, color: AppColors.brass),
            const SizedBox(height: 12),
            Text(
              'BOUTIQUE APPOINTMENTS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.brass,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
