import 'package:budgetting_backend/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../helpers/db_helpers.dart';

class MockConnection extends Mock implements Connection {}

void main() {
  late MockConnection connection;
  late TransactionRepository repo;

  setUp(() {
    connection = MockConnection();
    repo = TransactionRepository(connection);
  });

  final fullRow = {
    'id': 'txn-uuid-1',
    'user_id': 'user-uuid-1',
    'account_id': 'acc-uuid-1',
    'category_id': 'cat-uuid-1',
    'category_name': 'Groceries',
    'amount': '49.99',
    'description': 'Tesco',
    'transaction_date': DateTime(2026, 3, 15),
    'latitude': '52.28',
    'longitude': '-1.58',
  };

  group('TransactionRepository', () {
    group('getTransactions', () {
      test('returns mapped transactions for the user', () async {
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => makeResult([fullRow]));

        final transactions = await repo.getTransactions('user-uuid-1');

        expect(transactions, hasLength(1));
        expect(transactions[0].id, 'txn-uuid-1');
        expect(transactions[0].categoryName, 'Groceries');
        expect(transactions[0].amount, 49.99);
      });

      test('returns empty list when user has no transactions', () async {
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => makeResult([]));

        final transactions = await repo.getTransactions('user-uuid-1');

        expect(transactions, isEmpty);
      });
    });

    group('createTransaction', () {
      test('inserts and returns the transaction with category name', () async {
        final insertRow = {
          'id': 'txn-uuid-new',
          'user_id': 'user-uuid-1',
          'account_id': 'acc-uuid-1',
          'category_id': 'cat-uuid-1',
          'amount': '25.00',
          'description': null,
          'transaction_date': DateTime(2026, 4),
          'latitude': null,
          'longitude': null,
        };
        final selectRow = {
          ...insertRow,
          'category_name': 'Dining',
        };

        var callCount = 0;
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          return callCount == 1
              ? makeResult([insertRow])
              : makeResult([selectRow]);
        });

        final transaction = await repo.createTransaction(
          userId: 'user-uuid-1',
          accountId: 'acc-uuid-1',
          categoryId: 'cat-uuid-1',
          amount: 25,
          transactionDate: '2026-04-01',
        );

        expect(transaction.id, 'txn-uuid-new');
        expect(transaction.categoryName, 'Dining');
        expect(callCount, 2);
      });
    });
  });
}
