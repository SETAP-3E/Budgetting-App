import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bar chart showing spending by category for the current month on one account.
class AccountSpendingChart extends StatefulWidget {
  /// Create an [AccountSpendingChart].
  const AccountSpendingChart({
    required this.transactions,
    required this.accentColor,
    super.key,
  });

  /// All transactions for the account (caller filters to current month).
  final List<AccountTransactionItem> transactions;

  /// Accent colour for chart bars — matches the account card colour.
  final Color accentColor;

  @override
  State<AccountSpendingChart> createState() => _AccountSpendingChartState();
}

class _AccountSpendingChartState extends State<AccountSpendingChart> {
  int? _touchedIndex;

  List<MapEntry<String, double>> _grouped() {
    final totals = <String, double>{};
    for (final tx in widget.transactions) {
      totals[tx.categoryName] =
          (totals[tx.categoryName] ?? 0) + tx.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).toList();
  }

  String _label(String name) =>
      name.length > 7 ? '${name.substring(0, 7)}…' : name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _grouped();

    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data.first.value * 1.25;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex = (event is FlTapUpEvent ||
                                event is FlPointerExitEvent)
                            ? null
                            : response?.spot?.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, _, rod, __) {
                        final entry = data[group.x];
                        return BarTooltipItem(
                          '${entry.key}\n£${rod.toY.toStringAsFixed(2)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _label(data[i].key),
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, _) => Text(
                          '£${value.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final isTouched = _touchedIndex == i;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].value,
                          color: isTouched
                              ? widget.accentColor
                              : widget.accentColor.withValues(alpha: 0.75),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
