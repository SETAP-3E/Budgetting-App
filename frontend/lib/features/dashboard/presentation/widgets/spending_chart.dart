import 'package:flutter/material.dart';

/// Interactive donut/pie chart showing spending by category.
///
/// Supports Simple view (top 3 + Other) and Advanced view (all categories).
/// Displays tooltips on hover/tap and triggers drill-down callbacks.
class SpendingChart extends StatefulWidget {
  /// Create a [SpendingChart].
  const SpendingChart({
    required this.categories,
    required this.isSimpleView,
    this.onCategoryTap,
    this.customColours,
    this.showPercentages = true,
    super.key,
  });

  /// List of categories with name, amount, percentage, colour.
  final List<Map<String, dynamic>> categories;

  /// Whether showing Simple (top 3 + Other) or Advanced (all) view.
  final bool isSimpleView;

  /// Callback when a chart segment is tapped.
  final void Function(String categoryName)? onCategoryTap;

  /// Custom colour override list. If null, uses default warm palette.
  final List<int>? customColours;

  /// Whether to show percentage labels on chart.
  final bool showPercentages;

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  /// Get colour from palette at index.
  /// Used by the PieChart to cycle through the colour palette.
  // ignore: unused_element
  Color _getChartColour(int index) {
    final colours = widget.customColours ??
        const [
          0xFF2E7D32, // Green
          0xFF4DB6AC, // Teal
          0xFFFF9800, // Orange
          0xFFFFC107, // Gold
          0xFF66BB6A, // Light Green
        ];
    return Color(colours[index % colours.length]);
  }

  /// Get the categories to display based on view mode.
  List<Map<String, dynamic>> _getDisplayCategories() {
    if (widget.isSimpleView && widget.categories.length > 3) {
      // Simple: top 3 + Other
      final topThree = widget.categories.sublist(0, 3);
      final otherAmount = widget.categories
          .sublist(3)
          .fold<double>(0, (sum, cat) => sum + (cat['amount'] as double));
      
      return [
        ...topThree,
        {
          'name': 'Other',
          'amount': otherAmount,
          'percentage': (otherAmount /
              widget.categories.fold<double>(
                0,
                (sum, cat) => sum + (cat['amount'] as double),
              )) *
              100,
          'colour': 0xFF757575, // Grey for "Other"
        },
      ];
    }
    // Advanced: all categories
    return widget.categories;
  }

  @override
  Widget build(BuildContext context) {
    final displayCategories = _getDisplayCategories();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TODO(dev): Implement fl_chart PieChart donut rendering
            // - White centre (donut style)
            // - Colour legend from customColours or default palette
            // - Segment labels (14pt white, if >5%)
            // - Percentage labels (12pt outside)
            // - Hover tooltip (dark bg, white text)
            // - Hover scaling (1.05x)
            // - Tap callback to onCategoryTap
            Container(
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Donut Chart - '
                  '${widget.isSimpleView ? "Simple" : "Advanced"} View\n'
                  '${displayCategories.length} categories',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category legend
            ..._buildCategoryLegend(displayCategories, context),
          ],
        ),
      ),
    );
  }

  /// Build legend items for each category.
  List<Widget> _buildCategoryLegend(
    List<Map<String, dynamic>> categories,
    BuildContext context,
  ) {
    return categories
        .map(
          (category) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(category['colour'] as int),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${category['name']} • '
                    '£${(category['amount'] as double).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                if (widget.showPercentages)
                  Text(
                    '${(category['percentage'] as double).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        )
        .toList();
  }
}
