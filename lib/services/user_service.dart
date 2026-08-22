import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final Dio _dio;
  final Ref _ref;

  UserService(this._dio, this._ref);

  Future<UserModel> updateProfile({required String name, required String phone}) async {
    try {
      final response = await _dio.patch('users/me', data: {
        'name': name,
        'phone': phone,
      });
      
      final updatedUser = UserModel.fromJson(response.data['data']);
      // Update the local auth state as well
      _ref.read(authProvider.notifier).updateLocalUser(updatedUser);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('users/me');
      await _ref.read(authProvider.notifier).logout();
    } catch (e) {
      rethrow;
    }
  }
}

final userServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return UserService(dio, ref);
});
