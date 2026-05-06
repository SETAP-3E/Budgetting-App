import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/transactions_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen displaying the paginated, searchable, sortable transaction list.
class TransactionsScreen extends StatelessWidget {
  /// Create a [TransactionsScreen].
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionsBloc(apiClient: TransactionsApiClient())
        ..add(const TransactionsStarted()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  void _openAddExpenseSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddExpenseSheet(),
    ).then((_) {
      if (context.mounted) {
        context
            .read<TransactionsBloc>()
            .add(const TransactionsRefreshRequested());
      }
    });
  }

  void _openSortSheet(BuildContext context, SortOption current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _SortSheet(
        current: current,
        onSelected: (opt) =>
            context.read<TransactionsBloc>().add(TransactionsSortChanged(opt)),
      ),
    );
  }

  void _openFilterSheet(
    BuildContext context,
    TransactionFilter currentFilter,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TransactionsFilterSheet(
        initialFilter: currentFilter,
        onApply: (filter) => context
            .read<TransactionsBloc>()
            .add(TransactionsFilterChanged(filter)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Transactions',
        onMenuPressed: () {},
      ),
      body: Column(
        children: [
          _SearchAndToolbar(
            onSortTap: () => _openSortSheet(
              context,
              context.read<TransactionsBloc>().state.sortOption,
            ),
            onFilterTap: () => _openFilterSheet(
              context,
              context.read<TransactionsBloc>().state.filter,
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state.status == TransactionsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TransactionsStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ?? 'Something went wrong.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context
                                .read<TransactionsBloc>()
                                .add(const TransactionsRefreshRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.pageTransactions.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No transactions found.\n'
                          'Try adjusting your search or filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<TransactionsBloc>()
                      .add(const TransactionsRefreshRequested()),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.pageTransactions.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) => _TransactionTile(
                            transaction: state.pageTransactions[index],
                          ),
                        ),
                      ),
                      if (state.totalPages > 1)
                        _PaginationBar(
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          totalFiltered: state.totalFiltered,
                          onPrevious: () => context
                              .read<TransactionsBloc>()
                              .add(TransactionsPageChanged(
                                state.currentPage - 1,
                              ),),
                          onNext: () => context
                              .read<TransactionsBloc>()
                              .add(TransactionsPageChanged(
                                state.currentPage + 1,
                              ),),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseSheet(context),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppFooter(activeIndex: 3),
    );
  }
}

/// Search bar + sort/filter icon buttons.
class _SearchAndToolbar extends StatelessWidget {
  const _SearchAndToolbar({
    required this.onSortTap,
    required this.onFilterTap,
  });

  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: BlocSelector<TransactionsBloc, TransactionsState, String>(
              selector: (s) => s.searchQuery,
              builder: (context, query) => TextField(
                onChanged: (value) => context
                    .read<TransactionsBloc>()
                    .add(TransactionsSearchChanged(value)),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => context
                              .read<TransactionsBloc>()
                              .add(const TransactionsSearchChanged('')),
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          BlocSelector<TransactionsBloc, TransactionsState, bool>(
            selector: (s) => !s.filter.isEmpty,
            builder: (context, hasFilter) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  onPressed: onFilterTap,
                ),
                if (hasFilter)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: onSortTap,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for choosing a sort option.
class _SortSheet extends StatelessWidget {
  const _SortSheet({
    required this.current,
    required this.onSelected,
  });

  final SortOption current;
  final ValueChanged<SortOption> onSelected;

  static const _options = [
    (SortOption.dateNewest, 'Date: newest first'),
    (SortOption.dateOldest, 'Date: oldest first'),
    (SortOption.amountHighest, 'Amount: highest first'),
    (SortOption.amountLowest, 'Amount: lowest first'),
    (SortOption.categoryAZ, 'Category: A → Z'),
    (SortOption.categoryZA, 'Category: Z → A'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Sort by',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          RadioGroup<SortOption>(
            groupValue: current,
            onChanged: (val) {
              if (val != null) {
                onSelected(val);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _options
                  .map(
                    (entry) => RadioListTile<SortOption>(
                      title: Text(entry.$2),
                      value: entry.$1,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prev / page-indicator / Next bar shown below the list.
class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalFiltered,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int totalFiltered;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
            onPressed: currentPage == 0 ? null : onPrevious,
          ),
          Text(
            'Page ${currentPage + 1} of $totalPages  ·  $totalFiltered results',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
            onPressed: currentPage >= totalPages - 1 ? null : onNext,
          ),
        ],
      ),
    );
  }
}

/// A single row in the transactions list.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final date = transaction.date;
    final dateStr = '${date.day} ${_monthName(date.month)} ${date.year}';

    final subtitleParts = [
      if (transaction.location != null) transaction.location!,
      if (transaction.accountName != null) transaction.accountName!,
      dateStr,
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.receipt_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        transaction.categoryName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitleParts.join('  ·  ')),
      trailing: Text(
        formatCurrency(transaction.amount),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _monthName(int month) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];
}
