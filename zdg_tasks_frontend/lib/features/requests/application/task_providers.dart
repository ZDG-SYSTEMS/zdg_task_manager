import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/task.dart';
import '../data/task_repository.dart';

part 'task_providers.g.dart';

/// The list screen's active filters; changing them re-fetches the list.
@riverpod
class TaskFilters extends _$TaskFilters {
  @override
  TaskFilter build() => const TaskFilter();

  void apply(TaskFilter filter) => state = filter;
}

@riverpod
Future<List<Task>> taskList(Ref ref) {
  final filter = ref.watch(taskFiltersProvider);

  return ref.watch(taskRepositoryProvider).list(filter);
}

@riverpod
Future<Task> taskDetail(Ref ref, int id) {
  return ref.watch(taskRepositoryProvider).get(id);
}
