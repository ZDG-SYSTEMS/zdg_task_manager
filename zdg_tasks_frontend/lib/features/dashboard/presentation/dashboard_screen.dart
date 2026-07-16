import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../../shared/models/budget_position.dart';
import '../../../shared/money.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return dashboard.when(
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _countCard(context, 'Total tasks', data.counts.total, Icons.assignment),
                _countCard(context, 'Pending', data.counts.pending, Icons.hourglass_top),
                _countCard(context, 'In progress', data.counts.inProgress, Icons.sync),
                _countCard(context, 'Assigned', data.counts.assigned, Icons.person_pin),
                _countCard(context, 'Overdue', data.counts.overdue, Icons.warning_amber),
              ],
            ),
            const SizedBox(height: 16),
            if (data.byStatus.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By status', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      for (final entry in data.byStatus.entries)
                        _bar(context, entry.key, entry.value, data.counts.total),
                    ],
                  ),
                ),
              ),
            if (data.monthlyFunded.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash released (last months)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final point in data.monthlyFunded)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              SizedBox(width: 80, child: Text(point.month)),
                              Text(formatZmw(point.fundedTotal ?? 0)),
                              const Spacer(),
                              Text('${point.fundedCount ?? 0} task(s)'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            // Where no budget is set, no budget UI appears at all.
            if (data.budgets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Budget position', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final budget in data.budgets) _budgetCard(context, budget),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(apiErrorMessage(error))),
    );
  }

  Widget _countCard(BuildContext context, String label, int value, IconData icon) {
    return SizedBox(
      width: 168,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.headlineMedium),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, String label, int value, int total) {
    final fraction = total == 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(value: fraction, minHeight: 10),
          ),
          SizedBox(width: 40, child: Text('  $value')),
        ],
      ),
    );
  }

  Widget _budgetCard(BuildContext context, BudgetPosition budget) {
    final spent = budget.amount == 0 ? 0.0 : budget.fundedToDate / budget.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${budget.company.code} - ${budget.department}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('${budget.periodStart} to ${budget.periodEnd}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: spent.clamp(0.0, 1.0), minHeight: 10),
            const SizedBox(height: 4),
            Text(
              '${formatZmw(budget.fundedToDate)} funded of ${formatZmw(budget.amount)} '
              '(${formatZmw(budget.remaining)} remaining)',
            ),
          ],
        ),
      ),
    );
  }
}
