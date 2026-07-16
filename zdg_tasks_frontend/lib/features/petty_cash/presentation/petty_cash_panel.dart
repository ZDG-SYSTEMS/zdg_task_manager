import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/task.dart';
import '../../../shared/models/user.dart';
import '../../../shared/money.dart';
import '../../../shared/permissions.dart';
import '../../approvals/presentation/approval_dialogs.dart';
import '../data/petty_cash_repository.dart';

/// The imprest reconciliation panel: the three figures tracked
/// continuously, the receipt list with finance verification, returned
/// balance recording, and the close action.
class PettyCashPanel extends ConsumerWidget {
  const PettyCashPanel({
    super.key,
    required this.task,
    required this.user,
    required this.onChanged,
  });

  final Task task;
  final User user;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(pettyCashRepositoryProvider);
    final canReconcile = user.canActOn(task) && task.status != TaskStatus.completed;

    void toast(String message) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    Future<void> run(Future<void> Function() action, String success) async {
      try {
        await action();
        onChanged();
        toast(success);
      } catch (error) {
        toast(apiErrorMessage(error));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Imprest reconciliation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _figure(context, 'Issued', task.amountIssued ?? 0),
                _figure(context, 'Accounted', task.amountAccounted ?? 0),
                _figure(context, 'Remaining', task.balanceRemaining ?? 0),
              ],
            ),
            if (task.balanceReturned != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Returned in cash: ${formatZmw(task.balanceReturned!)}'),
              ),
            if (task.receiptDueDate != null)
              Text(
                'Receipts due by ${task.receiptDueDate!.toIso8601String().substring(0, 10)}',
              ),
            const Divider(),
            Text('Receipts', style: Theme.of(context).textTheme.titleSmall),
            if (task.receipts == null || task.receipts!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No receipts uploaded yet.'),
              )
            else
              for (final receipt in task.receipts!)
                ListTile(
                  dense: true,
                  leading: Icon(
                    receipt.verified ? Icons.verified : Icons.pending_outlined,
                    color: receipt.verified ? Colors.green : null,
                  ),
                  title: Text(formatZmw(receipt.amount)),
                  subtitle: Text(receipt.attachment?.originalName ?? ''),
                  trailing: !receipt.verified && canReconcile
                      ? TextButton(
                          onPressed: () => run(
                            () => repository.verifyReceipt(task.id, receipt.id),
                            'Receipt verified.',
                          ),
                          child: const Text('Verify'),
                        )
                      : null,
                ),
            if (canReconcile) ...[
              const Divider(),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final amount = await promptForAmount(context, 'Returned balance');
                      if (amount == null) return;
                      await run(
                        () => repository.returnBalance(task.id, amount),
                        'Returned balance recorded.',
                      );
                    },
                    icon: const Icon(Icons.currency_exchange),
                    label: const Text('Record returned balance'),
                  ),
                  FilledButton.icon(
                    onPressed: () => run(
                      () => repository.close(task.id),
                      'Imprest reconciled and closed.',
                    ),
                    icon: const Icon(Icons.task_alt),
                    label: const Text('Verify and close'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _figure(BuildContext context, String label, int ngwee) => Expanded(
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              formatZmw(ngwee),
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
