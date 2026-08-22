import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/salon_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../models/salon_model.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salonsAsync = ref.watch(salonsByCategoryProvider(category));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(
        title: Text(category.toUpperCase()),
      ),
      body: salonsAsync.when(
        data: (salons) => salons.isEmpty
            ? Center(
                child: BoutiqueEmptyState(
                  title: 'NO ARTISANS FOUND',
                  message: 'No salons currently offer $category services in your area.',
                  actionLabel: 'GO BACK',
                  onAction: () => context.pop(),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: salons.length,
                itemBuilder: (context, index) => _SalonCard(salon: salons[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rouge)),
        error: (err, _) => Center(
          child: BoutiqueEmptyState(
            title: 'CONNECTION ERROR',
            message: 'Unable to fetch $category services.',
            actionLabel: 'RETRY',
            onAction: () => ref.refresh(salonsByCategoryProvider(category)),
            icon: Icons.wifi_off_rounded,
          ),
        ),
      ),
    );
  }
}

// Reuse the _SalonCard logic from HomeScreen (ideally should be a shared widget)
class _SalonCard extends StatelessWidget {
  final SalonSummary salon;
  const _SalonCard({required this.salon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/salons/${salon.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDED9D1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: salon.mainImage != null
                        ? Image.network(salon.mainImage!, fit: BoxFit.cover)
                        : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.white, size: 40)),
                  ),
                  if (salon.isOpen)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.sage, borderRadius: BorderRadius.circular(2)),
                        child: const Text('OPEN', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(salon.name.toUpperCase(), style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18, letterSpacing: 1)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.brass, size: 16),
                          const SizedBox(width: 4),
                          Text(salon.rating.toString(), style: theme.textTheme.labelSmall?.copyWith(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(salon.address?.toUpperCase() ?? '', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600], fontSize: 9)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${salon.distance.toStringAsFixed(1)} KM AWAY',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const Spacer(),
                      if (salon.startingPrice != null)
                        Text(
                          'FROM ₹${salon.startingPrice!.toInt()}',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.rouge, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
