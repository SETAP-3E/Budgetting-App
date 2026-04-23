import 'package:flutter/material.dart';

/// Visual chart showing budget distribution and spending.
///
/// Displays stacked horizontal bars showing allocated vs spent for each category.
class BudgetChart extends StatelessWidget {
  /// Create a [BudgetChart].
  const BudgetChart({
    required this.categories,
    required this.isSimpleView,
    super.key,
  });

  /// List of budget categories with name, allocated, spent, and color.
  final List<Map<String, dynamic>> categories;

  /// Whether to show simplified chart (less detail).
  final bool isSimpleView;

  @override
  Widget build(BuildContext context) {
    final maxAllocated = categories
        .fold<double>(0, (max, c) => c['allocated'] as double > max 
            ? c['allocated'] as double 
            : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget vs Spending',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              final allocated = category['allocated'] as double;
              final spent = category['spent'] as double;
              final name = category['name'] as String;
              final colour = Color(category['colour'] as int);

              final allocatedRatio = allocated / maxAllocated;
              final spentRatio = spent / maxAllocated;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          '£${spent.toStringAsFixed(2)} / £${allocated.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Stacked bar chart
                    Stack(
                      children: [
                        // Allocated bar (background)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: allocatedRatio,
                            minHeight: 8,
                            backgroundColor: colour.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colour.withOpacity(0.4),
                            ),
                          ),
                        ),
                        // Spent bar (foreground)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: spentRatio,
                            minHeight: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              spent > allocated 
                                  ? Colors.red 
                                  : colour,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
