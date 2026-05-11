import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Displays individual budget information with spending progress.
///
/// Shows: rank, category name, allocated/spent amounts, progress bar, percentage.
class BudgetCard extends StatelessWidget {
  /// Create a [BudgetCard].
  const BudgetCard({
    required this.rank,
    required this.categoryName,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.percentage,
    this.categoryColour = 0xFFFF9800,
    this.onEditLimit,
    super.key,
  });

  /// Rank number (1, 2, 3, etc.).
  final int rank;

  /// Name of the budget category (e.g., "Groceries").
  final String categoryName;

  /// Total budget allocated for this category.
  final double allocatedAmount;

  /// Amount already spent in this category.
  final double spentAmount;

  /// Percentage of budget used (0-100+).
  final double percentage;

  /// Color associated with this category (as integer).
  final int categoryColour;

  /// Optional callback to edit this category's budget limit.
  final VoidCallback? onEditLimit;

  @override
  Widget build(BuildContext context) {
    final isOverBudget = percentage > 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(categoryColour),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Category name and amounts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formatCurrency(spentAmount),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? Colors.red : null,
                            ),
                      ),
                      Text(
                        ' / ${formatCurrency(allocatedAmount)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percentage > 100 ? 1.0 : percentage / 100,
                      minHeight: 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? Colors.red : Color(categoryColour),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Percentage and edit action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : null,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit budget limit',
                  onPressed: onEditLimit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
