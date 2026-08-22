import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, needsOnboarding }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState({required this.status, this.user, this.error});

  factory AuthState.unknown() => AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated({String? error}) => AuthState(status: AuthStatus.unauthenticated, error: error);
  factory AuthState.needsOnboarding() => AuthState(status: AuthStatus.needsOnboarding);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._ref) : super(AuthState.unknown()) {
    checkInitialState();
  }

  Future<void> _saveUserToCache(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(user.toJson()));
    } catch (e) {
      print('DEBUG_AUTH: Failed to cache user: $e');
    }
  }

  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
    } catch (e) {
      print('DEBUG_AUTH: Failed to clear user cache: $e');
    }
  }

  Future<UserModel?> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print('DEBUG_AUTH: Failed to load cached user: $e');
    }
    return null;
  }

  Future<void> checkInitialState() async {
    print('DEBUG_AUTH: 1. Checking Onboarding...');
    try {
      final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 3));
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!hasSeenOnboarding) {
        print('DEBUG_AUTH: 2. Needs Onboarding');
        state = AuthState.needsOnboarding();
        return;
      }

      print('DEBUG_AUTH: 3. Reading Token & Cache...');
      final token = await _storage.read(key: 'jwt_token').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );

      final cachedUser = await _loadUserFromCache();

      if (token == null) {
        print('DEBUG_AUTH: 4. No Token Found');
        state = AuthState.unauthenticated();
        return;
      }

      // If we have a token and a cached user, authenticate immediately for UI speed
      if (cachedUser != null) {
        print('DEBUG_AUTH: 4.5 Authenticating from Cache');
        state = AuthState.authenticated(cachedUser);
      }

      print('DEBUG_AUTH: 5. Verifying with Cloud...');
      final client = _ref.read(apiClientProvider);
      
      try {
        final response = await client.get('auth/me').timeout(const Duration(seconds: 4));
        
        if (response.statusCode == 200) {
          print('DEBUG_AUTH: 6. Session Validated');
          final userModel = UserModel.fromJson(response.data['data']);
          await _saveUserToCache(userModel);
          state = AuthState.authenticated(userModel);
        } else {
          print('DEBUG_AUTH: 7. Session Invalid (Not 200)');
          if (response.statusCode == 401 || response.statusCode == 403) {
            await logout();
          } else if (state.status == AuthStatus.unknown) {
             state = AuthState.unauthenticated(error: 'SERVER_UNAVAILABLE');
          }
        }
      } catch (e) {
        print('DEBUG_AUTH: Cloud verification failed, relying on cache/local state: $e');
        if (e is dio.DioException) {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await logout();
            return;
          }
        }
        
        // If we were already authenticated from cache, stay authenticated
        if (state.status == AuthStatus.unknown) {
          state = AuthState.unauthenticated(error: 'OFFLINE_MODE');
        }
      }
    } catch (e) {
      print('DEBUG_AUTH: Critical error in checkInitialState: $e');
      if (state.status == AuthStatus.unknown) {
        state = AuthState.unauthenticated(error: 'INITIALIZATION_ERROR');
      }
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    state = AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    try {
      state = AuthState.unknown(); // Loading state
      final client = _ref.read(apiClientProvider);
      final response = await client.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];
        final userModel = UserModel.fromJson(userData);
        
        await _storage.write(key: 'jwt_token', value: token);
        await _saveUserToCache(userModel);
        
        state = AuthState.authenticated(userModel);
      }
    } on dio.DioException catch (e) {
      String message = 'LOGIN_FAILED';
      if (e.type == dio.DioExceptionType.connectionTimeout) message = 'SERVER_UNREACHABLE';
      if (e.response?.statusCode == 401) message = 'INVALID_EMAIL_OR_PASSWORD';
      state = AuthState.unauthenticated(error: message);
      rethrow;
    } catch (e) {
      state = AuthState.unauthenticated(error: 'UNEXPECTED_ERROR');
      rethrow;
    }
  }

  Future<void> register({required String name, required String email, required String phone, required String password}) async {
    try {
      state = AuthState.unknown(); // Loading state
      final client = _ref.read(apiClientProvider);
      final response = await client.post('auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'CUSTOMER',
      });

      if (response.data['success']) {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];
        final userModel = UserModel.fromJson(userData);

        await _storage.write(key: 'jwt_token', value: token);
        await _saveUserToCache(userModel);

        state = AuthState.authenticated(userModel);
      }
    } on dio.DioException catch (e) {
      String message = 'REGISTRATION_FAILED';
      if (e.response?.statusCode == 400) message = 'EMAIL_ALREADY_REGISTERED';
      state = AuthState.unauthenticated(error: message);
      rethrow;
    } catch (e) {
      state = AuthState.unauthenticated(error: 'UNEXPECTED_ERROR');
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final client = _ref.read(apiClientProvider);
      await client.patch('auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  void updateLocalUser(UserModel user) {
    _saveUserToCache(user);
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _clearUserCache();
    state = AuthState.unauthenticated();
  }

  void loginAsDemo() {
    state = AuthState.authenticated(UserModel(
      id: 999,
      firebaseUid: 'demo_uid',
      role: 'CUSTOMER',
      name: 'Rishabh (Demo)',
      email: 'demo@quickque.com',
      isActive: true,
      phone: '9999999999',
    ));
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
