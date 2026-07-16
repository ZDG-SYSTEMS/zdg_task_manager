import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/user.dart';
import '../data/user_admin_repository.dart';

/// Technical-only account management. Assigning a role to a pending
/// registration activates the account.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);

    return users.when(
      data: (items) {
        final pending = items.where((user) => user.role == null).toList();
        final active = items.where((user) => user.role != null).toList();

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(userListProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text(
                  'Awaiting role assignment (${pending.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final user in pending) _userTile(context, ref, user, pending: true),
                const Divider(height: 32),
              ],
              Text(
                'All accounts (${active.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final user in active) _userTile(context, ref, user, pending: false),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(apiErrorMessage(error))),
    );
  }

  Widget _userTile(BuildContext context, WidgetRef ref, User user, {required bool pending}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(user.company?.code.substring(0, 1) ?? '?')),
        title: Text('${user.name} (${user.code})'),
        subtitle: Text(
          [
            user.company?.code,
            user.department,
            user.position,
            user.role?.name ?? 'no role',
            user.status.name,
          ].whereType<String>().join(' | '),
        ),
        trailing: pending
            ? FilledButton(
                onPressed: () => _assignRole(context, ref, user),
                child: const Text('Assign role'),
              )
            : PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'role') {
                    await _assignRole(context, ref, user);
                  } else {
                    await _toggleStatus(context, ref, user);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'role', child: Text('Change role')),
                  PopupMenuItem(
                    value: 'status',
                    child: Text(
                      user.status == UserStatus.active ? 'Deactivate' : 'Activate',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _assignRole(BuildContext context, WidgetRef ref, User user) async {
    final role = await showDialog<Role>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Assign role to ${user.name}'),
        children: [
          for (final role in Role.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(role),
              child: Text(role.name),
            ),
        ],
      ),
    );
    if (role == null) return;

    // Wire value: snake_case of the enum name.
    final wire = role.name.replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );

    try {
      await ref.read(userAdminRepositoryProvider).update(user.id, {'role': wire});
      ref.invalidate(userListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} is now ${role.name} and active.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref, User user) async {
    final next = user.status == UserStatus.active ? 'inactive' : 'active';
    try {
      await ref.read(userAdminRepositoryProvider).update(user.id, {'status': next});
      ref.invalidate(userListProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }
}
