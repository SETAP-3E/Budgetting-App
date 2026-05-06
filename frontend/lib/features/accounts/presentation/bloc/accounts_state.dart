import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:equatable/equatable.dart';

/// Loading status for the accounts list.
enum AccountsStatus {
  /// Not yet started.
  initial,

  /// Fetching data.
  loading,

  /// Data loaded successfully.
  success,

  /// Load failed.
  failure,
}

/// Immutable state for the accounts screen.
class AccountsState extends Equatable {
  /// Create an [AccountsState].
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.visibleAccounts = const [],
    this.selectedType,
    this.errorMessage,
  });

  /// Current loading status.
  final AccountsStatus status;

  /// All accounts (unfiltered).
  final List<AccountModel> accounts;

  /// Accounts filtered by [selectedType] (all accounts when null).
  final List<AccountModel> visibleAccounts;

  /// Active type filter; null means "All".
  final AccountType? selectedType;

  /// Error message when [status] is [AccountsStatus.failure].
  final String? errorMessage;

  /// Returns a copy of this state with the given fields replaced.
  AccountsState copyWith({
    AccountsStatus? status,
    List<AccountModel>? accounts,
    List<AccountModel>? visibleAccounts,
    AccountType? selectedType,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      visibleAccounts: visibleAccounts ?? this.visibleAccounts,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, accounts, visibleAccounts, selectedType, errorMessage];
}
