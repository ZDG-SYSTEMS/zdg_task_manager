import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums.dart';
import 'attachment.dart';
import 'company.dart';
import 'receipt.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Light projection of a user as embedded in task payloads
/// (creator/recipient/funder relations select limited columns).
@freezed
abstract class UserLite with _$UserLite {
  const factory UserLite({
    required int id,
    String? code,
    required String name,
    String? position,
    String? branch,
  }) = _UserLite;

  factory UserLite.fromJson(Map<String, dynamic> json) => _$UserLiteFromJson(json);
}

/// One row of the single tasks table; money fields are integer minor
/// units (ngwee) and must never become doubles.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required int id,
    required TaskType type,
    required String title,
    String? description,
    String? draftReason,
    required TaskStatus status,
    // Absent from payloads for non-approver viewers.
    Priority? priority,
    int? amountRequested,
    int? amountApproved,
    String? amountEditReason,
    @Default('ZMW') String currency,
    DateTime? dueDate,
    BeneficiaryType? beneficiaryType,
    String? beneficiaryName,
    bool? receiptRequired,
    @Default(false) bool overdue,
    @Default(false) bool viaTechnical,
    @Default(false) bool funded,
    DateTime? fundedAt,
    String? fundedReference,
    int? fundedAmount,
    int? amountIssued,
    int? amountAccounted,
    int? balanceReturned,
    int? balanceRemaining,
    DateTime? receiptDueDate,
    int? recipientId,
    int? assignedFunderId,
    required int companyId,
    int? createdBy,
    DateTime? createdAt,
    UserLite? creator,
    Company? company,
    UserLite? recipient,
    List<Attachment>? attachments,
    List<Receipt>? receipts,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
