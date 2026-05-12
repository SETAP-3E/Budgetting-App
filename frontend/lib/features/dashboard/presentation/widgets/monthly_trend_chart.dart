import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart showing total spending for each of the last [monthCount] months.
class MonthlyTrendChart extends StatefulWidget {
  /// Create a [MonthlyTrendChart].
  const MonthlyTrendChart({
    required this.transactions,
    this.monthCount = 6,
    super.key,
  });

  /// All transactions to aggregate — filtered internally by date.
  final List<TransactionModel> transactions;

  /// How many months to display (default 6).
  final int monthCount;

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  int? _touchedIndex;

  List<({int year, int month, double total})> get _months {
    final now = DateTime.now();
    final result = <({int year, int month, double total})>[];
    for (var i = widget.monthCount - 1; i >= 0; i--) {
      var month = now.month - i;
      var year = now.year;
      while (month < 1) {
        month += 12;
        year--;
      }
      final total = widget.transactions
          .where((t) => t.date.year == year && t.date.month == month)
          .fold<double>(0, (sum, t) => sum + t.amount);
      result.add((year: year, month: month, total: total));
    }
    return result;
  }

  static const _shortMonths = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final months = _months;
    final hasData = months.any((m) => m.total > 0);
    if (!hasData) return const SizedBox.shrink();

    final maxY = months.map((m) => m.total).reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly spending',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.25,
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
                      getTooltipItem: (group, _, rod, __) {
                        final m = months[group.x];
                        return BarTooltipItem(
                          '${_shortMonths[m.month]} ${m.year}\n'
                          '${formatCurrency(m.total)}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final m = months[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _shortMonths[m.month],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontSize: 11),
                            ),
                          );
                        },
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
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: months.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final isCurrent =
                        m.year == now.year && m.month == now.month;
                    final isTouched = _touchedIndex == i;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: m.total,
                          color: isCurrent
                              ? AppTheme.darkTeal
                              : AppTheme.primaryMint,
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
}
