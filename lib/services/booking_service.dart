import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio;
  BookingService(this._dio);

  Future<List<String>> getAvailability({
    required int salonId,
    required String date,
    required int serviceId,
    required int staffId,
  }) async {
    try {
      final response = await _dio.get('salons/$salonId/availability', queryParameters: {
        'date': date,
        'serviceId': serviceId,
        'staffId': staffId,
      });
      return List<String>.from(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingModel> holdSlot({
    required int salonId,
    required int staffId,
    required int serviceId,
    required String date,
    required String startTime,
  }) async {
    try {
      final response = await _dio.post('bookings/hold', data: {
        'salonId': salonId,
        'staffId': staffId,
        'serviceId': serviceId,
        'date': date,
        'startTime': startTime,
      });
      return BookingModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingModel> confirmBooking(int bookingId) async {
    try {
      final response = await _dio.post('bookings/confirm', data: {
        'bookingId': bookingId,
      });
      return BookingModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get('bookings/my-bookings');
      final List data = response.data['data'];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final bookingServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return BookingService(dio);
});
