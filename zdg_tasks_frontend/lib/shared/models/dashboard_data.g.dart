// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardCounts _$DashboardCountsFromJson(Map<String, dynamic> json) =>
    _DashboardCounts(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      assigned: (json['assigned'] as num?)?.toInt() ?? 0,
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardCountsToJson(_DashboardCounts instance) =>
    <String, dynamic>{
      'total': instance.total,
      'pending': instance.pending,
      'in_progress': instance.inProgress,
      'assigned': instance.assigned,
      'overdue': instance.overdue,
    };

_MonthlyPoint _$MonthlyPointFromJson(Map<String, dynamic> json) =>
    _MonthlyPoint(
      month: json['month'] as String,
      requests: (json['requests'] as num?)?.toInt(),
      requestedTotal: (json['requested_total'] as num?)?.toInt(),
      fundedCount: (json['funded_count'] as num?)?.toInt(),
      fundedTotal: (json['funded_total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MonthlyPointToJson(_MonthlyPoint instance) =>
    <String, dynamic>{
      'month': instance.month,
      'requests': instance.requests,
      'requested_total': instance.requestedTotal,
      'funded_count': instance.fundedCount,
      'funded_total': instance.fundedTotal,
    };

_DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    _DashboardData(
      counts: DashboardCounts.fromJson(json['counts'] as Map<String, dynamic>),
      byStatus: json['by_status'] == null
          ? const {}
          : _statusMap(json['by_status']),
      monthlyRequests:
          (json['monthly_requests'] as List<dynamic>?)
              ?.map((e) => MonthlyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      monthlyFunded:
          (json['monthly_funded'] as List<dynamic>?)
              ?.map((e) => MonthlyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      budgets:
          (json['budgets'] as List<dynamic>?)
              ?.map((e) => BudgetPosition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DashboardDataToJson(
  _DashboardData instance,
) => <String, dynamic>{
  'counts': instance.counts.toJson(),
  'by_status': instance.byStatus,
  'monthly_requests': instance.monthlyRequests.map((e) => e.toJson()).toList(),
  'monthly_funded': instance.monthlyFunded.map((e) => e.toJson()).toList(),
  'budgets': instance.budgets.map((e) => e.toJson()).toList(),
};
