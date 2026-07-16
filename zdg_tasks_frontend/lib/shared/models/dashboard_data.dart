import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget_position.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

@freezed
abstract class DashboardCounts with _$DashboardCounts {
  const factory DashboardCounts({
    @Default(0) int total,
    @Default(0) int pending,
    @Default(0) int inProgress,
    @Default(0) int assigned,
    @Default(0) int overdue,
  }) = _DashboardCounts;

  factory DashboardCounts.fromJson(Map<String, dynamic> json) =>
      _$DashboardCountsFromJson(json);
}

@freezed
abstract class MonthlyPoint with _$MonthlyPoint {
  const factory MonthlyPoint({
    required String month,
    int? requests,
    int? requestedTotal,
    int? fundedCount,
    int? fundedTotal,
  }) = _MonthlyPoint;

  factory MonthlyPoint.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPointFromJson(json);
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required DashboardCounts counts,
    // Empty PHP arrays serialize as [] while populated maps are {};
    // the converter accepts both shapes.
    @JsonKey(fromJson: _statusMap) @Default({}) Map<String, int> byStatus,
    @Default([]) List<MonthlyPoint> monthlyRequests,
    @Default([]) List<MonthlyPoint> monthlyFunded,
    @Default([]) List<BudgetPosition> budgets,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

Map<String, int> _statusMap(Object? raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
  }

  return {};
}
