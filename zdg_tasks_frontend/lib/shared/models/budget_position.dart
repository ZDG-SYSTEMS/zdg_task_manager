import 'package:freezed_annotation/freezed_annotation.dart';

import 'company.dart';

part 'budget_position.freezed.dart';
part 'budget_position.g.dart';

/// A budget with its drawdown position: funded-to-date against the
/// budgeted amount. All money is integer ngwee.
@freezed
abstract class BudgetPosition with _$BudgetPosition {
  const factory BudgetPosition({
    required int id,
    required Company company,
    required String department,
    String? periodType,
    required String periodStart,
    required String periodEnd,
    required int amount,
    required int fundedToDate,
    required int remaining,
  }) = _BudgetPosition;

  factory BudgetPosition.fromJson(Map<String, dynamic> json) =>
      _$BudgetPositionFromJson(json);
}
