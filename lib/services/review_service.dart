import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewService {
  final Dio _dio;
  ReviewService(this._dio);

  Future<void> postReview(int bookingId, int rating, String? comment) async {
    try {
      await _dio.post('reviews', data: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewModel>> fetchSalonReviews(int salonId) async {
    try {
      final response = await _dio.get('reviews/salons/$salonId');
      final List data = response.data['data'];
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final reviewServiceProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return ReviewService(dio);
});
