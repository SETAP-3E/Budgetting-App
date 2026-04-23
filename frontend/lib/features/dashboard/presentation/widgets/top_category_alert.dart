import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Displays top category with month-over-month spending comparison.
///
/// Shows: category icon (32pt), name, amount (20pt bold), percentage,
/// and comparison indicator (↑/↓/→) with previous month amount.
class TopCategoryAlert extends StatelessWidget {
  /// Create a [TopCategoryAlert].
  const TopCategoryAlert({
    required this.categoryName,
    required this.currentAmount,
    required this.previousAmount,
    required this.percentage,
    this.categoryIcon,
    this.categoryColour,
    this.onTap,
    super.key,
  });

  /// Category name (e.g., "Groceries").
  final String categoryName;

  /// Current period spending for this category.
  final double currentAmount;

  /// Previous period spending for comparison.
  final double previousAmount;

  /// Percentage of total spending.
  final double percentage;

  /// Category icon (e.g., "shopping_bag").
  final IconData? categoryIcon;

  /// Category colour as hex (e.g., 0xFF2E7D32).
  final int? categoryColour;

  /// Callback when card is tapped for drill-down.
  final VoidCallback? onTap;

  /// Determine comparison indicator (↑ more, ↓ less, → same).
  String _getComparisonIndicator() {
    if (currentAmount > previousAmount) {
      return '↑';
    } else if (currentAmount < previousAmount) {
      return '↓';
    } else {
      return '→';
    }
  }

  /// Get comparison text describing the change.
  String _getComparisonText() {
    final difference = (currentAmount - previousAmount).abs();
    if (currentAmount > previousAmount) {
      return '${formatCurrency(difference)} more than last month';
    } else if (currentAmount < previousAmount) {
      return '${formatCurrency(difference)} less than last month';
    } else {
      return 'Same as last month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: categoryColour != null
                    ? Color(categoryColour!)
                    : Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon, name, percentage
              Row(
                children: [
                  // Category icon (32pt)
                  if (categoryIcon != null)
                    Icon(
                      categoryIcon,
                      size: 32,
                      color: categoryColour != null
                          ? Color(categoryColour!)
                          : Theme.of(context).colorScheme.primary,
                    ),
                  if (categoryIcon != null) const SizedBox(width: 12),
                  // Category name and percentage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style:
                              Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of spending',
                          style:
                              Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Current amount (20pt bold)
              Text(
                formatCurrency(currentAmount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Comparison row
              Row(
                children: [
                  // Comparison indicator
                  Text(
                    _getComparisonIndicator(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                        fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Comparison text
                  Expanded(
                    child: Text(
                      _getComparisonText(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
