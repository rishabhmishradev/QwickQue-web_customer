import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/network/api_client.dart';
import '../core/routes/router.dart';

class NotificationsService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Ref _ref;

  NotificationsService(this._ref);

  Future<void> init() async {
    // Notifications disabled for review mode
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final dio = _ref.read(apiClientProvider);
      await dio.post('/notifications/register-token', data: {'token': token});
      print('FCM Token registered with backend');
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final bookingId = message.data['bookingId'];
    final type = message.data['type'];
    
    if (bookingId != null) {
      if (type == 'BOOKING_COMPLETED') {
        _ref.read(routerProvider).push('/review/$bookingId');
      } else {
        print('Navigate to booking: $bookingId');
      }
    }
  }
}

final notificationsServiceProvider = Provider((ref) => NotificationsService(ref));
