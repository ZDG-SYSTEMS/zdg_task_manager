import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../shared/money.dart';
import '../data/report_repository.dart';

/// The three report tiers, rendered generically because the field set
/// is registry-driven server-side. Money keys display as ZMW.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  static const _tiers = [
    (path: 'general', label: 'General'),
    (path: 'comparison', label: 'Comparison'),
    (path: 'in-depth', label: 'In-depth'),
  ];

  static const _moneyKeys = {
    'total_requested', 'total_approved', 'total_funded', 'rejected_value',
    'completed_value', 'petty_cash_issued_value', 'petty_cash_accounted',
    'petty_cash_outstanding', 'amount', 'funded_to_date', 'remaining',
    'funded_total', 'current', 'previous', 'variance', 'outstanding',
    'amount_requested', 'amount_approved', 'funded_amount',
  };

  var _tier = 'general';
  var _period = 'monthly';
  DateTime _date = DateTime.now();
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(reportRepositoryProvider).fetch(
          _tier,
          period: _period,
          date: _date.toIso8601String().substring(0, 10),
        );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<String>(
                segments: [
                  for (final tier in _tiers)
                    ButtonSegment(value: tier.path, label: Text(tier.label)),
                ],
                selected: {_tier},
                onSelectionChanged: (selection) {
                  _tier = selection.first;
                  _load();
                },
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ],
                selected: {_period},
                onSelectionChanged: (selection) {
                  _period = selection.first;
                  _load();
                },
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _date = picked;
                    _load();
                  }
                },
                icon: const Icon(Icons.event),
                label: Text(_date.toIso8601String().substring(0, 10)),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(apiErrorMessage(snapshot.error!)));
              }

              final report = snapshot.data ?? const {};

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [_node(context, report, 0)],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Renders arbitrary report structure: maps as label/value sections,
  /// lists as numbered entries, scalars as text.
  Widget _node(BuildContext context, Object? value, int depth, [String? key]) {
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (key != null)
            Padding(
              padding: EdgeInsets.only(top: depth == 1 ? 16 : 8, bottom: 4),
              child: Text(
                key.replaceAll('_', ' '),
                style: depth <= 1
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.titleSmall,
              ),
            ),
          for (final entry in value.entries)
            _entry(context, entry.key.toString(), entry.value, depth + 1),
        ],
      );
    }
    if (value is List) {
      if (value.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('$key: none', style: Theme.of(context).textTheme.bodySmall),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (key != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                '${key.replaceAll('_', ' ')} (${value.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          for (final item in value.take(25))
            Card(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _node(context, item, depth + 1),
              ),
            ),
        ],
      );
    }

    return Text('$value');
  }

  Widget _entry(BuildContext context, String key, Object? value, int depth) {
    if (value is Map || value is List) {
      return Padding(
        padding: EdgeInsets.only(left: depth > 2 ? 8 : 0),
        child: _node(context, value, depth, key),
      );
    }

    var display = '$value';
    if (value is int && _moneyKeys.contains(key)) display = formatZmw(value);
    if (value == null) display = '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 240,
            child: Text(
              key.replaceAll('_', ' '),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(display)),
        ],
      ),
    );
  }
}
