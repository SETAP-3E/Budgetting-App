import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';

/// Displays an individual category's budget vs spending with a progress bar.
class BudgetCard extends StatelessWidget {
  /// Create a [BudgetCard].
  const BudgetCard({
    required this.rank,
    required this.categoryName,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.percentage,
    this.categoryColour = 0xFF32B5A0,
    this.onEditLimit,
    this.onDelete,
    super.key,
  });

  /// Rank position (1 = highest goal).
  final int rank;

  /// Category display name.
  final String categoryName;

  /// Budget goal for this category.
  final double allocatedAmount;

  /// Amount spent so far.
  final double spentAmount;

  /// Percentage of goal used (0–100+).
  final double percentage;

  /// ARGB colour integer for the category accent.
  final int categoryColour;

  /// Optional callback when the edit icon is tapped.
  final VoidCallback? onEditLimit;

  /// Optional callback when the delete icon is tapped.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final barColour = budgetHealthColour(percentage);
    final isOver = percentage > 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(categoryColour),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        formatCurrency(spentAmount),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isOver ? barColour : null,
                            ),
                      ),
                      Text(
                        ' / ${formatCurrency(allocatedAmount)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor:
                          barColour.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(barColour),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: barColour,
                      ),
                ),
                if (onEditLimit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit limit',
                    onPressed: onEditLimit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    tooltip: 'Delete budget',
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
