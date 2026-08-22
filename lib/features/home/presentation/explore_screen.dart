import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/salon_service.dart';
import '../../../services/location_service.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final salonsAsync = ref.watch(allSalonsProvider);
    final locationState = ref.watch(locationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.chalk,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/logo.png', 
            height: 120, 
            width: 120, 
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
      bottomNavigationBar: const BoutiqueBottomNav(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search salons or services',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFB8935A)),
                const SizedBox(width: 4),
                Text(
                  'EXPLORE ALL · ${(locationState.cityName ?? 'CURRENT LOCATION').toUpperCase()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7A4B4B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == 'All',
                  onTap: () => setState(() => _selectedCategory = 'All'),
                ),
                _CategoryChip(
                  label: 'Haircut',
                  isSelected: _selectedCategory == 'Haircut',
                  onTap: () => setState(() => _selectedCategory = 'Haircut'),
                ),
                _CategoryChip(
                  label: 'Facial',
                  isSelected: _selectedCategory == 'Facial',
                  onTap: () => setState(() => _selectedCategory = 'Facial'),
                ),
                _CategoryChip(
                  label: 'Spa',
                  isSelected: _selectedCategory == 'Spa',
                  onTap: () => setState(() => _selectedCategory = 'Spa'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: salonsAsync.when(
              data: (salons) => Text(
                'ALL SALONS · ${salons.length} RESULTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: const Color(0xFF3D1C3D),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),

          // Grid of Salons
          Expanded(
            child: salonsAsync.when(
              data: (salons) {
                final filteredSalons = salons.where((s) {
                  final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  
                  // Improved category filtering:
                  // 1. If 'All' is selected, show everything.
                  // 2. Otherwise, check if the salon's categories list contains the selected category.
                  if (_selectedCategory == 'All') return matchesSearch;
                  
                  final matchesCategory = s.categories.any((c) => 
                    c.trim().toLowerCase() == _selectedCategory.toLowerCase());
                    
                  return matchesSearch && matchesCategory;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredSalons.length,
                  itemBuilder: (context, index) {
                    final salon = filteredSalons[index];
                    return GestureDetector(
                      onTap: () => context.push('/salons/${salon.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF7A0000).withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            Expanded(
                              flex: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  image: salon.mainImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(salon.mainImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: salon.mainImage == null 
                                  ? const Center(child: Icon(Icons.image_outlined, color: Colors.black12, size: 40))
                                  : null,
                              ),
                            ),
                            // Info Section
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      salon.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: Color(0xFF3D1C3D),
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 12, color: Color(0xFFB8935A)),
                                            const SizedBox(width: 2),
                                            Text(
                                              salon.rating.toString(),
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${salon.distance.toStringAsFixed(1)} KM',
                                          style: const TextStyle(
                                            fontSize: 10, 
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'From ',
                                              style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: '₹${salon.startingPrice?.toInt() ?? 0}',
                                              style: const TextStyle(
                                                color: Color(0xFF7A0000),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7A0000))),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D1C3D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
