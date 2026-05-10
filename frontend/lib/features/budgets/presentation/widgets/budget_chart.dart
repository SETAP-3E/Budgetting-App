import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Visual chart showing budget distribution and spending.
///
/// Displays a donut pie chart in standard view and stacked horizontal bars
/// in edit view. Tapping a pie segment shows a centre tooltip.
class BudgetChart extends StatefulWidget {
  /// Create a [BudgetChart].
  const BudgetChart({
    required this.categories,
    required this.isSimpleView,
    super.key,
  });

  /// List of budget categories with name, allocated, spent, and colour.
  final List<Map<String, dynamic>> categories;

  /// Whether to show the pie chart (true) or stacked bars (false).
  final bool isSimpleView;

  @override
  State<BudgetChart> createState() => _BudgetChartState();
}

class _BudgetChartState extends State<BudgetChart> {
  int? _touchedIndex;

  List<PieChartSectionData> _buildSections(double totalAllocated) {
    return List.generate(widget.categories.length, (index) {
      final c = widget.categories[index];
      final allocated = c['allocated'] as double;
      final isHovered = _touchedIndex == index;
      final percentage =
          totalAllocated > 0 ? allocated / totalAllocated * 100 : 0.0;

      return PieChartSectionData(
        color: Color(c['colour'] as int),
        value: allocated,
        radius: isHovered ? 85 : 75,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      );
    });
  }

  Widget _buildCenterTooltip() {
    final c = widget.categories[_touchedIndex!];
    final name = c['name'] as String;
    final spent = c['spent'] as double;
    final allocated = c['allocated'] as double;
    final usedPct = allocated > 0 ? spent / allocated * 100 : 0.0;
    final isOverBudget = spent > allocated;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          '£${spent.toStringAsFixed(2)} / £${allocated.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
        Text(
          '${usedPct.toStringAsFixed(0)}% used',
          style: TextStyle(
            fontSize: 11,
            color: isOverBudget
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSimpleView) {
      final totalAllocated = widget.categories.fold<double>(
        0,
        (sum, c) => sum + (c['allocated'] as double),
      );

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget allocation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              centerSpaceRadius: 55,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    _touchedIndex =
                                        event.isInterestedForInteractions
                                            ? response?.touchedSection
                                                ?.touchedSectionIndex
                                            : null;
                                  });
                                },
                              ),
                              sections: _buildSections(totalAllocated),
                            ),
                          ),
                          if (_touchedIndex != null) _buildCenterTooltip(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.categories.map((category) {
                        final allocated = category['allocated'] as double;
                        final name = category['name'] as String;
                        final colour = Color(category['colour'] as int);
                        final percentage = totalAllocated > 0
                            ? allocated / totalAllocated * 100
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colour,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$name • ${percentage.toStringAsFixed(1)}%',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final maxAllocated = widget.categories.fold<double>(
      0,
      (max, c) =>
          c['allocated'] as double > max ? c['allocated'] as double : max,
    );

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
            ...widget.categories.map((category) {
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
                          '£${spent.toStringAsFixed(2)} / '
                          '£${allocated.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: allocatedRatio,
                            minHeight: 8,
                            backgroundColor: colour.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colour.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: spentRatio,
                            minHeight: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              spent > allocated ? Colors.red : colour,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
