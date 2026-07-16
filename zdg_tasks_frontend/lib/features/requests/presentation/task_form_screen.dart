import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_error.dart';
import '../../../shared/enums.dart';
import '../../../shared/models/task.dart';
import '../../../shared/money.dart';
import '../application/task_providers.dart';
import '../data/task_repository.dart';

/// Create or edit a standard request. Save as draft at any point;
/// Complete validates, shows the verification summary, and submits.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final int? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _beneficiaryName = TextEditingController();
  DateTime? _dueDate;
  BeneficiaryType _beneficiary = BeneficiaryType.self;
  bool _busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final controller in [_title, _description, _amount, _beneficiaryName]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _prefill(Task task) {
    if (_loaded) return;
    _loaded = true;
    _title.text = task.title;
    _description.text = task.description ?? '';
    if (task.amountRequested != null) {
      _amount.text = (task.amountRequested! / 100).toStringAsFixed(2);
    }
    _beneficiaryName.text = task.beneficiaryName ?? '';
    _beneficiary = task.beneficiaryType ?? BeneficiaryType.self;
    _dueDate = task.dueDate;
  }

  Map<String, dynamic> _payload({String? draftReason}) => {
        'title': _title.text.trim(),
        'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
        'amount_requested': parseZmwToNgwee(_amount.text),
        'due_date': _dueDate?.toIso8601String().substring(0, 10),
        'beneficiary_type': _beneficiary == BeneficiaryType.self ? 'self' : 'other',
        'beneficiary_name':
            _beneficiaryName.text.trim().isEmpty ? null : _beneficiaryName.text.trim(),
        'draft_reason': ?draftReason,
      };

  Future<Task> _persistDraft({String? draftReason}) async {
    final repository = ref.read(taskRepositoryProvider);
    final payload = _payload(draftReason: draftReason);

    return widget.taskId == null
        ? await repository.createDraft(payload)
        : await repository.updateDraft(widget.taskId!, payload);
  }

  Future<void> _saveDraft() async {
    if (_title.text.trim().isEmpty) {
      _toast('A title is required to save a draft.');

      return;
    }
    setState(() => _busy = true);
    try {
      await _persistDraft();
      ref.invalidate(taskListProvider);
      if (mounted) {
        _toast('Draft saved.');
        context.go('/tasks');
      }
    } catch (error) {
      _toast(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Complete: inline validation blocks missing fields (never
  /// auto-drafted), then the verification summary confirms, then
  /// submit. A genuine network failure auto-saves as a draft with the
  /// recorded reason.
  Future<void> _complete() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify your request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Title', _title.text.trim()),
              _summaryRow('Description', _description.text.trim()),
              _summaryRow('Amount', formatZmw(parseZmwToNgwee(_amount.text) ?? 0)),
              _summaryRow('Due date', _dueDate!.toIso8601String().substring(0, 10)),
              _summaryRow(
                'Beneficiary',
                _beneficiary == BeneficiaryType.self
                    ? 'Myself'
                    : _beneficiaryName.text.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Edit'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    Task? draft;
    try {
      draft = await _persistDraft();
      final task = await ref.read(taskRepositoryProvider).submit(draft.id);
      ref.invalidate(taskListProvider);
      if (mounted) {
        _toast('Request submitted to your company finance office.');
        context.go('/tasks/${task.id}');
      }
    } catch (error) {
      // The draft persisted; record why submission did not complete.
      if (draft != null) {
        try {
          await ref.read(taskRepositoryProvider).updateDraft(draft.id, {
            'draft_reason': 'Auto-saved: submission failed (${apiErrorMessage(error)})',
          });
        } catch (_) {}
        _toast('Saved as draft: ${apiErrorMessage(error)}');
      } else {
        _toast(apiErrorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('$label: $value'),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.taskId != null && !_loaded) {
      final detail = ref.watch(taskDetailProvider(widget.taskId!));

      return detail.when(
        data: (task) {
          _prefill(task);

          return _form(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(apiErrorMessage(error))),
      );
    }

    return _form(context);
  }

  Widget _form(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'New request' : 'Edit request'),
        leading: BackButton(onPressed: () => context.go('/tasks')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    decoration:
                        const InputDecoration(labelText: 'Description (max 150 words)'),
                    maxLines: 4,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'A description is required';
                      final words =
                          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

                      return words > 150 ? 'Maximum 150 words (currently $words)' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'ZMW ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => parseZmwToNgwee(value ?? '') == null
                        ? 'Enter a valid amount'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    icon: const Icon(Icons.event),
                    label: Text(
                      _dueDate == null
                          ? 'Pick a due date'
                          : 'Due ${_dueDate!.toIso8601String().substring(0, 10)}',
                    ),
                  ),
                  if (_dueDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'A due date is required to submit',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SegmentedButton<BeneficiaryType>(
                    segments: const [
                      ButtonSegment(value: BeneficiaryType.self, label: Text('For myself')),
                      ButtonSegment(
                        value: BeneficiaryType.other,
                        label: Text('For someone else'),
                      ),
                    ],
                    selected: {_beneficiary},
                    onSelectionChanged: (selection) =>
                        setState(() => _beneficiary = selection.first),
                  ),
                  if (_beneficiary == BeneficiaryType.other) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _beneficiaryName,
                      decoration: const InputDecoration(labelText: 'Beneficiary name'),
                      validator: (value) => _beneficiary == BeneficiaryType.other &&
                              (value == null || value.trim().isEmpty)
                          ? 'Beneficiary name is required'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _busy ? null : _saveDraft,
                          child: const Text('Save as draft'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy || _dueDate == null ? null : _complete,
                          child: const Text('Complete'),
                        ),
                      ),
                    ],
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
