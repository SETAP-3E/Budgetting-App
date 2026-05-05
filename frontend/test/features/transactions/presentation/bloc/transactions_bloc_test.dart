import 'package:bloc_test/bloc_test.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionsApiClient extends Mock implements TransactionsApiClient {}

TransactionModel _txn({
  required String id,
  required String categoryName,
  required double amount,
  required DateTime date,
  String? location,
}) =>
    TransactionModel(
      id: id,
      amount: amount,
      categoryName: categoryName,
      date: date,
      location: location,
    );

void main() {
  late MockTransactionsApiClient apiClient;

  final t1 = _txn(
    id: 'txn-1',
    categoryName: 'Groceries',
    amount: 50,
    date: DateTime(2026, 3, 10),
    location: 'Tesco',
  );
  final t2 = _txn(
    id: 'txn-2',
    categoryName: 'Dining',
    amount: 25,
    date: DateTime(2026, 3, 5),
    location: 'Nandos',
  );
  final t3 = _txn(
    id: 'txn-3',
    categoryName: 'Travel',
    amount: 10,
    date: DateTime(2026, 2, 20),
  );

  setUp(() {
    apiClient = MockTransactionsApiClient();
  });

  TransactionsBloc build() =>
      TransactionsBloc(apiClient: apiClient);

  group('TransactionsBloc', () {
    group('TransactionsStarted', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'emits [loading, success] on successful fetch',
        setUp: () => when(() => apiClient.getTransactions())
            .thenAnswer((_) async => [t1, t2, t3]),
        build: build,
        act: (b) => b.add(const TransactionsStarted()),
        expect: () => [
          const TransactionsState(status: TransactionsStatus.loading),
          isA<TransactionsState>()
              .having((s) => s.status, 'status', TransactionsStatus.success)
              .having((s) => s.allTransactions.length, 'allTransactions', 3)
              .having(
                (s) => s.totalFiltered,
                'totalFiltered',
                3,
              )
              .having((s) => s.currentPage, 'currentPage', 0),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'emits [loading, failure] when API throws',
        setUp: () => when(() => apiClient.getTransactions())
            .thenThrow(Exception('network error')),
        build: build,
        act: (b) => b.add(const TransactionsStarted()),
        expect: () => [
          const TransactionsState(status: TransactionsStatus.loading),
          isA<TransactionsState>()
              .having(
                (s) => s.status,
                'status',
                TransactionsStatus.failure,
              )
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('TransactionsRefreshRequested', () {
      blocTest<TransactionsBloc, TransactionsState>(
        're-fetches and emits [loading, success]',
        setUp: () => when(() => apiClient.getTransactions())
            .thenAnswer((_) async => [t1]),
        build: build,
        seed: () => const TransactionsState(
          status: TransactionsStatus.success,
        ),
        act: (b) => b.add(const TransactionsRefreshRequested()),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.status, 'status', TransactionsStatus.loading),
          isA<TransactionsState>()
              .having((s) => s.status, 'status', TransactionsStatus.success)
              .having((s) => s.allTransactions.length, 'count', 1),
        ],
      );
    });

    group('TransactionsSearchChanged', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'filters by categoryName substring (case-insensitive)',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(const TransactionsSearchChanged('groc')),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.searchQuery, 'query', 'groc')
              .having((s) => s.totalFiltered, 'totalFiltered', 1)
              .having(
                (s) => s.pageTransactions.first.categoryName,
                'category',
                'Groceries',
              ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'filters by location substring',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(const TransactionsSearchChanged('nandos')),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.totalFiltered, 'totalFiltered', 1)
              .having(
                (s) => s.pageTransactions.first.id,
                'id',
                'txn-2',
              ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'empty query shows all transactions',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1],
          searchQuery: 'groc',
          totalFiltered: 1,
          totalPages: 1,
        ),
        act: (b) => b.add(const TransactionsSearchChanged('')),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.searchQuery, 'query', '')
              .having((s) => s.totalFiltered, 'totalFiltered', 3),
        ],
      );
    });

    group('TransactionsSortChanged', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'dateOldest sorts ascending by date',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          const TransactionsSortChanged(SortOption.dateOldest),
        ),
        expect: () => [
          isA<TransactionsState>().having(
            (s) => s.pageTransactions.first.id,
            'first id',
            'txn-3',
          ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'amountHighest sorts descending by amount',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          const TransactionsSortChanged(SortOption.amountHighest),
        ),
        expect: () => [
          isA<TransactionsState>().having(
            (s) => s.pageTransactions.first.amount,
            'first amount',
            50.0,
          ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'categoryAZ sorts alphabetically',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          const TransactionsSortChanged(SortOption.categoryAZ),
        ),
        expect: () => [
          isA<TransactionsState>().having(
            (s) => s.pageTransactions.first.categoryName,
            'first category',
            'Dining',
          ),
        ],
      );
    });

    group('TransactionsFilterChanged', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'filters by date range',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          TransactionsFilterChanged(
            TransactionFilter(
              dateFrom: DateTime(2026, 3),
              dateTo: DateTime(2026, 3, 31),
            ),
          ),
        ),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.totalFiltered, 'totalFiltered', 2),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'filters by category query substring',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          const TransactionsFilterChanged(
            TransactionFilter(categoryQuery: 'travel'),
          ),
        ),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.totalFiltered, 'totalFiltered', 1)
              .having(
                (s) => s.pageTransactions.first.id,
                'id',
                'txn-3',
              ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'filters by amount range',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t1, t2, t3],
          totalFiltered: 3,
          totalPages: 1,
        ),
        act: (b) => b.add(
          const TransactionsFilterChanged(
            TransactionFilter(minAmount: 20, maxAmount: 30),
          ),
        ),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.totalFiltered, 'totalFiltered', 1)
              .having(
                (s) => s.pageTransactions.first.amount,
                'amount',
                25.0,
              ),
        ],
      );
    });

    group('TransactionsFilterCleared', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'resets filter and shows all transactions',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: [t1, t2, t3],
          pageTransactions: [t3],
          filter: const TransactionFilter(categoryQuery: 'travel'),
          totalFiltered: 1,
          totalPages: 1,
        ),
        act: (b) => b.add(const TransactionsFilterCleared()),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.filter.isEmpty, 'filter.isEmpty', isTrue)
              .having((s) => s.totalFiltered, 'totalFiltered', 3),
        ],
      );
    });

    group('TransactionsPageChanged', () {
      final manyTxns = List.generate(
        15,
        (i) => _txn(
          id: 'txn-$i',
          categoryName: 'Cat$i',
          amount: i.toDouble(),
          date: DateTime(2026, 3, i + 1),
        ),
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'returns the correct page slice',
        build: build,
        seed: () => TransactionsState(
          status: TransactionsStatus.success,
          allTransactions: manyTxns,
          pageTransactions: manyTxns.take(10).toList(),
          totalFiltered: 15,
          totalPages: 2,
        ),
        act: (b) => b.add(const TransactionsPageChanged(1)),
        expect: () => [
          isA<TransactionsState>()
              .having((s) => s.currentPage, 'currentPage', 1)
              .having(
                (s) => s.pageTransactions.length,
                'pageSize',
                5,
              ),
        ],
      );
    });
  });
}
