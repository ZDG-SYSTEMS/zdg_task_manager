// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationTask _$NotificationTaskFromJson(Map<String, dynamic> json) =>
    _NotificationTask(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$NotificationTaskToJson(_NotificationTask instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: (json['id'] as num).toInt(),
      taskId: (json['task_id'] as num?)?.toInt(),
      event: json['event'] as String,
      channelsSent: (json['channels_sent'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      task: json['task'] == null
          ? null
          : NotificationTask.fromJson(json['task'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'event': instance.event,
      'channels_sent': instance.channelsSent,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'task': instance.task?.toJson(),
    };
