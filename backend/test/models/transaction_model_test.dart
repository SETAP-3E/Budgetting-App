import 'package:budgetting_backend/models/transaction_model.dart';
import 'package:test/test.dart';

import '../helpers/db_helpers.dart';

void main() {
  group('TransactionModel', () {
    final baseRow = {
      'id': 'txn-uuid-1',
      'user_id': 'user-uuid-1',
      'account_id': 'acc-uuid-1',
      'category_id': 'cat-uuid-1',
      'category_name': 'Groceries',
      'amount': '49.99',
      'description': 'Tesco Warwick',
      'transaction_date': DateTime(2026, 3, 15),
      'latitude': '52.2800',
      'longitude': '-1.5850',
    };

    group('fromRow', () {
      test('maps all fields correctly', () {
        final model = TransactionModel.fromRow(makeRow(baseRow));

        expect(model.id, 'txn-uuid-1');
        expect(model.userId, 'user-uuid-1');
        expect(model.accountId, 'acc-uuid-1');
        expect(model.categoryId, 'cat-uuid-1');
        expect(model.categoryName, 'Groceries');
        expect(model.amount, 49.99);
        expect(model.description, 'Tesco Warwick');
        expect(model.transactionDate, '2026-03-15');
        expect(model.latitude, 52.28);
        expect(model.longitude, -1.585);
      });

      test('trims transactionDate to yyyy-MM-dd', () {
        final model = TransactionModel.fromRow(makeRow(baseRow));
        expect(model.transactionDate.length, 10);
        expect(model.transactionDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      });

      test('parses amount from string via double.parse', () {
        final row = {...baseRow, 'amount': '1234.56'};
        final model = TransactionModel.fromRow(makeRow(row));
        expect(model.amount, 1234.56);
      });

      test('handles null latitude and longitude', () {
        final row = {...baseRow, 'latitude': null, 'longitude': null};
        final model = TransactionModel.fromRow(makeRow(row));

        expect(model.latitude, isNull);
        expect(model.longitude, isNull);
      });

      test('handles null description', () {
        final row = {...baseRow, 'description': null};
        final model = TransactionModel.fromRow(makeRow(row));

        expect(model.description, isNull);
      });
    });

    group('toJson', () {
      const model = TransactionModel(
        id: 'txn-uuid-1',
        userId: 'user-uuid-1',
        accountId: 'acc-uuid-1',
        categoryId: 'cat-uuid-1',
        categoryName: 'Groceries',
        amount: 49.99,
        transactionDate: '2026-03-15',
        description: 'Tesco Warwick',
        latitude: 52.28,
        longitude: -1.585,
      );

      test('serializes all fields with snake_case keys', () {
        final json = model.toJson();

        expect(json['id'], 'txn-uuid-1');
        expect(json['user_id'], 'user-uuid-1');
        expect(json['account_id'], 'acc-uuid-1');
        expect(json['category_id'], 'cat-uuid-1');
        expect(json['category_name'], 'Groceries');
        expect(json['amount'], 49.99);
        expect(json['transaction_date'], '2026-03-15');
        expect(json['description'], 'Tesco Warwick');
        expect(json['latitude'], 52.28);
        expect(json['longitude'], -1.585);
      });

      test('includes null fields in output', () {
        const nullableModel = TransactionModel(
          id: 'txn-uuid-2',
          userId: 'user-uuid-1',
          accountId: 'acc-uuid-1',
          categoryId: 'cat-uuid-1',
          categoryName: 'Groceries',
          amount: 10,
          transactionDate: '2026-01-01',
        );

        final json = nullableModel.toJson();

        expect(json['description'], isNull);
        expect(json['latitude'], isNull);
        expect(json['longitude'], isNull);
      });
    });
  });
}
