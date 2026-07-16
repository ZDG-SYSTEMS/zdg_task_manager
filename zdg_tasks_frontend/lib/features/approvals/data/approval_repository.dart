import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/task.dart';

part 'approval_repository.g.dart';

class ApprovalRepository {
  ApprovalRepository(this._dio);

  final Dio _dio;

  /// Approve; optional amount edit (ngwee, reason required by the
  /// API when it differs) and optional dof assignment.
  Future<Task> approve(int id, {
    int? amountApproved,
    String? amountEditReason,
    required bool receiptRequired,
    int? assignedFunderId,
  }) async {
    final response = await _dio.post('/tasks/$id/approve', data: {
      'amount_approved': ?amountApproved,
      if (amountEditReason != null && amountEditReason.isNotEmpty)
        'amount_edit_reason': amountEditReason,
      'receipt_required': receiptRequired,
      'assigned_funder_id': ?assignedFunderId,
    });

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> reject(int id, String reason) async {
    final response = await _dio.post('/tasks/$id/reject', data: {'reason': reason});

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<Task> postpone(int id, String dueDate, String reason) async {
    final response = await _dio.post('/tasks/$id/postpone', data: {
      'due_date': dueDate,
      'reason': reason,
    });

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  /// Mark-as-funded: the data-only record of an external release.
  Future<Task> fund(int id, int amount, String reference) async {
    final response = await _dio.post('/tasks/$id/fund', data: {
      'funded_amount': amount,
      'funded_reference': reference,
    });

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<List<UserLite>> assignableFunders(int id) async {
    final response = await _dio.get('/tasks/$id/assignable-funders');

    return (response.data['funders'] as List)
        .map((json) => UserLite.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
ApprovalRepository approvalRepository(Ref ref) =>
    ApprovalRepository(ref.watch(apiClientProvider));
