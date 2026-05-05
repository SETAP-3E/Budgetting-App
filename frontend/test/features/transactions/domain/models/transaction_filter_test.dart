import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionFilter', () {
    group('isEmpty', () {
      test('returns true when all fields are null or empty', () {
        expect(const TransactionFilter().isEmpty, isTrue);
      });

      test('returns false when dateFrom is set', () {
        final filter =
            TransactionFilter(dateFrom: DateTime(2026));
        expect(filter.isEmpty, isFalse);
      });

      test('returns false when dateTo is set', () {
        final filter = TransactionFilter(dateTo: DateTime(2026));
        expect(filter.isEmpty, isFalse);
      });

      test('returns false when categoryQuery is non-empty', () {
        const filter = TransactionFilter(categoryQuery: 'Food');
        expect(filter.isEmpty, isFalse);
      });

      test('returns true when categoryQuery is empty string', () {
        const filter = TransactionFilter(categoryQuery: '');
        expect(filter.isEmpty, isTrue);
      });

      test('returns false when minAmount is set', () {
        const filter = TransactionFilter(minAmount: 10);
        expect(filter.isEmpty, isFalse);
      });

      test('returns false when maxAmount is set', () {
        const filter = TransactionFilter(maxAmount: 100);
        expect(filter.isEmpty, isFalse);
      });
    });

    group('copyWith', () {
      const base = TransactionFilter(
        categoryQuery: 'Groceries',
        minAmount: 5,
        maxAmount: 50,
      );

      test('replaces only the specified fields', () {
        final updated = base.copyWith(minAmount: 10);

        expect(updated.categoryQuery, 'Groceries');
        expect(updated.minAmount, 10);
        expect(updated.maxAmount, 50);
      });

      test('preserves all fields when called with no arguments', () {
        final copy = base.copyWith();
        expect(copy, equals(base));
      });
    });

    group('equality', () {
      test('two filters with identical fields are equal', () {
        final a = TransactionFilter(
          dateFrom: DateTime(2026),
          dateTo: DateTime(2026, 3),
          categoryQuery: 'Dining',
          minAmount: 5,
          maxAmount: 100,
        );
        final b = TransactionFilter(
          dateFrom: DateTime(2026),
          dateTo: DateTime(2026, 3),
          categoryQuery: 'Dining',
          minAmount: 5,
          maxAmount: 100,
        );

        expect(a, equals(b));
      });

      test('two filters with different fields are not equal', () {
        const a = TransactionFilter(categoryQuery: 'Food');
        const b = TransactionFilter(categoryQuery: 'Travel');

        expect(a, isNot(equals(b)));
      });
    });
  });
}
