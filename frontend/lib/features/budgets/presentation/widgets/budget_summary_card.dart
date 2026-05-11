import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Displays total budget summary with allocated, spent, and remaining amounts.
///
/// Shows: total budget (36pt bold), month/year, remaining budget,
/// and visual breakdown of allocated vs spent.
class BudgetSummaryCard extends StatelessWidget {
  /// Create a [BudgetSummaryCard].
  const BudgetSummaryCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.month,
    required this.year,
    this.onAddBudget,
    super.key,
  });

  /// Total budget allocated.
  final double totalBudget;

  /// Total amount spent so far.
  final double totalSpent;

  /// Month name (e.g., "March").
  final String month;

  /// Year (e.g., 2026).
  final int year;

  /// Callback when "Add Budget" button is tapped.
  final VoidCallback? onAddBudget;

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - totalSpent;
    final spentPercentage = (totalSpent / totalBudget * 100).clamp(0.0, 100.0);
    final isOverBudget = totalSpent > totalBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total budget amount (36pt bold)
            Text(
              formatCurrency(totalBudget),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            // Month and year subtext
            Text(
              '$month $year',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 16),
            // Budget breakdown row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(totalSpent),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOverBudget ? Colors.red : null,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(remainingBudget),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: remainingBudget < 0 ? Colors.red : Colors.green,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar showing budget usage
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (spentPercentage / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Percentage text
            Text(
              '${spentPercentage.toInt()}% of total budget used',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOverBudget ? Colors.red : null,
              ),
            ),
            if (!isOverBudget)
              const SizedBox(height: 16)
            else
              Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You have exceeded your budget!',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
