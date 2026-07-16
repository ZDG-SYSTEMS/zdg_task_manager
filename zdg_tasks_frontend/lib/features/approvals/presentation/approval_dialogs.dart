import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/user.dart';
import '../../../shared/money.dart';
import '../data/approval_repository.dart';

/// Prompts for a ZMW amount and returns integer ngwee.
Future<int?> promptForAmount(BuildContext context, String title) async {
  final controller = TextEditingController();

  final result = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(prefixText: 'ZMW '),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final ngwee = parseZmwToNgwee(controller.text);
            if (ngwee != null) Navigator.of(context).pop(ngwee);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
  controller.dispose();

  return result;
}

/// Approve with optional amount edit (reason required when the amount
/// differs), the receipt-required radial, and dof-only assignment.
Future<bool?> showApproveDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
  User user,
) async {
  final amount = TextEditingController(
    text: task.amountRequested != null
        ? (task.amountRequested! / 100).toStringAsFixed(2)
        : '',
  );
  final reason = TextEditingController();
  var receiptRequired = false;
  int? funderId;

  List<UserLite> funders = const [];
  if (user.role == Role.dof) {
    try {
      funders = await ref.read(approvalRepositoryProvider).assignableFunders(task.id);
    } catch (_) {}
  }

  if (!context.mounted) return false;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Approve request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Approved amount',
                  prefixText: 'ZMW ',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reason,
                decoration: const InputDecoration(
                  labelText: 'Edit reason (required when amount changes)',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Receipt required'),
                subtitle: const Text('Holds the task open until proof of purchase'),
                value: receiptRequired,
                onChanged: (value) => setState(() => receiptRequired = value),
              ),
              if (user.role == Role.dof && funders.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: funderId,
                  decoration: const InputDecoration(
                    labelText: 'Assign to company finance (optional)',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No assignment')),
                    for (final funder in funders)
                      DropdownMenuItem(value: funder.id, child: Text(funder.name)),
                  ],
                  onChanged: (value) => setState(() => funderId = value),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(approvalRepositoryProvider).approve(
                      task.id,
                      amountApproved: parseZmwToNgwee(amount.text),
                      amountEditReason: reason.text.trim(),
                      receiptRequired: receiptRequired,
                      assignedFunderId: funderId,
                    );
                if (context.mounted) Navigator.of(context).pop(true);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
                }
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showRejectDialog(BuildContext context, WidgetRef ref, Task task) {
  return _reasonDialog(
    context,
    title: 'Reject request',
    label: 'Reason (shown to the requester)',
    action: 'Reject',
    onSubmit: (reason) => ref.read(approvalRepositoryProvider).reject(task.id, reason),
  );
}

Future<bool?> showPostponeDialog(BuildContext context, WidgetRef ref, Task task) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 14)),
    firstDate: DateTime.now().add(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    helpText: 'New due date',
  );
  if (picked == null || !context.mounted) return false;

  final date = picked.toIso8601String().substring(0, 10);

  return _reasonDialog(
    context,
    title: 'Postpone to $date',
    label: 'Reason',
    action: 'Postpone',
    onSubmit: (reason) =>
        ref.read(approvalRepositoryProvider).postpone(task.id, date, reason),
  );
}

Future<bool?> showFundDialog(BuildContext context, WidgetRef ref, Task task) async {
  final amount = TextEditingController(
    text: task.amountApproved != null
        ? (task.amountApproved! / 100).toStringAsFixed(2)
        : '',
  );
  final reference = TextEditingController();

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Record funding'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount released',
              prefixText: 'ZMW ',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reference,
            decoration: const InputDecoration(labelText: 'Payment reference'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Money is released outside the app; this records the release for reporting.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final ngwee = parseZmwToNgwee(amount.text);
            if (ngwee == null || reference.text.trim().isEmpty) return;
            try {
              await ref
                  .read(approvalRepositoryProvider)
                  .fund(task.id, ngwee, reference.text.trim());
              if (context.mounted) Navigator.of(context).pop(true);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
              }
            }
          },
          child: const Text('Record'),
        ),
      ],
    ),
  );
}

Future<bool?> _reasonDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  required Future<void> Function(String reason) onSubmit,
}) {
  final controller = TextEditingController();

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 2,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (controller.text.trim().isEmpty) return;
            try {
              await onSubmit(controller.text.trim());
              if (context.mounted) Navigator.of(context).pop(true);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
              }
            }
          },
          child: Text(action),
        ),
      ],
    ),
  );
}
