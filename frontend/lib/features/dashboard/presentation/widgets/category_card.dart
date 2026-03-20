import 'package:flutter/material.dart';

/// List item card displaying a category's rank, spending, and percentage.
///
/// Shows ranked position (1-n), category icon, name, amount, percentage,
/// and a visual bar indicating spending contribution. Supports tap callbacks
/// for drill-down navigation.
class CategoryCard extends StatelessWidget {
  /// Create a [CategoryCard].
  const CategoryCard({
    required this.rank,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    this.categoryIcon,
    this.categoryColour,
    this.onTap,
    super.key,
  });

  /// Rank position (1, 2, 3, etc.).
  final int rank;

  /// Category name (e.g., "Groceries", "Utilities").
  final String categoryName;

  /// Spending amount in GBP pounds.
  final double amount;

  /// Percentage of total spending (0-100).
  final double percentage;

  /// Optional category icon (IconData).
  final IconData? categoryIcon;

  /// Optional category colour as ARGB hex int (0xFFRRGGBB).
  final int? categoryColour;

  /// Optional callback when card is tapped.
  final VoidCallback? onTap;

  /// Get the display colour for the category.
  /// Returns category colour or theme primary colour.
  Color _getCategoryColour(BuildContext context) {
    if (categoryColour == null) {
      return Theme.of(context).primaryColor;
    }
    return Color(categoryColour!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
      // ignore: avoid_redundant_argument_values
      // ignore: avoid_redundant_argument_values
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Row: rank badge, icon, name, amount
              Row(
                children: [
                  // Rank badge (28dp circle)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icon + name column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + name row
                        Row(
                          children: [
                            if (categoryIcon != null)
                              Icon(
                                categoryIcon,
                                size: 24,
                                color: _getCategoryColour(context),
                              ),
                            if (categoryIcon != null)
                              const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                categoryName,
                                style: Theme.of(context)
                                    .textTheme.labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Amount + percentage row
                        Row(
                          children: [
                            Text(
                              '£${amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context)
                                  .textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // TODO(dev): Implement visual spending bar
              // (4dp height, category colour)
              // Shows percentage of total spending as a linear progress bar
              // Use ClipRRect for rounded corners on progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 4,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 80) *
                          (percentage / 100),
                      height: 4,
                      color: _getCategoryColour(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
