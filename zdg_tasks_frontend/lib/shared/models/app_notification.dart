import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
abstract class NotificationTask with _$NotificationTask {
  const factory NotificationTask({
    required int id,
    required String title,
  }) = _NotificationTask;

  factory NotificationTask.fromJson(Map<String, dynamic> json) =>
      _$NotificationTaskFromJson(json);
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    int? taskId,
    required String event,
    required List<String> channelsSent,
    DateTime? readAt,
    DateTime? createdAt,
    NotificationTask? task,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
