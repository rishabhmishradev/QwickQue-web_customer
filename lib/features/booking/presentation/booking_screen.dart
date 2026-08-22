import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import '../../../models/salon_model.dart' as models;
import '../../../services/booking_service.dart';
import '../../../services/salon_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final int salonId;
  final int? initialServiceId;
  final models.SalonService? preSelectedService;

  const BookingScreen({
    super.key, 
    required this.salonId, 
    this.preSelectedService,
    this.initialServiceId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedStaffId;
  int? _selectedServiceId;
  String? _selectedSlot;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.initialServiceId ?? widget.preSelectedService?.id;
  }

  Future<void> _fetchSlots() async {
    if (_selectedServiceId == null) return;

    setState(() => _isLoadingSlots = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final slots = await ref.read(bookingServiceProvider).getAvailability(
        salonId: widget.salonId,
        date: dateStr,
        serviceId: _selectedServiceId!,
        staffId: _selectedStaffId, // Now correctly passing optional staffId
      );
      setState(() => _availableSlots = slots);
    } catch (e) {
      setState(() => _availableSlots = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching slots: $e'), backgroundColor: AppColors.rust),
        );
      }
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salonAsync = ref.watch(salonDetailProvider(widget.salonId));
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(
        title: const Text('SECURE APPOINTMENT'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: salonAsync.when(
        data: (salon) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHeader(step: '01', title: 'CHOOSE SERVICE'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                hint: const Text('SELECT A SERVICE'),
                items: salon.services.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text('${s.name.toUpperCase()} (₹${s.price.toInt()})'),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedServiceId = val;
                    _selectedSlot = null;
                  });
                  _fetchSlots();
                },
              ),

              const SizedBox(height: 48),
              _StepHeader(step: '02', title: 'SELECT AN ARTISAN'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedStaffId,
                hint: const Text('SELECT AN ARTISAN'),
                items: salon.staff.map((st) => DropdownMenuItem(
                  value: st.id,
                  child: Text(st.name.toUpperCase()),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStaffId = val;
                    _selectedSlot = null;
                  });
                  _fetchSlots();
                },
              ),

              const SizedBox(height: 48),
              _StepHeader(step: '03', title: 'CHOOSE DATE'),
              const SizedBox(height: 16),
              Theme(
                data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: AppColors.rouge)),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedSlot = null;
                    });
                    _fetchSlots();
                  },
                ),
              ),

              const SizedBox(height: 48),
              _StepHeader(step: '04', title: 'AVAILABLE TIME SLOTS'),
              const SizedBox(height: 24),
              if (_isLoadingSlots)
                const Center(child: CircularProgressIndicator(color: AppColors.rouge))
              else if (_availableSlots.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    (_selectedStaffId == null || _selectedServiceId == null) 
                      ? 'Please select service and artisan first.'
                      : 'No slots available for this selection.',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                )
              else
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _availableSlots.map((slot) => ChoiceChip(
                    label: Text(slot, style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _selectedSlot == slot ? Colors.white : AppColors.ink,
                    )),
                    selected: _selectedSlot == slot,
                    selectedColor: AppColors.rouge,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() => _selectedSlot = selected ? slot : null);
                    },
                  )).toList(),
                ),
              const SizedBox(height: 64),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rouge)),
        error: (err, _) => BoutiqueEmptyState(
          title: 'ERROR',
          message: 'Failed to load salon details.',
          actionLabel: 'RETRY',
          onAction: () => ref.refresh(salonDetailProvider(widget.salonId)),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.chalk,
          border: Border(top: BorderSide(color: Color(0xFFDED9D1), width: 1)),
        ),
        child: ElevatedButton(
          onPressed: (_selectedSlot == null || _isLoadingSlots) ? null : _handleBooking,
          child: const Text('SECURE APPOINTMENT'),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      await ref.read(bookingServiceProvider).holdSlot(
        salonId: widget.salonId,
        staffId: _selectedStaffId,
        serviceId: _selectedServiceId!,
        date: dateStr,
        startTime: _selectedSlot!,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Booking failed: $e';
        if (e is dio.DioException) {
          if (e.response?.statusCode == 401) {
            errorMsg = 'PLEASE LOG IN TO SECURE APPOINTMENT';
            context.push('/login');
          } else if (e.response?.statusCode == 403) {
            errorMsg = 'PERMISSION DENIED. PLEASE CONTACT SUPPORT.';
          } else if (e.response?.data != null && e.response?.data['error'] != null) {
            errorMsg = e.response?.data['error'].toString().toUpperCase();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.rust),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.chalk,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('APPOINTMENT SECURED', style: Theme.of(context).textTheme.headlineMedium),
        content: const Text('Your request has been sent to the artisan. You will receive a notification once confirmed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('RETURN HOME', style: TextStyle(color: AppColors.rouge, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String step;
  final String title;
  const _StepHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          step,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 14, color: AppColors.brass, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ],
    );
  }
}
