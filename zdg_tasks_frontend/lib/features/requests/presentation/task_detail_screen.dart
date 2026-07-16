import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/user.dart';
import '../../../shared/money.dart';
import '../../../shared/permissions.dart';
import '../../approvals/presentation/approval_dialogs.dart';
import '../../auth/application/auth_controller.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../petty_cash/presentation/petty_cash_panel.dart';
import '../application/task_providers.dart';
import '../data/task_repository.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  void _refresh(WidgetRef ref) {
    ref
      ..invalidate(taskDetailProvider(taskId))
      ..invalidate(taskListProvider)
      ..invalidate(dashboardProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final detail = ref.watch(taskDetailProvider(taskId));
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task #$taskId'),
        leading: BackButton(onPressed: () => context.go('/tasks')),
      ),
      body: detail.when(
        data: (task) => _body(context, ref, task, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(apiErrorMessage(error))),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, Task task, User user) {
    void toast(String message) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    Future<void> run(Future<void> Function() action, String success) async {
      try {
        await action();
        _refresh(ref);
        toast(success);
      } catch (error) {
        toast(apiErrorMessage(error));
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Chip(label: Text(task.status.name)),
                        if (task.overdue)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Chip(
                              label: Text('overdue'),
                              backgroundColor: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                    if (task.viaTechnical)
                      Text(
                        'Flagged: actioned via technical (not a genuine authorization)',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    const SizedBox(height: 8),
                    if (task.description != null) Text(task.description!),
                    const Divider(),
                    _row('Type', task.type.name),
                    if (task.creator != null)
                      _row(
                        'Requested by',
                        '${task.creator!.name} (${task.creator!.position ?? ''})',
                      ),
                    if (task.company != null) _row('Company', task.company!.name),
                    if (task.priority != null && user.isApprover)
                      _row('Priority', task.priority!.name),
                    if (task.amountRequested != null)
                      _row('Amount requested', formatZmw(task.amountRequested!)),
                    if (task.amountApproved != null)
                      _row('Amount approved', formatZmw(task.amountApproved!)),
                    if (task.amountEditReason != null)
                      _row('Edit reason', task.amountEditReason!),
                    if (task.dueDate != null)
                      _row('Due date', task.dueDate!.toIso8601String().substring(0, 10)),
                    if (task.beneficiaryType != null)
                      _row(
                        'Beneficiary',
                        task.beneficiaryType == BeneficiaryType.self
                            ? (task.creator?.name ?? 'Self')
                            : (task.beneficiaryName ?? ''),
                      ),
                    if (task.receiptRequired != null)
                      _row('Receipt required', task.receiptRequired! ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
            if (task.funded) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Funding record',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      _row('Amount released', formatZmw(task.fundedAmount ?? 0)),
                      _row('Reference', task.fundedReference ?? ''),
                      if (task.fundedAt != null)
                        _row(
                          'Released on',
                          task.fundedAt!.toIso8601String().substring(0, 10),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (task.type == TaskType.pettyCash) ...[
              const SizedBox(height: 12),
              PettyCashPanel(task: task, user: user, onChanged: () => _refresh(ref)),
            ],
            if (task.attachments != null && task.attachments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                      for (final attachment in task.attachments!)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.attach_file),
                          title: Text(attachment.originalName),
                          subtitle: Text(attachment.kind.name),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (user.ownsEditable(task))
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/tasks/${task.id}/edit'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                if (user.ownsEditable(task))
                  OutlinedButton.icon(
                    onPressed: () => _attach(context, ref, task, run),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Attach quotation/invoice'),
                  ),
                if (task.status == TaskStatus.draft && user.ownsEditable(task))
                  FilledButton.icon(
                    onPressed: () => run(
                      () => ref.read(taskRepositoryProvider).submit(task.id),
                      'Submitted to your company finance office.',
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                  ),
                if (task.status == TaskStatus.rejected && user.ownsEditable(task))
                  FilledButton.icon(
                    onPressed: () => run(
                      () => ref.read(taskRepositoryProvider).resubmit(task.id),
                      'Resubmitted for approval.',
                    ),
                    icon: const Icon(Icons.redo),
                    label: const Text('Resubmit'),
                  ),
                if (task.type == TaskType.standard &&
                    task.status == TaskStatus.pendingReceipt &&
                    user.canUploadReceipt(task))
                  FilledButton.icon(
                    onPressed: () => _uploadReceipt(context, ref, task, run),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Upload proof of purchase'),
                  ),
                if ((task.status == TaskStatus.pendingApproval ||
                        task.status == TaskStatus.escalated) &&
                    user.canActOn(task)) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      final done = await showApproveDialog(context, ref, task, user);
                      if (done == true) _refresh(ref);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final done = await showRejectDialog(context, ref, task);
                      if (done == true) _refresh(ref);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                  if (task.status == TaskStatus.pendingApproval)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final done = await showPostponeDialog(context, ref, task);
                        if (done == true) _refresh(ref);
                      },
                      icon: const Icon(Icons.schedule),
                      label: const Text('Postpone'),
                    ),
                ],
                if (!task.funded &&
                    user.canFund(task) &&
                    (task.status == TaskStatus.approved ||
                        task.status == TaskStatus.pendingReceipt ||
                        task.status == TaskStatus.completed))
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final done = await showFundDialog(context, ref, task);
                      if (done == true) _refresh(ref);
                    },
                    icon: const Icon(Icons.payments),
                    label: const Text('Mark as funded'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _attach(
    BuildContext context,
    WidgetRef ref,
    Task task,
    Future<void> Function(Future<void> Function(), String) run,
  ) async {
    final kind = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Attachment type'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('quotation'),
            child: const Text('Quotation'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('invoice'),
            child: const Text('Invoice'),
          ),
        ],
      ),
    );
    if (kind == null) return;

    final picked = await FilePicker.pickFiles(withData: true);
    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    await run(
      () => ref
          .read(taskRepositoryProvider)
          .uploadAttachment(task.id, file.bytes!, file.name, kind),
      'Attachment uploaded.',
    );
  }

  Future<void> _uploadReceipt(
    BuildContext context,
    WidgetRef ref,
    Task task,
    Future<void> Function(Future<void> Function(), String) run,
  ) async {
    final amount = await promptForAmount(context, 'Receipt amount');
    if (amount == null) return;

    final picked = await FilePicker.pickFiles(withData: true);
    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;

    await run(
      () => ref
          .read(taskRepositoryProvider)
          .uploadReceipt(task.id, file.bytes!, file.name, amount),
      'Receipt uploaded.',
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 160, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
