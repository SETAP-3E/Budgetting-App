import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:flutter/material.dart';

/// Row-style card used in the accounts list.
class AccountListCard extends StatelessWidget {
  /// Creates an account list card.
  const AccountListCard({
    required this.account,
    required this.balanceText,
    required this.remainingText,
    required this.onTap,
    super.key,
  });

  /// Account data to display.
  final AccountModel account;

  /// Formatted account balance.
  final String balanceText;

  /// Formatted remaining budget text.
  final String remainingText;

  /// Callback triggered when the card is selected.
  final VoidCallback onTap;

  Color _weeklyColor(double ratio) {
    if (ratio > 1.0) return const Color(0xFFB71C1C);
    if (ratio >= 0.9) return const Color(0xFFE65100);
    if (ratio >= 0.75) return const Color(0xFFFFB300);
    return AppTheme.primaryMint;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthlyUsage = account.budgetUsageRatio.clamp(0, 1).toDouble();
    final hasWeeklyTarget = account.weeklyTarget > 0;
    final weeklyRatio = account.weeklyUsageRatio;
    final weeklyUsage = weeklyRatio.clamp(0, 1).toDouble();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: account.accentColor.withValues(alpha: 0.2),
                    child: Icon(account.type.icon, color: account.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.type.label,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    balanceText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: monthlyUsage,
                        backgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(remainingText, style: theme.textTheme.labelSmall),
                ],
              ),
              if (hasWeeklyTarget) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: weeklyUsage,
                          color: _weeklyColor(weeklyRatio),
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Wk: £${account.weeklySpent.toStringAsFixed(0)}'
                      ' / £${account.weeklyTarget.toStringAsFixed(0)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _weeklyColor(weeklyRatio),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
