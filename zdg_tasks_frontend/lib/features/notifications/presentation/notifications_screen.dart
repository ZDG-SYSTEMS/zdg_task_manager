import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return notifications.when(
      data: (items) => items.isEmpty
          ? const Center(child: Text('No notifications.'))
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(notificationListProvider),
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = items[index];
                  final unread = notification.readAt == null;

                  return ListTile(
                    leading: Icon(
                      unread ? Icons.mark_email_unread : Icons.drafts_outlined,
                      color: unread ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(
                      notification.event.replaceAll('_', ' '),
                      style: unread
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                    ),
                    subtitle: Text(notification.task?.title ?? ''),
                    trailing: notification.createdAt == null
                        ? null
                        : Text(
                            notification.createdAt!
                                .toIso8601String()
                                .substring(0, 10),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                    onTap: () async {
                      if (unread) {
                        try {
                          await ref
                              .read(notificationRepositoryProvider)
                              .markRead(notification.id);
                          ref.invalidate(notificationListProvider);
                        } catch (_) {}
                      }
                      if (notification.taskId != null && context.mounted) {
                        context.go('/tasks/${notification.taskId}');
                      }
                    },
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(apiErrorMessage(error))),
    );
  }
}
