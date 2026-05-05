import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';

/// Base class for all transaction list events.
sealed class TransactionsEvent {
  const TransactionsEvent();
}

/// Triggers the initial load of transactions.
final class TransactionsStarted extends TransactionsEvent {
  /// Create a [TransactionsStarted].
  const TransactionsStarted();
}

/// Re-fetches transactions from the API (pull-to-refresh).
final class TransactionsRefreshRequested extends TransactionsEvent {
  /// Create a [TransactionsRefreshRequested].
  const TransactionsRefreshRequested();
}

/// Updates the search query and re-applies filtering.
final class TransactionsSearchChanged extends TransactionsEvent {
  /// Create a [TransactionsSearchChanged].
  const TransactionsSearchChanged(this.query);

  /// The new search query string.
  final String query;
}

/// Changes the active sort option.
final class TransactionsSortChanged extends TransactionsEvent {
  /// Create a [TransactionsSortChanged].
  const TransactionsSortChanged(this.sort);

  /// The sort option to apply.
  final SortOption sort;
}

/// Applies a new set of filters.
final class TransactionsFilterChanged extends TransactionsEvent {
  /// Create a [TransactionsFilterChanged].
  const TransactionsFilterChanged(this.filter);

  /// The filter to apply.
  final TransactionFilter filter;
}

/// Clears all active filters.
final class TransactionsFilterCleared extends TransactionsEvent {
  /// Create a [TransactionsFilterCleared].
  const TransactionsFilterCleared();
}

/// Moves to a different page in the paginated list.
final class TransactionsPageChanged extends TransactionsEvent {
  /// Create a [TransactionsPageChanged].
  const TransactionsPageChanged(this.page);

  /// Zero-indexed page number to navigate to.
  final int page;
}
