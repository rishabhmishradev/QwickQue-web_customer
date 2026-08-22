import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/booking_service.dart';
import '../../../models/booking_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/ticket_stub.dart';
import 'package:intl/intl.dart';

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) {
  return ref.watch(bookingServiceProvider).getMyBookings();
});

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(
        title: const Text('MY BOOKINGS'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.rouge,
          labelColor: AppColors.rouge,
          unselectedLabelColor: Colors.grey,
          labelStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'CURRENT'),
            Tab(text: 'PAST'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) => TabBarView(
          controller: _tabController,
          children: [
            _BookingList(
              bookings: bookings.where((b) => b.status == 'CONFIRMED' || b.status == 'PENDING_CONFIRMATION').toList(),
              emptyTitle: 'NO ACTIVE BOOKINGS',
              emptyMessage: 'You don\'t have any pending or confirmed appointments at the moment.',
            ),
            _BookingList(
              bookings: bookings.where((b) => ['COMPLETED', 'CANCELLED', 'REJECTED', 'EXPIRED'].contains(b.status)).toList(),
              emptyTitle: 'NO PAST BOOKINGS',
              emptyMessage: 'Your appointment history is empty.',
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rouge)),
        error: (err, stack) => BoutiqueEmptyState(
          title: 'FETCH FAILED',
          message: 'Unable to retrieve your bookings.',
          actionLabel: 'RETRY',
          onAction: () => ref.refresh(myBookingsProvider),
          icon: Icons.error_outline_rounded,
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyTitle;
  final String emptyMessage;

  const _BookingList({
    required this.bookings,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: BoutiqueEmptyState(
          title: emptyTitle,
          message: emptyMessage,
          actionLabel: 'BOOK NOW',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: TicketStub(
            status: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: booking.status),
                Text(
                  'ID: #${booking.id}',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.serviceName.toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16),
                      ),
                    ),
                    Text(
                      '₹${booking.totalPrice.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rouge),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.brass),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(booking.bookingDate).toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 12, color: AppColors.brass),
                    const SizedBox(width: 8),
                    Text(
                      booking.startTime.substring(0, 5),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
