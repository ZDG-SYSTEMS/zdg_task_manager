// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The list screen's active filters; changing them re-fetches the list.

@ProviderFor(TaskFilters)
final taskFiltersProvider = TaskFiltersProvider._();

/// The list screen's active filters; changing them re-fetches the list.
final class TaskFiltersProvider
    extends $NotifierProvider<TaskFilters, TaskFilter> {
  /// The list screen's active filters; changing them re-fetches the list.
  TaskFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskFiltersHash();

  @$internal
  @override
  TaskFilters create() => TaskFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskFilter>(value),
    );
  }
}

String _$taskFiltersHash() => r'b8a3653f71c72c859c9ead09d4ed2131f0ada324';

/// The list screen's active filters; changing them re-fetches the list.

abstract class _$TaskFilters extends $Notifier<TaskFilter> {
  TaskFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskFilter, TaskFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskFilter, TaskFilter>,
              TaskFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(taskList)
final taskListProvider = TaskListProvider._();

final class TaskListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>
        >
    with $FutureModifier<List<Task>>, $FutureProvider<List<Task>> {
  TaskListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListHash();

  @$internal
  @override
  $FutureProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Task>> create(Ref ref) {
    return taskList(ref);
  }
}

String _$taskListHash() => r'a10e4cf7619678ef97b2f105a082c2ba83046348';

@ProviderFor(taskDetail)
final taskDetailProvider = TaskDetailFamily._();

final class TaskDetailProvider
    extends $FunctionalProvider<AsyncValue<Task>, Task, FutureOr<Task>>
    with $FutureModifier<Task>, $FutureProvider<Task> {
  TaskDetailProvider._({
    required TaskDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'taskDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskDetailHash();

  @override
  String toString() {
    return r'taskDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Task> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Task> create(Ref ref) {
    final argument = this.argument as int;
    return taskDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDetailHash() => r'28cd1153412911d355718dfea291d1b82dd0916a';

final class TaskDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Task>, int> {
  TaskDetailFamily._()
    : super(
        retry: null,
        name: r'taskDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskDetailProvider call(int id) =>
      TaskDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'taskDetailProvider';
}
