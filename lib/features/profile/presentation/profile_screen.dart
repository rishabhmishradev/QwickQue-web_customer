import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(title: const Text('MY ACCOUNT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User basic Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(4),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 64, color: AppColors.brass),
                  const SizedBox(height: 16),
                  Text(
                    user?.name?.toUpperCase() ?? 'NAME NOT SET',
                    style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.chalk),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                  if (user?.phone != null)
                    Text(
                      user!.phone!,
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _AccountItem(
              icon: Icons.edit_outlined,
              label: 'EDIT PROFILE',
              onTap: () => context.push('/edit-profile'),
            ),
            _AccountItem(
              icon: Icons.lock_outline_rounded,
              label: 'CHANGE PASSWORD',
              onTap: () => context.push('/change-password'),
            ),
            
            const SizedBox(height: 48),
            Container(width: 40, height: 1, color: AppColors.brass),
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showLogoutConfirm(context, ref),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.rust)),
                child: const Text('LOGOUT', style: TextStyle(color: AppColors.rust, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.chalk,
        title: const Text('LOGOUT'),
        content: const Text('Are you sure you want to end your session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccountItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDED9D1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.ink, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
      ),
    );
  }
}
