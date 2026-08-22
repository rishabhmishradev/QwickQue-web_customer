import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/salon_model.dart';
import 'location_service.dart';

class SalonApiService {
  final Dio _dio;
  SalonApiService(this._dio);

  Future<List<SalonSummary>> fetchNearbySalons({
    double? lat, 
    double? lng, 
    double? radius,
    String? category,
    String? city,
    String? state,
  }) async {
    try {
      final response = await _dio.get('salons', queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radius != null) 'radius': radius,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
      });
      
      final List data = response.data['data'];
      return data.map((json) => SalonSummary.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SalonDetail> fetchSalonDetail(int id) async {
    try {
      final response = await _dio.get('salons/$id');
      return SalonDetail.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _dio.get('services/categories');
      final List data = response.data['data'];
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final salonServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return SalonApiService(dio);
});

// Categories Provider
final serviceCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return await ref.watch(salonServiceProvider).fetchCategories();
});

// Nearby Salons Provider (Uses current location)
final nearbySalonsProvider = FutureProvider<List<SalonSummary>>((ref) async {
  final locationState = ref.watch(locationProvider);
  
  return await ref.watch(salonServiceProvider).fetchNearbySalons(
    lat: locationState.latitude,
    lng: locationState.longitude,
    city: locationState.cityName,
    state: locationState.stateName,
  );
});

// Salons by Category Provider
final salonsByCategoryProvider = FutureProvider.family<List<SalonSummary>, String>((ref, category) async {
  final locationState = ref.watch(locationProvider);
  
  return await ref.watch(salonServiceProvider).fetchNearbySalons(
    lat: locationState.latitude,
    lng: locationState.longitude,
    category: category,
    city: locationState.cityName,
    state: locationState.stateName,
  );
});

final salonDetailProvider = FutureProvider.family<SalonDetail, int>((ref, id) {
  return ref.watch(salonServiceProvider).fetchSalonDetail(id);
});
