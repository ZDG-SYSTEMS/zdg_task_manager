import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api_client.dart';
import '../../../shared/models/dashboard_data.dart';

part 'dashboard_repository.g.dart';

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardData> fetch() async {
    final response = await _dio.get('/dashboard');

    return DashboardData.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
DashboardRepository dashboardRepository(Ref ref) =>
    DashboardRepository(ref.watch(apiClientProvider));

@riverpod
Future<DashboardData> dashboard(Ref ref) => ref.watch(dashboardRepositoryProvider).fetch();
