import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _steps = [
    {
      'title': 'DISCOVER',
      'subtitle': 'CURATED ARTISANS',
      'description': 'Browse a hand-picked selection of the finest salons and stylists in your city.'
    },
    {
      'title': 'SELECT',
      'subtitle': 'PRECISE SLOTS',
      'description': 'Real-time availability tracking means no more waiting or double-bookings.'
    },
    {
      'title': 'SECURE',
      'subtitle': 'INSTANT TICKETS',
      'description': 'Get your digital appointment stub instantly and manage your grooming ledger with ease.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.chalk,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _steps[index]['title']!,
                          style: theme.textTheme.displayMedium?.copyWith(letterSpacing: 4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _steps[index]['subtitle']!,
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.brass, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 48),
                        Container(width: 32, height: 1, color: AppColors.ink),
                        const SizedBox(height: 48),
                        Text(
                          _steps[index]['description']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.rouge : AppColors.ink.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentPage < _steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        ref.read(authProvider.notifier).completeOnboarding();
                        context.go('/login');
                      }
                    },
                    child: Text(
                      _currentPage < _steps.length - 1 ? 'NEXT' : 'ENTER',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.rouge,
                      ),
                    ),
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
