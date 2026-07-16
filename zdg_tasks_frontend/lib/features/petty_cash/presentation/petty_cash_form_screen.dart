import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../shared/money.dart';
import '../../requests/application/task_providers.dart';
import '../data/petty_cash_repository.dart';

/// Issue petty cash: no approval step, money is issued immediately on
/// creation and reconciled with receipts afterwards.
class PettyCashFormScreen extends ConsumerStatefulWidget {
  const PettyCashFormScreen({super.key});

  @override
  ConsumerState<PettyCashFormScreen> createState() => _PettyCashFormScreenState();
}

class _PettyCashFormScreenState extends ConsumerState<PettyCashFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientId = TextEditingController();
  final _amount = TextEditingController();
  final _purpose = TextEditingController();
  DateTime? _receiptDue;
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_recipientId, _amount, _purpose]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      final task = await ref.read(pettyCashRepositoryProvider).create(
            recipientId: int.parse(_recipientId.text.trim()),
            amountIssued: parseZmwToNgwee(_amount.text)!,
            purpose: _purpose.text.trim(),
            receiptDueDate: _receiptDue?.toIso8601String().substring(0, 10),
          );
      ref.invalidate(taskListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Petty cash issued; the recipient was notified.')),
        );
        context.go('/tasks/${task.id}');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue petty cash'),
        leading: BackButton(onPressed: () => context.go('/tasks')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _recipientId,
                    decoration: const InputDecoration(
                      labelText: 'Recipient user ID',
                      helperText: 'The recipient must hold an account',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        int.tryParse(value?.trim() ?? '') == null ? 'Enter a user ID' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(
                      labelText: 'Amount issued',
                      prefixText: 'ZMW ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        parseZmwToNgwee(value ?? '') == null ? 'Enter a valid amount' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purpose,
                    decoration: const InputDecoration(labelText: 'Purpose'),
                    maxLines: 2,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Purpose is required' : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _receiptDue = picked);
                    },
                    icon: const Icon(Icons.event),
                    label: Text(
                      _receiptDue == null
                          ? 'Receipt due date (optional)'
                          : 'Receipts due ${_receiptDue!.toIso8601String().substring(0, 10)}',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? 'Issuing...' : 'Issue now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
