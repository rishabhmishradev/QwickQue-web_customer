import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/explore_screen.dart';
import '../../features/home/presentation/splash_screen.dart';
import '../../features/home/presentation/onboarding_screen.dart';
import '../../features/salons/presentation/salon_detail_screen.dart';
import '../../features/salons/presentation/category_detail_screen.dart';
import '../../features/reviews/presentation/review_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/booking_summary_screen.dart';
import '../../features/profile/presentation/booking_history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/change_password_screen.dart';
import '../../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<AuthState>(ref.watch(authProvider));
  ref.listen(authProvider, (_, next) => refreshListenable.value = next);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final isAtSplash = state.matchedLocation == '/';
      final goingToAuth = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' || 
                          state.matchedLocation == '/onboarding';
      
      if (status == AuthStatus.unknown) return isAtSplash ? null : '/';

      if (status == AuthStatus.needsOnboarding) {
        return goingToAuth ? null : '/onboarding';
      }
      
      if (status == AuthStatus.authenticated) {
        if (isAtSplash || goingToAuth) return '/home';
        return null;
      }
      
      if (status == AuthStatus.unauthenticated) {
        if (!goingToAuth) return '/login';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
      GoRoute(
        path: '/category/:name',
        builder: (context, state) => CategoryDetailScreen(category: state.pathParameters['name']!),
      ),
      GoRoute(
        path: '/salons/:id',
        builder: (context, state) => SalonDetailScreen(salonId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/review/:bookingId',
        builder: (context, state) => ReviewScreen(bookingId: int.parse(state.pathParameters['bookingId']!)),
      ),
      GoRoute(
        path: '/book/:salonId',
        builder: (context, state) {
          final salonId = int.parse(state.pathParameters['salonId']!);
          final serviceId = state.uri.queryParameters['serviceId'];
          return BookingScreen(
            salonId: salonId,
            initialServiceId: serviceId != null ? int.parse(serviceId) : null,
          );
        },
      ),
      GoRoute(
        path: '/booking-summary',
        builder: (context, state) => BookingSummaryScreen(bookingData: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/my-bookings', builder: (context, state) => const BookingHistoryScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(
        path: '/offers',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('OFFERS')),
          body: const Center(child: Text('No offers available yet')),
        ),
      ),
    ],
  );
});
