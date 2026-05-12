import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';

/// Displays total spending for a period with budget goal progress.
class MetricCard extends StatelessWidget {
  /// Create a [MetricCard].
  const MetricCard({
    required this.totalSpending,
    required this.month,
    required this.year,
    required this.budgetGoal,
    super.key,
  });

  /// Total spending amount to display.
  final double totalSpending;

  /// Month name (e.g., "March"), or empty string for a year view.
  final String month;

  /// Year (e.g., 2026).
  final int year;

  /// Sum of all monthly budget goals. Pass 0.0 when no budgets are set.
  final double budgetGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periodLabel = month.isEmpty ? '$year' : '$month $year';
    final hasBudget = budgetGoal > 0;
    final pct = hasBudget ? (totalSpending / budgetGoal * 100) : 0.0;
    final progressColour = hasBudget
        ? budgetHealthColour(pct)
        : theme.colorScheme.primary;
    final clampedValue =
        hasBudget ? (totalSpending / budgetGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = budgetGoal - totalSpending;
    final remainingLabel = remaining >= 0
        ? '${formatCurrency(remaining)} remaining'
        : '${formatCurrency(remaining.abs())} over budget';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(periodLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              formatCurrency(totalSpending),
              style: theme.textTheme.displayLarge,
            ),
            if (hasBudget) ...[
              const SizedBox(height: 2),
              Text(
                'of ${formatCurrency(budgetGoal)} monthly budget',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: clampedValue,
                  minHeight: 10,
                  backgroundColor: progressColour.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColour),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remainingLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: progressColour,
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}% used',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'No monthly budget set',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
