import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/app_notification.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final response = await _dio.get('/notifications', queryParameters: {
      if (unreadOnly) 'unread': 1,
    });

    return (response.data['data'] as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    await _dio.patch('/notifications/$id/read');
  }
}

@riverpod
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository(ref.watch(apiClientProvider));

@riverpod
Future<List<AppNotification>> notificationList(Ref ref) =>
    ref.watch(notificationRepositoryProvider).list();
