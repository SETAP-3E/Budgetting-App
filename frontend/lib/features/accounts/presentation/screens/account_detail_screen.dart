import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:flutter/material.dart';

/// Full-screen view for a single account.
class AccountDetailScreen extends StatelessWidget {
  /// Create an [AccountDetailScreen].
  const AccountDetailScreen({required this.account, super.key});

  /// The account to display.
  final AccountModel account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverBudget = account.budgetUsageRatio > 1.0;
    final isLowBalance = account.balance < 1000;

    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(account: account, theme: theme),
            const SizedBox(height: 16),
            _StatRow(account: account),
            const SizedBox(height: 16),
            _BudgetProgress(account: account, theme: theme),
            if (isOverBudget || isLowBalance) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  if (isOverBudget)
                    Chip(
                      label: const Text('Over budget'),
                      backgroundColor:
                          Colors.red.withAlpha((0.15 * 255).round()),
                      side: const BorderSide(color: Colors.red),
                      labelStyle: const TextStyle(color: Colors.red),
                    ),
                  if (isLowBalance)
                    Chip(
                      label: const Text('Low balance'),
                      backgroundColor:
                          Colors.amber.withAlpha((0.15 * 255).round()),
                      side: const BorderSide(color: Colors.amber),
                      labelStyle: const TextStyle(color: Colors.amber),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(activeIndex: 1),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.account, required this.theme});

  final AccountModel account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  account.accentColor.withAlpha((0.2 * 255).round()),
              child: Icon(account.type.icon, color: account.accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(account.balance),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    account.type.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.6 * 255).round(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.account});

  final AccountModel account;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Monthly Budget',
            value: formatCurrency(account.monthlyBudget),
          ),
        ),
        Expanded(
          child: _StatTile(
            label: 'Spent This Month',
            value: formatCurrency(account.monthlySpent),
          ),
        ),
        Expanded(
          child: _StatTile(
            label: 'Remaining',
            value: formatCurrency(account.remainingBudget),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.6 * 255).round(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.account, required this.theme});

  final AccountModel account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ratio = account.budgetUsageRatio.clamp(0.0, 1.0);
    final percentage = (account.budgetUsageRatio * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget Usage', style: theme.textTheme.titleSmall),
                Text(
                  '$percentage%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: account.budgetUsageRatio > 1.0
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio,
              backgroundColor:
                  theme.colorScheme.onSurface.withAlpha((0.1 * 255).round()),
              color: account.budgetUsageRatio > 1.0
                  ? Colors.red
                  : account.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
