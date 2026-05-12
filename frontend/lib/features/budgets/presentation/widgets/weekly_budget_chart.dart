import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart showing per-week spending against a weekly budget target.
///
/// Weekly target = [totalGoal] / number-of-weeks-in-month.
class WeeklyBudgetChart extends StatefulWidget {
  /// Create a [WeeklyBudgetChart].
  const WeeklyBudgetChart({
    required this.weeks,
    required this.totalGoal,
    required this.year,
    required this.month,
    super.key,
  });

  /// Per-week spending items from the API.
  final List<WeeklySpendingItem> weeks;

  /// Monthly total goal — divided by week count to get the weekly target line.
  final double totalGoal;

  /// Year being displayed (used to determine days in month).
  final int year;

  /// Month being displayed (1–12).
  final int month;

  @override
  State<WeeklyBudgetChart> createState() => _WeeklyBudgetChartState();
}

class _WeeklyBudgetChartState extends State<WeeklyBudgetChart> {
  int? _touchedIndex;

  static const _overBudget = Color(0xFFB71C1C);
  static const _amber = Color(0xFFFFB300);

  int get _daysInMonth =>
      DateTime(widget.year, widget.month + 1, 0).day;

  int get _numWeeks => (_daysInMonth / 7).ceil();

  double get _weeklyTarget =>
      _numWeeks > 0 ? widget.totalGoal / _numWeeks : 0;

  Color _barColour(int index, double spent) {
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == widget.year && now.month == widget.month;
    final currentWeek =
        isCurrentMonth ? ((now.day - 1) ~/ 7) + 1 : -1;

    if (index + 1 == currentWeek) return AppTheme.darkTeal;
    if (spent > _weeklyTarget) return _overBudget;
    return AppTheme.primaryMint;
  }

  @override
  Widget build(BuildContext context) {
    final hasSpending = widget.weeks.any((w) => w.spent > 0);
    if (widget.weeks.isEmpty || (!hasSpending && widget.totalGoal <= 0)) {
      return const SizedBox.shrink();
    }
    final showTarget = widget.totalGoal > 0;

    final candidates = [
      ...widget.weeks.map((w) => w.spent),
      if (showTarget) _weeklyTarget,
    ];
    final maxY =
        candidates.reduce((a, b) => a > b ? a : b) * 1.25;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Weekly spending',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (showTarget) ...[
                  const SizedBox(width: 8),
                  Container(width: 24, height: 2, color: _amber),
                  const SizedBox(width: 4),
                  Text(
                    'target',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex =
                            (event is FlTapUpEvent || event is FlPanEndEvent)
                                ? null
                                : response?.spot?.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final week = widget.weeks[groupIndex];
                        final monthName = _shortMonth(widget.month);
                        return BarTooltipItem(
                          'Wk ${week.weekNum} '
                          '(${week.startDay}–${week.endDay} $monthName)\n'
                          'Spent: ${formatCurrency(week.spent)}'
                          '${showTarget
                              ? '\nTarget: ${formatCurrency(_weeklyTarget)}'
                              : ''}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Wk ${value.toInt() + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            formatCurrency(value),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: showTarget
                      ? ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: _weeklyTarget,
                              color: _amber,
                              dashArray: [6, 4],
                            ),
                          ],
                        )
                      : const ExtraLinesData(),
                  barGroups: widget.weeks.asMap().entries.map((entry) {
                    final i = entry.key;
                    final week = entry.value;
                    final isTouched = _touchedIndex == i;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: week.spent,
                          color: _barColour(i, week.spent),
                          width: isTouched ? 20 : 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortMonth(int month) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][month];
}
