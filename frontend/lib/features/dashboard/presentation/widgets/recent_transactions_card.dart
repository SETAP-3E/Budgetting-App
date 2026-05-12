import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';

/// Dashboard card showing the 5 most recent transactions.
class RecentTransactionsCard extends StatelessWidget {
  /// Create a [RecentTransactionsCard].
  const RecentTransactionsCard({
    required this.transactions,
    required this.onSeeAll,
    super.key,
  });

  /// Transactions to display — caller should already slice to ≤5.
  final List<TransactionModel> transactions;

  /// Called when the "See all" button is tapped.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See all →'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (transactions.isEmpty)
              _EmptyState()
            else
              Column(
                children: transactions
                    .map((t) => _TransactionRow(transaction: t))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = transaction;

    final parts = [
      if (t.location != null && t.location!.isNotEmpty) t.location!,
      '${t.date.day} ${_shortMonth(t.date.month)} ${t.date.year}',
    ];
    final subtitle = parts.join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.receipt_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Text(
            formatCurrency(t.amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  static String _shortMonth(int month) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];
}
