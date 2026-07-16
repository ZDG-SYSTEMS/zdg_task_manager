import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/task.dart';

part 'petty_cash_repository.g.dart';

class PettyCashRepository {
  PettyCashRepository(this._dio);

  final Dio _dio;

  /// Issue immediately: no approval step. Amount in integer ngwee.
  Future<Task> create({
    required int recipientId,
    required int amountIssued,
    required String purpose,
    String? receiptDueDate,
  }) async {
    final response = await _dio.post('/petty-cash', data: {
      'recipient_id': recipientId,
      'amount_issued': amountIssued,
      'purpose': purpose,
      'receipt_due_date': ?receiptDueDate,
    });

    return Task.fromJson(response.data['task'] as Map<String, dynamic>);
  }

  Future<void> verifyReceipt(int taskId, int receiptId) async {
    await _dio.post('/tasks/$taskId/receipts/$receiptId/verify');
  }

  Future<void> returnBalance(int taskId, int amount) async {
    await _dio.post('/tasks/$taskId/return-balance', data: {'amount': amount});
  }

  Future<void> close(int taskId) async {
    await _dio.post('/tasks/$taskId/close');
  }
}

@riverpod
PettyCashRepository pettyCashRepository(Ref ref) =>
    PettyCashRepository(ref.watch(apiClientProvider));
