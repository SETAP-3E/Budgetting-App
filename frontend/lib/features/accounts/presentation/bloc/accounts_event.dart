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

/// Triggers a re-fetch of accounts from the API (e.g. after adding one).
final class AccountsRefreshRequested extends AccountsEvent {
  /// Create an [AccountsRefreshRequested] event.
  const AccountsRefreshRequested();
}

/// Changes the active type filter.
final class AccountsTypeFilterChanged extends AccountsEvent {
  /// Create an [AccountsTypeFilterChanged] event.
  const AccountsTypeFilterChanged(this.type);

  /// The selected type; null means "All".
  final AccountType? type;
}
