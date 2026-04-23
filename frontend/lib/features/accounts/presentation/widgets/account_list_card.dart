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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usage = account.budgetUsageRatio.clamp(0, 1).toDouble();

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
                        value: usage,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(remainingText, style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
