import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';

/// Base class for all accounts events.
sealed class AccountsEvent {
  const AccountsEvent();
}

/// Triggers the initial account load.
final class AccountsStarted extends AccountsEvent {
  /// Create an [AccountsStarted] event.
  const AccountsStarted();
}

/// Changes the active type filter.
final class AccountsTypeFilterChanged extends AccountsEvent {
  /// Create an [AccountsTypeFilterChanged] event.
  const AccountsTypeFilterChanged(this.type);

  /// The selected type; null means "All".
  final AccountType? type;
}

/// Adds a new account to the list.
final class AccountsAccountAdded extends AccountsEvent {
  /// Create an [AccountsAccountAdded] event.
  const AccountsAccountAdded(this.account);

  /// The account to add.
  final AccountModel account;
}
