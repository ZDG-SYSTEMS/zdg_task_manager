// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserLite _$UserLiteFromJson(Map<String, dynamic> json) => _UserLite(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String?,
  name: json['name'] as String,
  position: json['position'] as String?,
  branch: json['branch'] as String?,
);

Map<String, dynamic> _$UserLiteToJson(_UserLite instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'position': instance.position,
  'branch': instance.branch,
};

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$TaskTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String?,
  draftReason: json['draft_reason'] as String?,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
  amountRequested: (json['amount_requested'] as num?)?.toInt(),
  amountApproved: (json['amount_approved'] as num?)?.toInt(),
  amountEditReason: json['amount_edit_reason'] as String?,
  currency: json['currency'] as String? ?? 'ZMW',
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  beneficiaryType: $enumDecodeNullable(
    _$BeneficiaryTypeEnumMap,
    json['beneficiary_type'],
  ),
  beneficiaryName: json['beneficiary_name'] as String?,
  receiptRequired: json['receipt_required'] as bool?,
  overdue: json['overdue'] as bool? ?? false,
  viaTechnical: json['via_technical'] as bool? ?? false,
  funded: json['funded'] as bool? ?? false,
  fundedAt: json['funded_at'] == null
      ? null
      : DateTime.parse(json['funded_at'] as String),
  fundedReference: json['funded_reference'] as String?,
  fundedAmount: (json['funded_amount'] as num?)?.toInt(),
  amountIssued: (json['amount_issued'] as num?)?.toInt(),
  amountAccounted: (json['amount_accounted'] as num?)?.toInt(),
  balanceReturned: (json['balance_returned'] as num?)?.toInt(),
  balanceRemaining: (json['balance_remaining'] as num?)?.toInt(),
  receiptDueDate: json['receipt_due_date'] == null
      ? null
      : DateTime.parse(json['receipt_due_date'] as String),
  recipientId: (json['recipient_id'] as num?)?.toInt(),
  assignedFunderId: (json['assigned_funder_id'] as num?)?.toInt(),
  companyId: (json['company_id'] as num).toInt(),
  createdBy: (json['created_by'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  creator: json['creator'] == null
      ? null
      : UserLite.fromJson(json['creator'] as Map<String, dynamic>),
  company: json['company'] == null
      ? null
      : Company.fromJson(json['company'] as Map<String, dynamic>),
  recipient: json['recipient'] == null
      ? null
      : UserLite.fromJson(json['recipient'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  receipts: (json['receipts'] as List<dynamic>?)
      ?.map((e) => Receipt.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$TaskTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'draft_reason': instance.draftReason,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$PriorityEnumMap[instance.priority],
  'amount_requested': instance.amountRequested,
  'amount_approved': instance.amountApproved,
  'amount_edit_reason': instance.amountEditReason,
  'currency': instance.currency,
  'due_date': instance.dueDate?.toIso8601String(),
  'beneficiary_type': _$BeneficiaryTypeEnumMap[instance.beneficiaryType],
  'beneficiary_name': instance.beneficiaryName,
  'receipt_required': instance.receiptRequired,
  'overdue': instance.overdue,
  'via_technical': instance.viaTechnical,
  'funded': instance.funded,
  'funded_at': instance.fundedAt?.toIso8601String(),
  'funded_reference': instance.fundedReference,
  'funded_amount': instance.fundedAmount,
  'amount_issued': instance.amountIssued,
  'amount_accounted': instance.amountAccounted,
  'balance_returned': instance.balanceReturned,
  'balance_remaining': instance.balanceRemaining,
  'receipt_due_date': instance.receiptDueDate?.toIso8601String(),
  'recipient_id': instance.recipientId,
  'assigned_funder_id': instance.assignedFunderId,
  'company_id': instance.companyId,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt?.toIso8601String(),
  'creator': instance.creator?.toJson(),
  'company': instance.company?.toJson(),
  'recipient': instance.recipient?.toJson(),
  'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
  'receipts': instance.receipts?.map((e) => e.toJson()).toList(),
};

const _$TaskTypeEnumMap = {
  TaskType.standard: 'standard',
  TaskType.pettyCash: 'petty_cash',
};

const _$TaskStatusEnumMap = {
  TaskStatus.draft: 'draft',
  TaskStatus.submitted: 'submitted',
  TaskStatus.pendingApproval: 'pending_approval',
  TaskStatus.approved: 'approved',
  TaskStatus.pendingReceipt: 'pending_receipt',
  TaskStatus.completed: 'completed',
  TaskStatus.rejected: 'rejected',
  TaskStatus.postponed: 'postponed',
  TaskStatus.escalated: 'escalated',
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
};

const _$BeneficiaryTypeEnumMap = {
  BeneficiaryType.self: 'self',
  BeneficiaryType.other: 'other',
};
