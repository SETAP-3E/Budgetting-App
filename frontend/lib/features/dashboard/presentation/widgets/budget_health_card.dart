import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';

/// Dashboard card showing overall and per-category budget progress.
class BudgetHealthCard extends StatelessWidget {
  /// Create a [BudgetHealthCard].
  const BudgetHealthCard({
    required this.summary,
    required this.onManage,
    super.key,
  });

  /// Budget summary for the current month, or null while loading / on error.
  final BudgetSummaryModel? summary;

  /// Called when the "Manage" button is tapped.
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = summary == null || summary!.budgets.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Health',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: onManage,
                  child: const Text('Manage →'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isEmpty)
              _EmptyState()
            else ...[
              _OverallProgressBar(summary: summary!),
              const SizedBox(height: 12),
              ...summary!.budgets.take(3).map(
                    (item) => _CategoryRow(item: item),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 36,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No budgets set for this month',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallProgressBar extends StatelessWidget {
  const _OverallProgressBar({required this.summary});

  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = summary.totalGoal > 0
        ? summary.totalSpent / summary.totalGoal * 100
        : 0.0;
    final colour = budgetHealthColour(pct);
    final progress = summary.totalGoal > 0
        ? (summary.totalSpent / summary.totalGoal).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Overall', style: theme.textTheme.labelSmall),
            Text(
              '${formatCurrency(summary.totalSpent)} '
              '/ ${formatCurrency(summary.totalGoal)}',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colour.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(colour),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final BudgetItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = budgetHealthColour(item.percentage);
    final progress = (item.percentage / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(item.colourValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${item.percentage.toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colour,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: colour.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(colour),
            ),
          ),
        ],
      ),
    );
  }
}
