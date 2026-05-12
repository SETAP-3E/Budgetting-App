import 'package:flutter/material.dart';

/// Row of quick-action buttons for the Accounts screen.
class AccountsQuickActions extends StatelessWidget {
  /// Create an [AccountsQuickActions].
  const AccountsQuickActions({
    required this.onAddAccount,
    required this.onExport,
    super.key,
  });

  /// Called when the user taps Add Account.
  final VoidCallback onAddAccount;

  /// Called when the user taps Export.
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddAccount,
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export'),
          ),
        ),
      ],
    );
  }
}
