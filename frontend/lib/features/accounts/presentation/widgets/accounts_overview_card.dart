import 'package:flutter/material.dart';

/// High-level account summary card.
class AccountsOverviewCard extends StatelessWidget {
  /// Creates an overview card.
  const AccountsOverviewCard({
    required this.totalBalance,
    required this.activeAccounts,
    required this.lowBalanceCount,
    required this.currencyText,
    super.key,
  });

  /// Sum of all account balances.
  final double totalBalance;

  /// Number of currently active accounts.
  final int activeAccounts;

  /// Number of accounts considered low balance.
  final int lowBalanceCount;

  /// Formatted currency text for the total.
  final String currencyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              currencyText,
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(text: '$activeAccounts active accounts'),
                _Pill(text: '$lowBalanceCount need attention'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
