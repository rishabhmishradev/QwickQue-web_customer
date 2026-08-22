import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ticket_stub.dart';

class BookingSummaryScreen extends ConsumerWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(title: const Text('APPOINTMENT SUMMARY')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TicketStub(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RESERVATION DETAILS', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.brass, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _SummaryRow(label: 'SERVICE', value: bookingData['serviceName']),
                  _SummaryRow(label: 'ARTISAN', value: bookingData['staffName']),
                  _SummaryRow(label: 'DATE', value: bookingData['date']),
                  _SummaryRow(label: 'TIME', value: bookingData['time']),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFFDED9D1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL DUE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('₹${bookingData['price']}', style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.rouge)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'A hold has been placed on this slot for 5 minutes. Please confirm to finalize your appointment.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('FINALIZE APPOINTMENT'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL & RETURN', style: theme.textTheme.labelSmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
          Text(value.toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
