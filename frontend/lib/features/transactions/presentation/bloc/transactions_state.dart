import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

/// Number of transactions shown per page.
const int kTransactionsPageSize = 10;

/// Loading status for the transactions list.
enum TransactionsStatus {
  /// Not yet started.
  initial,

  /// Fetching data from the API.
  loading,

  /// Data loaded successfully.
  success,

  /// API request failed.
  failure,
}

/// Available sort orders for the transactions list.
enum SortOption {
  /// Most recent transactions first.
  dateNewest,

  /// Oldest transactions first.
  dateOldest,

  /// Highest amount first.
  amountHighest,

  /// Lowest amount first.
  amountLowest,

  /// Category name A → Z.
  categoryAZ,

  /// Category name Z → A.
  categoryZA,
}

/// Criteria used to narrow the transactions list.
class TransactionFilter extends Equatable {
  /// Create a [TransactionFilter].
  const TransactionFilter({
    this.dateFrom,
    this.dateTo,
    this.categoryQuery,
    this.minAmount,
    this.maxAmount,
  });

  /// Only include transactions on or after this date.
  final DateTime? dateFrom;

  /// Only include transactions on or before this date.
  final DateTime? dateTo;

  /// Case-insensitive substring match against category name.
  final String? categoryQuery;

  /// Minimum transaction amount (inclusive).
  final double? minAmount;

  /// Maximum transaction amount (inclusive).
  final double? maxAmount;

  /// Returns true when no filter criteria are set.
  bool get isEmpty =>
      dateFrom == null &&
      dateTo == null &&
      (categoryQuery == null || categoryQuery!.isEmpty) &&
      minAmount == null &&
      maxAmount == null;

  /// Returns a copy of this filter with the given fields replaced.
  TransactionFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? categoryQuery,
    double? minAmount,
    double? maxAmount,
  }) {
    return TransactionFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      categoryQuery: categoryQuery ?? this.categoryQuery,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }

  @override
  List<Object?> get props =>
      [dateFrom, dateTo, categoryQuery, minAmount, maxAmount];
}

/// Immutable state for the transactions list screen.
class TransactionsState extends Equatable {
  /// Create a [TransactionsState].
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.allTransactions = const [],
    this.pageTransactions = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalFiltered = 0,
    this.searchQuery = '',
    this.sortOption = SortOption.dateNewest,
    this.filter = const TransactionFilter(),
    this.errorMessage,
  });

  /// Current loading status.
  final TransactionsStatus status;

  /// All transactions fetched from the API (unfiltered).
  final List<TransactionModel> allTransactions;

  /// The slice of filtered+sorted transactions for the current page.
  final List<TransactionModel> pageTransactions;

  /// Zero-indexed current page number.
  final int currentPage;

  /// Total number of pages given the current filter.
  final int totalPages;

  /// Total number of transactions matching the current search + filter.
  final int totalFiltered;

  /// Active search query (matched against category name and location).
  final String searchQuery;

  /// Active sort order.
  final SortOption sortOption;

  /// Active filter criteria.
  final TransactionFilter filter;

  /// Error message when [status] is [TransactionsStatus.failure].
  final String? errorMessage;

  /// Returns a copy of this state with the given fields replaced.
  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionModel>? allTransactions,
    List<TransactionModel>? pageTransactions,
    int? currentPage,
    int? totalPages,
    int? totalFiltered,
    String? searchQuery,
    SortOption? sortOption,
    TransactionFilter? filter,
    String? errorMessage,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      allTransactions: allTransactions ?? this.allTransactions,
      pageTransactions: pageTransactions ?? this.pageTransactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalFiltered: totalFiltered ?? this.totalFiltered,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTransactions,
        pageTransactions,
        currentPage,
        totalPages,
        totalFiltered,
        searchQuery,
        sortOption,
        filter,
        errorMessage,
      ];
}
