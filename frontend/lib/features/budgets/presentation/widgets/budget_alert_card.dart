import 'package:flutter/material.dart';

/// Alert card showing a budget that's close to or over limit.
///
/// Displays: budget name, allocated vs spent amounts, progress bar with warning.
/// Shows in red if budget is exceeded (spent > allocated).
class BudgetAlertCard extends StatelessWidget {
  /// Create a [BudgetAlertCard].
  const BudgetAlertCard({
    required this.categoryName,
    required this.allocatedAmount,
    required this.currentAmount,
    required this.percentage,
    this.categoryColour = 0xFFFF9800,
    super.key,
  });

  /// Name of the budget category (e.g., "Groceries").
  final String categoryName;

  /// Total budget allocated for this category.
  final double allocatedAmount;

  /// Current spending against this budget.
  final double currentAmount;

  /// Percentage spent (0-100+). Values >100 indicate overspend.
  final double percentage;

  /// Color to use for the budget category.
  final int categoryColour;

  @override
  Widget build(BuildContext context) {
    final isOverBudget = percentage > 100;
    final displayPercentage = percentage.toInt().toDouble();
    
    return Card(
      color: isOverBudget ? Colors.red[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOverBudget ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverBudget ? 'Over Budget' : 'Close to Limit',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Amounts row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Allocated',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '£${allocatedAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Spent',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '£${currentAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOverBudget ? Colors.red : Colors.orange
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: displayPercentage > 100 ? 1.0 : displayPercentage / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.red : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Percentage text
            Text(
              '${displayPercentage.toInt()}% of budget used',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOverBudget ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
