import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/salon_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/salon_model.dart';

class SalonDetailScreen extends ConsumerStatefulWidget {
  final int salonId;
  const SalonDetailScreen({super.key, required this.salonId});

  @override
  ConsumerState<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends ConsumerState<SalonDetailScreen> {
  int? _selectedServiceId;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(salonDetailProvider(widget.salonId));
    final theme = Theme.of(context);

    return detailAsync.when(
      data: (salon) {
        final selectedService = _selectedServiceId == null 
          ? null 
          : salon.services.firstWhere((s) => s.id == _selectedServiceId);

        return Scaffold(
          backgroundColor: AppColors.chalk,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.chalk,
                flexibleSpace: FlexibleSpaceBar(
                  background: salon.images.isNotEmpty
                      ? Image.network(salon.images.first, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              salon.name.toUpperCase(),
                              style: theme.textTheme.displayMedium?.copyWith(
                                letterSpacing: 2,
                                fontSize: 28,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.brass, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                salon.rating.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        salon.address?.toUpperCase() ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.ink.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'THE EXPERIENCE'),
                      const SizedBox(height: 12),
                      Text(
                        salon.description ?? 'A curated grooming experience awaits.',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      const _SectionHeader(title: 'MENU OF SERVICES'),
                      const SizedBox(height: 16),
                      ...salon.services.map((s) => _ServiceItem(
                        service: s,
                        isSelected: _selectedServiceId == s.id,
                        onTap: () => setState(() => _selectedServiceId = s.id),
                      )),
                      const SizedBox(height: 40),
                      const _SectionHeader(title: 'MEET THE ARTISANS'),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: salon.staff.length,
                          itemBuilder: (context, index) {
                            final member = salon.staff[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.brass, width: 1),
                                      image: member.profileImage != null
                                          ? DecorationImage(image: NetworkImage(member.profileImage!), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: member.profileImage == null
                                        ? const Icon(Icons.person, color: AppColors.brass)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    member.name.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.chalk,
              border: Border(top: BorderSide(color: Color(0xFFDED9D1), width: 1)),
            ),
            child: ElevatedButton(
              onPressed: _selectedServiceId == null 
                ? null 
                : () => context.push('/book/${widget.salonId}?serviceId=$_selectedServiceId'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rouge,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                _selectedServiceId == null 
                  ? 'SELECT A SERVICE' 
                  : 'BOOK FOR ₹${selectedService?.price.toInt()}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _selectedServiceId == null ? Colors.grey[600] : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.brass,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 40, height: 1, color: AppColors.brass),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.service, 
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.ink : const Color(0xFFDED9D1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name.toUpperCase(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.durationMinutes} MINUTES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9, 
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${service.price.toInt()}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.brass : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

