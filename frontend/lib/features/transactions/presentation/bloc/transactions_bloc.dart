import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the full lifecycle of the transactions list:
/// fetching, searching, sorting, filtering, and pagination.
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  /// Create a [TransactionsBloc].
  TransactionsBloc({required TransactionsApiClient apiClient})
      : _apiClient = apiClient,
        super(const TransactionsState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionsRefreshRequested>(_onRefreshRequested);
    on<TransactionsSearchChanged>(_onSearchChanged);
    on<TransactionsSortChanged>(_onSortChanged);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<TransactionsFilterCleared>(_onFilterCleared);
    on<TransactionsPageChanged>(_onPageChanged);
  }

  final TransactionsApiClient _apiClient;

  Future<void> _onStarted(
    TransactionsStarted event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshRequested(
    TransactionsRefreshRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<TransactionsState> emit) async {
    try {
      final all = await _apiClient.getTransactions();
      final derived = _derive(
        all: all,
        query: state.searchQuery,
        sort: state.sortOption,
        filter: state.filter,
        page: 0,
      );
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          allTransactions: all,
          pageTransactions: derived.page,
          currentPage: 0,
          totalPages: derived.totalPages,
          totalFiltered: derived.totalFiltered,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: 'Could not load transactions. Is the server running?',
        ),
      );
    }
  }

  void _onSearchChanged(
    TransactionsSearchChanged event,
    Emitter<TransactionsState> emit,
  ) {
    final derived = _derive(
      all: state.allTransactions,
      query: event.query,
      sort: state.sortOption,
      filter: state.filter,
      page: 0,
    );
    emit(
      state.copyWith(
        searchQuery: event.query,
        pageTransactions: derived.page,
        currentPage: 0,
        totalPages: derived.totalPages,
        totalFiltered: derived.totalFiltered,
      ),
    );
  }

  void _onSortChanged(
    TransactionsSortChanged event,
    Emitter<TransactionsState> emit,
  ) {
    final clampedPage = state.totalPages == 0
        ? 0
        : state.currentPage.clamp(0, state.totalPages - 1);
    final derived = _derive(
      all: state.allTransactions,
      query: state.searchQuery,
      sort: event.sort,
      filter: state.filter,
      page: clampedPage,
    );
    emit(
      state.copyWith(
        sortOption: event.sort,
        pageTransactions: derived.page,
        currentPage: derived.actualPage,
        totalPages: derived.totalPages,
        totalFiltered: derived.totalFiltered,
      ),
    );
  }

  void _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) {
    final derived = _derive(
      all: state.allTransactions,
      query: state.searchQuery,
      sort: state.sortOption,
      filter: event.filter,
      page: 0,
    );
    emit(
      state.copyWith(
        filter: event.filter,
        pageTransactions: derived.page,
        currentPage: 0,
        totalPages: derived.totalPages,
        totalFiltered: derived.totalFiltered,
      ),
    );
  }

  void _onFilterCleared(
    TransactionsFilterCleared event,
    Emitter<TransactionsState> emit,
  ) {
    const cleared = TransactionFilter();
    final derived = _derive(
      all: state.allTransactions,
      query: state.searchQuery,
      sort: state.sortOption,
      filter: cleared,
      page: 0,
    );
    emit(
      state.copyWith(
        filter: cleared,
        pageTransactions: derived.page,
        currentPage: 0,
        totalPages: derived.totalPages,
        totalFiltered: derived.totalFiltered,
      ),
    );
  }

  void _onPageChanged(
    TransactionsPageChanged event,
    Emitter<TransactionsState> emit,
  ) {
    final derived = _derive(
      all: state.allTransactions,
      query: state.searchQuery,
      sort: state.sortOption,
      filter: state.filter,
      page: event.page,
    );
    emit(
      state.copyWith(
        pageTransactions: derived.page,
        currentPage: derived.actualPage,
      ),
    );
  }

  /// Pure function: apply search + filter + sort, then paginate.
  _DerivedPage _derive({
    required List<TransactionModel> all,
    required String query,
    required SortOption sort,
    required TransactionFilter filter,
    required int page,
  }) {
    var items = List<TransactionModel>.from(all);

    // Search
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      items = items
          .where(
            (t) =>
                t.categoryName.toLowerCase().contains(q) ||
                (t.location?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    // Date range
    if (filter.dateFrom != null) {
      items = items
          .where(
            (t) => !t.date.isBefore(
              DateTime(
                filter.dateFrom!.year,
                filter.dateFrom!.month,
                filter.dateFrom!.day,
              ),
            ),
          )
          .toList();
    }
    if (filter.dateTo != null) {
      final end = DateTime(
        filter.dateTo!.year,
        filter.dateTo!.month,
        filter.dateTo!.day,
        23,
        59,
        59,
      );
      items = items.where((t) => !t.date.isAfter(end)).toList();
    }

    // Category substring
    if (filter.categoryQuery != null && filter.categoryQuery!.isNotEmpty) {
      final cq = filter.categoryQuery!.toLowerCase();
      items = items
          .where((t) => t.categoryName.toLowerCase().contains(cq))
          .toList();
    }

    // Amount range
    if (filter.minAmount != null) {
      items = items.where((t) => t.amount >= filter.minAmount!).toList();
    }
    if (filter.maxAmount != null) {
      items = items.where((t) => t.amount <= filter.maxAmount!).toList();
    }

    // Sort
    switch (sort) {
      case SortOption.dateNewest:
        items.sort((a, b) => b.date.compareTo(a.date));
      case SortOption.dateOldest:
        items.sort((a, b) => a.date.compareTo(b.date));
      case SortOption.amountHighest:
        items.sort((a, b) => b.amount.compareTo(a.amount));
      case SortOption.amountLowest:
        items.sort((a, b) => a.amount.compareTo(b.amount));
      case SortOption.categoryAZ:
        items.sort((a, b) => a.categoryName.compareTo(b.categoryName));
      case SortOption.categoryZA:
        items.sort((a, b) => b.categoryName.compareTo(a.categoryName));
    }

    final totalFiltered = items.length;
    final totalPages =
        totalFiltered == 0 ? 0 : (totalFiltered / kTransactionsPageSize).ceil();
    final actualPage = totalPages == 0 ? 0 : page.clamp(0, totalPages - 1);
    final paginated = items
        .skip(actualPage * kTransactionsPageSize)
        .take(kTransactionsPageSize)
        .toList();

    return _DerivedPage(
      page: paginated,
      totalFiltered: totalFiltered,
      totalPages: totalPages,
      actualPage: actualPage,
    );
  }
}

class _DerivedPage {
  const _DerivedPage({
    required this.page,
    required this.totalFiltered,
    required this.totalPages,
    required this.actualPage,
  });

  final List<TransactionModel> page;
  final int totalFiltered;
  final int totalPages;
  final int actualPage;
}
