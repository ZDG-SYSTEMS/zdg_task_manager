import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/task.dart';

part 'task_repository.g.dart';

class TaskFilter {
  const TaskFilter({this.status, this.type, this.priority, this.query, this.overdue = false});

  final String? status;
  final String? type;
  final String? priority;
  final String? query;
  final bool overdue;

  TaskFilter copyWith({String? status, String? type, String? priority, String? query, bool? overdue}) {
    return TaskFilter(
      status: status == '' ? null : status ?? this.status,
      type: type == '' ? null : type ?? this.type,
      priority: priority == '' ? null : priority ?? this.priority,
      query: query == '' ? null : query ?? this.query,
      overdue: overdue ?? this.overdue,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TaskFilter &&
      other.status == status &&
      other.type == type &&
      other.priority == priority &&
      other.query == query &&
      other.overdue == overdue;

  @override
  int get hashCode => Object.hash(status, type, priority, query, overdue);
}

class TaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  Future<List<Task>> list(TaskFilter filter) async {
    final response = await _dio.get('/tasks', queryParameters: {
      if (filter.status != null) 'status': filter.status,
      if (filter.type != null) 'type': filter.type,
      if (filter.priority != null) 'priority': filter.priority,
      if (filter.query != null) 'q': filter.query,
      if (filter.overdue) 'overdue': 1,
    });

    return (response.data['data'] as List)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Task> get(int id) async {
    final response = await _dio.get('/tasks/$id');

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> createDraft(Map<String, dynamic> payload) async {
    final response = await _dio.post('/tasks', data: payload);

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> updateDraft(int id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/tasks/$id', data: payload);

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> submit(int id) async {
    final response = await _dio.post('/tasks/$id/submit');

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> resubmit(int id) async {
    final response = await _dio.post('/tasks/$id/resubmit');

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<void> uploadAttachment(int id, List<int> bytes, String filename, String kind) async {
    await _dio.post('/tasks/$id/attachments', data: FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'kind': kind,
    }));
  }

  /// Proof of purchase; amount in integer ngwee.
  Future<void> uploadReceipt(int id, List<int> bytes, String filename, int amount) async {
    await _dio.post('/tasks/$id/receipts', data: FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'amount': amount,
    }));
  }
}

@riverpod
TaskRepository taskRepository(Ref ref) => TaskRepository(ref.watch(apiClientProvider));
