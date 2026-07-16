import 'enums.dart';
import 'models/task.dart';
import 'models/user.dart';

/// Client-side mirror of the server permission matrix. This only hides
/// controls for convenience; the API is the source of truth for every
/// permission.
extension UserPermissions on User {
  bool get isApprover =>
      role == Role.technical || role == Role.dof || role == Role.companyFinance;

  bool get canCreatePettyCash =>
      role == Role.technical || role == Role.dof || role == Role.companyFinance;

  bool get canSeeReports =>
      role == Role.technical ||
      role == Role.dof ||
      role == Role.companyFinance ||
      role == Role.auditor;

  bool get canManageUsers => role == Role.technical;

  bool get canCreateStandard => role != null && role != Role.auditor;

  bool canActOn(Task task) {
    if (task.status == TaskStatus.escalated) {
      return role == Role.dof || role == Role.technical;
    }

    return switch (role) {
      Role.technical || Role.dof => true,
      Role.companyFinance => task.companyId == companyId,
      _ => false,
    };
  }

  /// Mark-as-funded: technical never funds.
  bool canFund(Task task) => switch (role) {
        Role.dof => true,
        Role.companyFinance => task.companyId == companyId,
        _ => false,
      };

  bool ownsEditable(Task task) =>
      (task.status == TaskStatus.draft || task.status == TaskStatus.rejected) &&
      (task.createdBy == id || role == Role.technical);

  bool canUploadReceipt(Task task) {
    if (role == null || role == Role.auditor) return false;
    if (role == Role.technical) return true;

    return task.recipientId == id || task.createdBy == id;
  }
}
