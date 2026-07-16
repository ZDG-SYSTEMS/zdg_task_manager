import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';

part 'report_repository.g.dart';

/// Reports are field-configurable server-side, so the client renders
/// them generically from the returned maps rather than typed models.
class ReportRepository {
  ReportRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetch(
    String tier, {
    required String period,
    required String date,
  }) async {
    final response = await _dio.get('/reports/$tier', queryParameters: {
      'period': period,
      'date': date,
    });

    return response.data['report'] as Map<String, dynamic>;
  }
}

@riverpod
ReportRepository reportRepository(Ref ref) => ReportRepository(ref.watch(apiClientProvider));
