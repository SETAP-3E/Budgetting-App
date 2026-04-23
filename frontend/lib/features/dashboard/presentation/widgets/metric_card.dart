import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Displays total spending for a period with optional goal progress.
///
/// Shows: total amount (36pt bold), month/year, optional progress bar,
/// and action button ("Add Spending" if no goal, or goal progress if exists).
class MetricCard extends StatelessWidget {
  /// Create a [MetricCard].
  const MetricCard({
    required this.totalSpending,
    required this.month,
    required this.year,
    this.goalAmount,
    this.onAddSpending,
    super.key,
  });

  /// Total spending amount to display (e.g., 2456.32).
  final double totalSpending;

  /// Month name (e.g., "March").
  final String month;

  /// Year (e.g., 2026).
  final int year;

  /// Optional goal amount. If null, shows "Add Spending" button instead.
  final double? goalAmount;

  /// Callback when "Add Spending" button is tapped (if no goal exists).
  final VoidCallback? onAddSpending;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total spending amount (36pt bold)
            Text(
              formatCurrency(totalSpending),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            // Month and year subtext
            Text(
              '$month $year',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 16),
            // Progress bar (if goal set)
            if (goalAmount != null) _buildGoalProgress(context),
            if (goalAmount != null) const SizedBox(height: 12),
            // Always show Add Spending button
            _buildAddSpendingButton(context),
          ],
        ),
      ),
    );
  }

  /// Build goal progress indicator and message.
  Widget _buildGoalProgress(BuildContext context) {
    final progressPercent = (totalSpending / goalAmount!) * 100;
    final isOnTrack = totalSpending <= goalAmount!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercent > 100 ? 1.0 : progressPercent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isOnTrack
                  ? Theme.of(context).colorScheme.primary
                  : Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Progress message
        Text(
          isOnTrack
              ? "You're on track toward your goal"
              : "You've exceeded your goal",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isOnTrack ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Build "Add Spending" action button.
  Widget _buildAddSpendingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAddSpending,
        child: const Text('Add Spending'),
      ),
    );
  }
}
