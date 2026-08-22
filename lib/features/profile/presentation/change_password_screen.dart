import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(title: const Text('UPDATE SECURITY')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _BoutiqueTextField(label: 'CURRENT ACCESS KEY', controller: _currentController, obscureText: true),
            const SizedBox(height: 24),
            _BoutiqueTextField(label: 'NEW ACCESS KEY', controller: _newController, obscureText: true),
            const SizedBox(height: 24),
            _BoutiqueTextField(label: 'CONFIRM NEW ACCESS KEY', controller: _confirmController, obscureText: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChange,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('UPDATE SECURITY KEY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChange() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NEW_PASSWORDS_DO_NOT_MATCH'), backgroundColor: AppColors.rust),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).changePassword(
        _currentController.text,
        _newController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SECURITY_KEY_UPDATED'), backgroundColor: AppColors.sage),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CURRENT_KEY_INVALID'), backgroundColor: AppColors.rust),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _BoutiqueTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const _BoutiqueTextField({required this.label, required this.controller, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        ),
      ],
    );
  }
}
