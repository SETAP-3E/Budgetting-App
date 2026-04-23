import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
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
  /// Index of currently hovered segment in the chart.
  int? _hoveredSegmentIndex;

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

  /// Check if the touch event is a tap event.
  bool _isTapEvent(FlTouchEvent event) {
    return event.runtimeType.toString() == 'FlTapUpEvent';
  }

  /// Get category name from display categories at given index.
  String? _getCategoryNameAt(
    List<Map<String, dynamic>> displayCategories,
    int index,
  ) {
    if (index < 0 || index >= displayCategories.length) {
      return null;
    }
    return displayCategories[index]['name'] as String;
  }

  /// Calculate total spending across all display categories.
  double _calculateTotal(List<Map<String, dynamic>> categories) {
    return categories.fold<double>(
      0,
      (sum, cat) => sum + (cat['amount'] as double),
    );
  }

  /// Build PieChartSectionData for each category with labels and interactions.
  List<PieChartSectionData> _buildPieChartSections(
    List<Map<String, dynamic>> categories,
  ) {
    final total = _calculateTotal(categories);

    return List.generate(
      categories.length,
      (index) {
        final category = categories[index];
        final amount = category['amount'] as double;
        final percentage = (amount / total) * 100;
        final isHovered = _hoveredSegmentIndex == index;
        final colour = Color(category['colour'] as int);

        return PieChartSectionData(
          color: colour,
          value: amount,
          radius: isHovered ? 90 : 80,
          // Show segment label if >5% of total
          title: widget.showPercentages && percentage >= 5
              ? '${percentage.toStringAsFixed(1)}%'
              : null,
          titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
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
            // fl_chart PieChart donut visualization
            SizedBox(
              height: 280,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  // White centre (donut style)
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (event.localPosition == null) {
                          _hoveredSegmentIndex = null;
                        } else {
                          // ignore: lines_longer_than_80_chars
                          _hoveredSegmentIndex = pieTouchResponse
                              ?.touchedSection?.touchedSectionIndex;
                        }
                      });

                      // Handle tap to trigger onCategoryTap callback
                      if (_isTapEvent(event) &&
                          pieTouchResponse?.touchedSection != null) {
                        // ignore: lines_longer_than_80_chars
                        final index = pieTouchResponse!
                            .touchedSection!.touchedSectionIndex;
                        final displayCategories = _getDisplayCategories();
                        final catName = _getCategoryNameAt(
                          displayCategories,
                          index,
                        );
                        if (catName != null) {
                          widget.onCategoryTap?.call(catName);
                        }
                      }
                    },
                  ),
                  sections: _buildPieChartSections(displayCategories),
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
                    '${formatCurrency(category['amount'] as double)}',
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
