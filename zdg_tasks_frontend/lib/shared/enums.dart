import 'package:json_annotation/json_annotation.dart';

/// Mirrors of the authoritative server enums from CLAUDE.md.
/// Wire names must match the backend exactly; do not rename.

enum Role {
  @JsonValue('technical')
  technical,
  @JsonValue('director')
  director,
  @JsonValue('dof')
  dof,
  @JsonValue('company_finance')
  companyFinance,
  @JsonValue('dept_head')
  deptHead,
  @JsonValue('auditor')
  auditor,
}

enum TaskType {
  @JsonValue('standard')
  standard,
  @JsonValue('petty_cash')
  pettyCash,
}

enum TaskStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('submitted')
  submitted,
  @JsonValue('pending_approval')
  pendingApproval,
  @JsonValue('approved')
  approved,
  @JsonValue('pending_receipt')
  pendingReceipt,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('postponed')
  postponed,
  @JsonValue('escalated')
  escalated,
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

enum BeneficiaryType {
  @JsonValue('self')
  self,
  @JsonValue('other')
  other,
}

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
}

enum AttachmentKind {
  @JsonValue('quotation')
  quotation,
  @JsonValue('invoice')
  invoice,
  @JsonValue('receipt')
  receipt,
}
