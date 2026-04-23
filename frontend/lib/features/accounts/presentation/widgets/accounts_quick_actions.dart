import 'package:flutter/material.dart';

/// Quick action controls for accounts tasks.
class AccountsQuickActions extends StatelessWidget {
  /// Creates quick action controls.
  const AccountsQuickActions({
    required this.onAddAccount,
    required this.onTransfer,
    required this.onExport,
    super.key,
  });

  /// Triggered when adding an account.
  final VoidCallback onAddAccount;

  /// Triggered when starting a transfer.
  final VoidCallback onTransfer;

  /// Triggered when exporting account data.
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onAddAccount,
          icon: const Icon(Icons.add),
          label: const Text('Add Account'),
        ),
        OutlinedButton.icon(
          onPressed: onTransfer,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Transfer'),
        ),
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.file_download),
          label: const Text('Export'),
        ),
      ],
    );
  }
}
