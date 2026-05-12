import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Horizontal bar chart showing spending by category.
///
/// Matches the layout pattern used on the budgets page — full category names
/// sit above proportional coloured bars, so no labels are ever truncated.
class SpendingBarChart extends StatelessWidget {
  /// Create a [SpendingBarChart].
  const SpendingBarChart({required this.categories, super.key});

  /// Categories with keys: name (String), amount (double),
  /// percentage (double), colour (int). Expected sorted by amount descending.
  final List<Map<String, dynamic>> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final maxAmount = categories.first['amount'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...categories.map(
              (cat) => _CategoryBar(
                name: cat['name'] as String,
                amount: cat['amount'] as double,
                percentage: cat['percentage'] as double,
                colour: Color(cat['colour'] as int),
                maxAmount: maxAmount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.colour,
    required this.maxAmount,
  });

  final String name;
  final double amount;
  final double percentage;
  final Color colour;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name, style: theme.textTheme.labelMedium),
              ),
              const SizedBox(width: 8),
              Text(
                '${formatCurrency(amount)} · '
                '${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: colour.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(colour),
            ),
          ),
        ],
      ),
    );
  }
}
