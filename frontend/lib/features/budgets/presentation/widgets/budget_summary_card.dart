import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Returns the health colour for a given percentage of budget used.
Color budgetHealthColour(double percentage) {
  if (percentage > 100) return const Color(0xFFB71C1C);
  if (percentage >= 90) return const Color(0xFFE65100);
  if (percentage >= 75) return const Color(0xFFFFB300);
  return AppTheme.primaryMint;
}

/// Top-of-screen budget summary with mint header, pace indicator,
/// days remaining, and projected spend.
class BudgetSummaryCard extends StatelessWidget {
  /// Create a [BudgetSummaryCard].
  const BudgetSummaryCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.monthName,
    required this.year,
    required this.month,
    super.key,
  });

  /// Total budget allocated for the period.
  final double totalBudget;

  /// Total amount spent so far.
  final double totalSpent;

  /// Display name for the month (e.g. "May").
  final String monthName;

  /// Calendar year.
  final int year;

  /// Month number 1–12 (used to compute days-in-month and pace).
  final int month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = totalBudget - totalSpent;
    final rawPct =
        totalBudget > 0 ? totalSpent / totalBudget * 100 : 0.0;
    final pct = rawPct.clamp(0.0, 100.0);
    final rawHealth = budgetHealthColour(rawPct);
    final barColour =
        rawHealth == AppTheme.primaryMint ? AppTheme.noteGreen : rawHealth;

    final now = DateTime.now();
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final isCurrentMonth = now.year == year && now.month == month;
    final daysElapsed = isCurrentMonth ? now.day : daysInMonth;
    final daysLeft = isCurrentMonth ? daysInMonth - now.day : 0;
    final expectedSpend = totalBudget * (daysElapsed / daysInMonth);
    final paceRatio =
        expectedSpend > 0 ? totalSpent / expectedSpend : 0.0;
    final projectedSpend =
        daysElapsed > 0 ? (totalSpent / daysElapsed) * daysInMonth : 0.0;

    final (paceLabel, paceColour) = _pace(totalSpent, totalBudget, paceRatio);
    final labelStyle =
        theme.textTheme.labelSmall?.copyWith(color: Colors.white70);
    final overBudget = remaining < 0;
    final spentLabel = '${formatCurrency(totalSpent)} spent  ·  '
        '${formatCurrency(remaining.abs())} '
        '${overBudget ? 'over budget' : 'remaining'}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryMint, AppTheme.darkTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$monthName $year', style: labelStyle),
            const SizedBox(height: 4),
            Text(
              formatCurrency(totalBudget),
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(spentLabel, style: labelStyle),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(barColour),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isCurrentMonth
                        ? '$daysLeft days left · '
                            'Projected ${formatCurrency(projectedSpend)}'
                        : '${pct.toInt()}% of budget used',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _PaceChip(label: paceLabel, colour: paceColour),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static (String, Color) _pace(
    double spent,
    double budget,
    double ratio,
  ) {
    if (spent > budget) {
      return ('Over budget', const Color(0xFFB71C1C));
    }
    if (ratio > 1.1) return ('Over pace', const Color(0xFFFFB300));
    if (ratio >= 0.9) return ('On track', AppTheme.noteGreen);
    return ('Ahead', AppTheme.noteGreen);
  }
}

class _PaceChip extends StatelessWidget {
  const _PaceChip({required this.label, required this.colour});
  final String label;
  final Color colour;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colour.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colour,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
