import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';

/// Alert card shown for the category closest to or over its budget limit.
class BudgetAlertCard extends StatelessWidget {
  /// Create a [BudgetAlertCard].
  const BudgetAlertCard({
    required this.categoryName,
    required this.allocatedAmount,
    required this.currentAmount,
    required this.percentage,
    this.categoryColour = 0xFF32B5A0,
    super.key,
  });

  /// Name of the budget category (e.g. "Groceries").
  final String categoryName;

  /// Total budget allocated for this category.
  final double allocatedAmount;

  /// Current spending against this budget.
  final double currentAmount;

  /// Percentage spent (0–100+). Values > 100 indicate overspend.
  final double percentage;

  /// ARGB colour integer for the category accent.
  final int categoryColour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverBudget = percentage > 100;
    final accentColour = budgetHealthColour(percentage);
    final cardColour = theme.cardTheme.color ?? theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColour,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentColour, width: 4),
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColour,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverBudget ? 'Over Budget' : 'Close to Limit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountColumn(
                label: 'Budget',
                value: formatCurrency(allocatedAmount),
              ),
              _AmountColumn(
                label: 'Spent',
                value: formatCurrency(currentAmount),
                valueColour: accentColour,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor:
                  accentColour.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accentColour),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${percentage.toInt()}% of budget used',
            style: theme.textTheme.labelSmall?.copyWith(
              color: accentColour,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    this.valueColour,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });
  final String label;
  final String value;
  final Color? valueColour;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColour,
                ),
          ),
        ],
      );
}
