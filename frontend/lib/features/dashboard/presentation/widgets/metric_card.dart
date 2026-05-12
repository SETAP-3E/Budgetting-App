import 'package:budgetting_frontend/core/theme/app_theme.dart';
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
    this.previousSpending,
    this.useGradient = false,
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

  /// Previous period's total spending — used to compute % change badge.
  /// Pass null to hide the badge.
  final double? previousSpending;

  /// When true, renders a mint-to-dark-teal gradient background with
  /// white text.

  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periodLabel = month.isEmpty ? '$year' : '$month $year';
    final hasBudget = budgetGoal > 0;
    final pct = hasBudget ? (totalSpending / budgetGoal * 100) : 0.0;
    final healthColour = hasBudget
        ? budgetHealthColour(pct)
        : theme.colorScheme.primary;
    final progressColour = useGradient
        ? (pct >= 100 ? Colors.redAccent : AppTheme.noteGreen)
        : healthColour;
    final clampedValue =
        hasBudget ? (totalSpending / budgetGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = budgetGoal - totalSpending;
    final remainingLabel = remaining >= 0
        ? '${formatCurrency(remaining)} remaining'
        : '${formatCurrency(remaining.abs())} over budget';

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: useGradient ? Colors.white70 : null,
    );

    final prev = previousSpending;
    final changePct =
        (prev != null && prev > 0) ? (totalSpending - prev) / prev * 100 : null;
    final isIncrease = changePct != null && changePct >= 0;
    final changeColour = useGradient
        ? Colors.white70
        : (isIncrease ? Colors.redAccent : Colors.green);
    final changeText = changePct != null
        ? '${isIncrease ? '↑' : '↓'} '
            '${changePct.abs().toStringAsFixed(0)}% from last month'
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: useGradient
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryMint, AppTheme.darkTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(periodLabel, style: labelStyle),
            const SizedBox(height: 4),
            Text(
              formatCurrency(totalSpending),
              style: theme.textTheme.displayLarge?.copyWith(
                color: useGradient ? Colors.white : null,
              ),
            ),
            if (changeText != null) ...[
              const SizedBox(height: 4),
              Text(
                changeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: changeColour,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (hasBudget) ...[
              const SizedBox(height: 2),
              Text(
                'of ${formatCurrency(budgetGoal)} monthly budget',
                style: labelStyle,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: clampedValue,
                  minHeight: 10,
                  backgroundColor: useGradient
                      ? Colors.white24
                      : progressColour.withValues(alpha: 0.15),
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
                      color: useGradient ? Colors.white : progressColour,
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}% used',
                    style: labelStyle,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'No monthly budget set',
                style: labelStyle?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
