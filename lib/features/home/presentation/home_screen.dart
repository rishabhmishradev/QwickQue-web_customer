import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/salon_service.dart';
import '../../../services/location_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/salon_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only determine position if not already manual
      if (ref.read(locationProvider).status == LocationStatus.initial) {
        ref.read(locationProvider.notifier).determinePosition();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final salonsAsync = ref.watch(nearbySalonsProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      endDrawer: const _HomeDrawer(),
      appBar: AppBar(
        leadingWidth: 120,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              'QUICKQUE',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 14,
                letterSpacing: 2,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.brass),
                  const SizedBox(width: 4),
                  Text(
                    (locationState.cityName ?? 'SET LOCATION').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.ink),
                ],
              ),
              if (locationState.status == LocationStatus.loading)
                const LinearProgressIndicator(minHeight: 1, backgroundColor: Colors.transparent, color: AppColors.brass),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.ink),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.rouge,
        onRefresh: () async {
          ref.refresh(nearbySalonsProvider);
          ref.refresh(serviceCategoriesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(title: 'CATEGORIES'),
                    const SizedBox(height: 16),
                    
                    categoriesAsync.when(
                      data: (categories) => categories.isEmpty 
                        ? const Text('No categories found', style: TextStyle(fontSize: 12, color: Colors.grey))
                        : SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: categories.length,
                              itemBuilder: (context, index) => _CategoryItem(
                                label: categories[index].toUpperCase(),
                                onTap: () => context.push('/category/${categories[index]}'),
                              ),
                            ),
                          ),
                      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (e, _) => Text('Error: $e', style: const TextStyle(fontSize: 10, color: Colors.red)),
                    ),
                    
                    const SizedBox(height: 48),
                    const _SectionTitle(title: 'CURATED NEARBY'),
                  ],
                ),
              ),
            ),
            
            salonsAsync.when(
              data: (salons) => salons.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: BoutiqueEmptyState(
                        title: 'NO ARTISANS FOUND',
                        message: 'Try expanding your search or selecting a different location.',
                        actionLabel: 'CHANGE LOCATION',
                        onAction: () => _showLocationPicker(context),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _SalonCard(salon: salons[index]),
                          childCount: salons.length,
                        ),
                      ),
                    ),
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.rouge))),
              error: (err, stack) => SliverFillRemaining(
                child: BoutiqueEmptyState(
                  title: 'CONNECTION LOST',
                  message: 'Could not reach server. Please check your internet.',
                  actionLabel: 'RETRY',
                  onAction: () => ref.refresh(nearbySalonsProvider),
                  icon: Icons.wifi_off_rounded,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.chalk,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (context) => const _LocationPickerSheet(),
    );
  }
}

class _HomeDrawer extends ConsumerWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    return Drawer(
      backgroundColor: AppColors.chalk,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.ink),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'QUICKQUE',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.chalk, letterSpacing: 4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name?.toUpperCase() ?? 'GUEST',
                    style: const TextStyle(color: AppColors.brass, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
          _DrawerTile(
            icon: Icons.account_circle_outlined,
            label: 'MY ACCOUNT',
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          _DrawerTile(
            icon: Icons.calendar_today_outlined,
            label: 'MY BOOKINGS',
            onTap: () {
              Navigator.pop(context);
              context.push('/my-bookings');
            },
          ),
          _DrawerTile(
            icon: Icons.local_offer_outlined,
            label: 'OFFERS',
            onTap: () {
              Navigator.pop(context);
              context.push('/offers');
            },
          ),
          const Spacer(),
          const Divider(),
          _DrawerTile(
            icon: Icons.logout_rounded,
            label: 'LOGOUT',
            color: AppColors.rust,
            onTap: () => _showLogoutConfirm(context, ref),
          ),
          const SizedBox(height: 24),
        ],
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.rust)),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color ?? AppColors.ink),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: color ?? AppColors.ink,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.brass)),
        const SizedBox(height: 4),
        Container(width: 32, height: 1.5, color: AppColors.brass),
      ],
    );
  }
}

class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet();

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  String? _selectedState;

  @override
  Widget build(BuildContext context) {
    final locationDataAsync = ref.watch(locationDataProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('ESTABLISH LOCATION', style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 2)),
            const SizedBox(height: 32),
            
            _BoutiqueActionTile(
              icon: Icons.my_location,
              title: 'USE CURRENT POSITION',
              onTap: () async {
                await ref.read(locationProvider.notifier).determinePosition();
                if (mounted) {
                  final loc = ref.read(locationProvider);
                  if (loc.cityName != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('LOCATION SET TO ${loc.cityName!.toUpperCase()}'),
                        backgroundColor: AppColors.sage,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              color: AppColors.rouge,
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR SELECT MANUALLY', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            Expanded(
              child: locationDataAsync.when(
                data: (data) {
                  final states = data['states'] as List;
                  
                  if (_selectedState == null) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: states.length,
                      itemBuilder: (context, index) {
                        final state = states[index]['name'];
                        return _LocationTile(
                          title: state.toString().toUpperCase(),
                          onTap: () => setState(() => _selectedState = state),
                        );
                      },
                    );
                  } else {
                    final stateObj = states.firstWhere((s) => s['name'] == _selectedState);
                    final cities = stateObj['cities'] as List;
                    
                    return Column(
                      children: [
                        _LocationTile(
                          title: '← BACK TO STATES',
                          onTap: () => setState(() => _selectedState = null),
                          isHeader: true,
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: cities.length,
                            itemBuilder: (context, index) {
                              final city = cities[index];
                              return _LocationTile(
                                title: city.toString().toUpperCase(),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await ref.read(locationProvider.notifier).setManualLocation(
                                    city: city,
                                    stateName: _selectedState!,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rouge)),
                error: (err, _) => const Text('Error loading location data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutiqueActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _BoutiqueActionTile({required this.icon, required this.title, required this.onTap, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: onTap,
    );
  }
}

class _LocationTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isHeader;
  const _LocationTile({required this.title, required this.onTap, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: isHeader ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          letterSpacing: 1,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 14,
          color: isHeader ? AppColors.brass : AppColors.ink,
        ),
      ),
      trailing: isHeader ? null : const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _CategoryItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.spa;
    if (label.contains('HAIR')) icon = Icons.content_cut;
    if (label.contains('FACE') || label.contains('FACIAL')) icon = Icons.face_retouching_natural;
    if (label.contains('NAIL')) icon = Icons.clean_hands;
    if (label.contains('MAKEUP')) icon = Icons.brush;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDED9D1)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: AppColors.ink, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1), 
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

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
