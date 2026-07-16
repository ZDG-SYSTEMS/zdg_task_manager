// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetPosition _$BudgetPositionFromJson(Map<String, dynamic> json) =>
    _BudgetPosition(
      id: (json['id'] as num).toInt(),
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      department: json['department'] as String,
      periodType: json['period_type'] as String?,
      periodStart: json['period_start'] as String,
      periodEnd: json['period_end'] as String,
      amount: (json['amount'] as num).toInt(),
      fundedToDate: (json['funded_to_date'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
    );

Map<String, dynamic> _$BudgetPositionToJson(_BudgetPosition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company.toJson(),
      'department': instance.department,
      'period_type': instance.periodType,
      'period_start': instance.periodStart,
      'period_end': instance.periodEnd,
      'amount': instance.amount,
      'funded_to_date': instance.fundedToDate,
      'remaining': instance.remaining,
    };
