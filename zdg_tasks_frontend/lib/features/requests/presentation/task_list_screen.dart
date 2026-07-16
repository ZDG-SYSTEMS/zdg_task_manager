import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/task.dart';
import '../../../shared/money.dart';
import '../../../shared/permissions.dart';
import '../../auth/application/auth_controller.dart';
import '../application/task_providers.dart';
import '../data/task_repository.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final filter = ref.watch(taskFiltersProvider);
    final user = ref.watch(authControllerProvider).value?.user;
    if (user == null) return const SizedBox.shrink();

    void apply(TaskFilter next) => ref.read(taskFiltersProvider.notifier).apply(next);

    return Scaffold(
      floatingActionButton: user.canCreateStandard
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/tasks/new'),
              icon: const Icon(Icons.add),
              label: const Text('New request'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search title, description, name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          apply(filter.copyWith(query: ''));
                        },
                      ),
                    ),
                    onSubmitted: (value) => apply(filter.copyWith(query: value)),
                  ),
                ),
                if (user.canCreatePettyCash) ...[
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/petty-cash/new'),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Issue petty cash'),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _statusFilter(filter, apply),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue'),
                  selected: filter.overdue,
                  onSelected: (selected) => apply(filter.copyWith(overdue: selected)),
                ),
                if (user.isApprover) ...[
                  const SizedBox(width: 8),
                  _priorityFilter(filter, apply),
                ],
              ],
            ),
          ),
          Expanded(
            child: tasks.when(
              data: (items) => items.isEmpty
                  ? const Center(child: Text('No tasks found.'))
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(taskListProvider),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _TaskTile(task: items[index], isApprover: user.isApprover),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(apiErrorMessage(error))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilter(TaskFilter filter, void Function(TaskFilter) apply) {
    return DropdownMenu<String>(
      hintText: 'Status',
      initialSelection: filter.status ?? '',
      dropdownMenuEntries: [
        const DropdownMenuEntry(value: '', label: 'All statuses'),
        for (final status in TaskStatus.values)
          DropdownMenuEntry(value: _wire(status.name), label: status.name),
      ],
      onSelected: (value) => apply(filter.copyWith(status: value ?? '')),
    );
  }

  Widget _priorityFilter(TaskFilter filter, void Function(TaskFilter) apply) {
    return DropdownMenu<String>(
      hintText: 'Priority',
      initialSelection: filter.priority ?? '',
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: '', label: 'Any priority'),
        DropdownMenuEntry(value: 'urgent', label: 'urgent'),
        DropdownMenuEntry(value: 'high', label: 'high'),
        DropdownMenuEntry(value: 'medium', label: 'medium'),
        DropdownMenuEntry(value: 'low', label: 'low'),
      ],
      onSelected: (value) => apply(filter.copyWith(priority: value ?? '')),
    );
  }

  /// camelCase enum names back to the API's snake_case wire values.
  String _wire(String name) => name.replaceAllMapped(
        RegExp('[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.isApprover});

  final Task task;
  final bool isApprover;

  @override
  Widget build(BuildContext context) {
    final amount = task.amountRequested ?? task.amountIssued;

    return ListTile(
      onTap: () => context.go('/tasks/${task.id}'),
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          task.creator?.name,
          task.company?.code,
          if (task.creator?.branch != null) task.creator!.branch,
          if (task.dueDate != null) 'due ${task.dueDate!.toIso8601String().substring(0, 10)}',
        ].whereType<String>().join(' | '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (amount != null) Text(formatZmw(amount)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.overdue)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                ),
              if (isApprover && task.priority != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    task.priority!.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              _StatusChip(status: task.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      TaskStatus.completed => (Colors.green.shade100, Colors.green.shade900),
      TaskStatus.rejected => (scheme.errorContainer, scheme.onErrorContainer),
      TaskStatus.escalated => (Colors.orange.shade100, Colors.orange.shade900),
      _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
