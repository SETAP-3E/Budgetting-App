import 'dart:math';

import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
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
  final _pieKey = GlobalKey();

  static const double _innerRadius = 55;
  static const double _outerRadius = 143;

  List<PieChartSectionData> _buildSections(double totalAllocated) {
    return List.generate(widget.categories.length, (index) {
      final c = widget.categories[index];
      final allocated = c['allocated'] as double;
      final isTouched = _touchedIndex == index;
      final percentage =
          totalAllocated > 0 ? allocated / totalAllocated * 100 : 0.0;

      return PieChartSectionData(
        color: Color(c['colour'] as int),
        value: allocated,
        radius: isTouched ? 85 : 75,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      );
    });
  }

  void _handleTap(TapUpDetails details) {
    final box = _pieKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance < _innerRadius || distance > _outerRadius) {
      setState(() => _touchedIndex = null);
      return;
    }

    final total = widget.categories.fold<double>(
      0,
      (s, c) => s + (c['allocated'] as double),
    );
    if (total <= 0) return;

    var angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    double cumulative = 0;
    for (var i = 0; i < widget.categories.length; i++) {
      final slice =
          (widget.categories[i]['allocated'] as double) / total * 2 * pi;
      if (angle < cumulative + slice) {
        setState(() => _touchedIndex = _touchedIndex == i ? null : i);
        return;
      }
      cumulative += slice;
    }

    setState(() => _touchedIndex = null);
  }

  Widget _buildCenterTooltip() {
    final c = widget.categories[_touchedIndex!];
    final name = c['name'] as String;
    final spent = c['spent'] as double;
    final allocated = c['allocated'] as double;
    final usedPct = allocated > 0 ? spent / allocated * 100 : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          '${formatCurrency(spent)} / ${formatCurrency(allocated)}',
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
        Text(
          '${usedPct.toStringAsFixed(0)}% used',
          style: TextStyle(
            fontSize: 11,
            color: budgetHealthColour(usedPct),
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
              GestureDetector(
                onTapUp: _handleTap,
                child: SizedBox(
                  key: _pieKey,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: _innerRadius,
                          pieTouchData: PieTouchData(enabled: false),
                          sections: _buildSections(totalAllocated),
                        ),
                      ),
                      if (_touchedIndex != null)
                        IgnorePointer(child: _buildCenterTooltip()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: widget.categories.map((category) {
                  final allocated = category['allocated'] as double;
                  final name = category['name'] as String;
                  final colour = Color(category['colour'] as int);
                  final percentage = totalAllocated > 0
                      ? allocated / totalAllocated * 100
                      : 0.0;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colour,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$name • ${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }).toList(),
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
                          '${formatCurrency(spent)} / ${formatCurrency(allocated)}',
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
                              budgetHealthColour(
                                allocated > 0 ? spent / allocated * 100 : 0,
                              ),
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
